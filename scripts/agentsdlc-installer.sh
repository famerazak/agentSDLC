#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-famerazak}"
REPO_NAME="${REPO_NAME:-agentSDLC}"
BRANCH="${BRANCH:-main}"

ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${BRANCH}.tar.gz"
RAW_BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

CLAUDE_DIR="${HOME}/.claude"
SKILLS_DIR="${CLAUDE_DIR}/skills"
AGENTSDLC_DIR="${CLAUDE_DIR}/agentsdlc"
META_DIR="${AGENTSDLC_DIR}/meta"
VERSIONS_DIR="${META_DIR}/versions"
TMP_DIR=""
EXTRACTED_ROOT=""

log() {
  printf "%s\n" "$*"
}

warn() {
  printf "WARNING: %s\n" "$*" >&2
}

error() {
  printf "ERROR: %s\n" "$*" >&2
}

cleanup() {
  if [ -n "${TMP_DIR}" ] && [ -d "${TMP_DIR}" ]; then
    rm -rf "${TMP_DIR}"
  fi
}
trap cleanup EXIT

usage() {
  cat <<EOF
agentSDLC installer

Usage:
  agentsdlc-installer.sh install [--all | --skill <name> ...] [--force]
  agentsdlc-installer.sh update [--all | --skill <name> ...] [--force]
  agentsdlc-installer.sh uninstall [--all | --skill <name> ...]
  agentsdlc-installer.sh list
  agentsdlc-installer.sh doctor

Options:
  --all              Install/update/uninstall all known skills
  --skill <name>     Target a specific skill. May be provided multiple times
  --force            Replace an existing skill folder if present
  -h, --help         Show this help
EOF
}

ensure_dirs() {
  mkdir -p "${SKILLS_DIR}"
  mkdir -p "${AGENTSDLC_DIR}"
  mkdir -p "${META_DIR}"
  mkdir -p "${VERSIONS_DIR}"
}

ensure_dependencies() {
  missing=0
  for cmd in curl tar mktemp find grep sed; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
      error "Missing required command: ${cmd}"
      missing=1
    fi
  done

  if [ "${missing}" -ne 0 ]; then
    exit 1
  fi
}

download_archive() {
  TMP_DIR="$(mktemp -d)"
  archive_file="${TMP_DIR}/repo.tar.gz"

  log "Downloading ${REPO_NAME} from GitHub..."
  curl -fsSL "${ARCHIVE_URL}" -o "${archive_file}"

  log "Extracting archive..."
  tar -xzf "${archive_file}" -C "${TMP_DIR}"

  EXTRACTED_ROOT="$(find "${TMP_DIR}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

  if [ -z "${EXTRACTED_ROOT}" ] || [ ! -d "${EXTRACTED_ROOT}" ]; then
    error "Could not determine extracted repo root."
    exit 1
  fi
}

repo_root() {
  printf "%s" "${EXTRACTED_ROOT}"
}

manifest_path() {
  printf "%s/manifest/skills.txt" "$(repo_root)"
}

version_path() {
  printf "%s/manifest/version.txt" "$(repo_root)"
}

version_value() {
  if [ -f "$(version_path)" ]; then
    cat "$(version_path)"
  else
    printf "%s" "${BRANCH}"
  fi
}

read_all_skills() {
  manifest="$(manifest_path)"

  if [ ! -f "${manifest}" ]; then
    error "Manifest not found at ${manifest}"
    error "Make sure manifest/skills.txt exists in the GitHub repo."
    exit 1
  fi

  grep -v '^[[:space:]]*$' "${manifest}" | grep -v '^[[:space:]]*#'
}

skill_source_dir() {
  skill_name="$1"
  printf "%s/.claude/skills/%s" "$(repo_root)" "${skill_name}"
}

skill_target_dir() {
  skill_name="$1"
  printf "%s/%s" "${SKILLS_DIR}" "${skill_name}"
}

skill_version_file() {
  skill_name="$1"
  printf "%s/%s.version" "${VERSIONS_DIR}" "${skill_name}"
}

is_managed_by_agentsdlc() {
  skill_name="$1"
  target="$(skill_target_dir "${skill_name}")"
  [ -f "${target}/.agentsdlc-managed" ]
}

write_management_marker() {
  skill_name="$1"
  target="$(skill_target_dir "${skill_name}")"
  version="$(version_value)"

  cat > "${target}/.agentsdlc-managed" <<EOF
repo_owner=${REPO_OWNER}
repo_name=${REPO_NAME}
branch=${BRANCH}
skill=${skill_name}
version=${version}
installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

  printf "%s\n" "${version}" > "$(skill_version_file "${skill_name}")"
}

remove_management_marker() {
  skill_name="$1"
  target="$(skill_target_dir "${skill_name}")"

  rm -f "${target}/.agentsdlc-managed"
  rm -f "$(skill_version_file "${skill_name}")"
}

ALL_REQUESTED=0
FORCE=0
TARGET_SKILLS=""
RESOLVED_SKILLS=""

parse_targets() {
  ALL_REQUESTED=0
  FORCE=0
  TARGET_SKILLS=""
  RESOLVED_SKILLS=""

  while [ $# -gt 0 ]; do
    case "$1" in
      --all)
        ALL_REQUESTED=1
        shift
        ;;
      --skill)
        if [ $# -lt 2 ]; then
          error "--skill requires a value"
          exit 1
        fi
        TARGET_SKILLS="${TARGET_SKILLS}
$2"
        shift 2
        ;;
      --force)
        FORCE=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        error "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done
}

resolve_targets() {
  if [ "${ALL_REQUESTED}" -eq 1 ]; then
    RESOLVED_SKILLS="$(read_all_skills)"
  elif [ -n "${TARGET_SKILLS}" ]; then
    RESOLVED_SKILLS="$(printf "%s\n" "${TARGET_SKILLS}" | sed '/^[[:space:]]*$/d')"
  else
    warn "No skill specified. Defaulting to --all"
    RESOLVED_SKILLS="$(read_all_skills)"
  fi
}

check_skill_exists_in_archive() {
  skill_name="$1"
  src="$(skill_source_dir "${skill_name}")"

  if [ ! -d "${src}" ]; then
    error "Skill '${skill_name}' not found in repo archive at ${src}"
    return 1
  fi

  if [ ! -f "${src}/SKILL.md" ]; then
    error "Skill '${skill_name}' is missing SKILL.md"
    return 1
  fi
}

install_one_skill() {
  skill_name="$1"
  src="$(skill_source_dir "${skill_name}")"
  target="$(skill_target_dir "${skill_name}")"

  check_skill_exists_in_archive "${skill_name}"

  if [ -e "${target}" ]; then
    if is_managed_by_agentsdlc "${skill_name}"; then
      if [ "${FORCE}" -eq 1 ]; then
        warn "Replacing managed skill: ${skill_name}"
        rm -rf "${target}"
      else
        warn "Skill '${skill_name}' already installed. Use update or --force."
        return 0
      fi
    else
      warn "Skipping '${skill_name}' because ${target} already exists and is not managed by agentSDLC."
      return 0
    fi
  fi

  cp -R "${src}" "${target}"
  write_management_marker "${skill_name}"
  log "Installed skill: ${skill_name}"
}

update_one_skill() {
  skill_name="$1"
  src="$(skill_source_dir "${skill_name}")"
  target="$(skill_target_dir "${skill_name}")"

  check_skill_exists_in_archive "${skill_name}"

  if [ ! -e "${target}" ]; then
    warn "Skill '${skill_name}' is not installed. Installing it now."
    install_one_skill "${skill_name}"
    return 0
  fi

  if ! is_managed_by_agentsdlc "${skill_name}"; then
    warn "Skipping '${skill_name}' because ${target} exists and is not managed by agentSDLC."
    return 0
  fi

  rm -rf "${target}"
  cp -R "${src}" "${target}"
  write_management_marker "${skill_name}"
  log "Updated skill: ${skill_name}"
}

uninstall_one_skill() {
  skill_name="$1"
  target="$(skill_target_dir "${skill_name}")"

  if [ ! -e "${target}" ]; then
    warn "Skill '${skill_name}' is not installed."
    return 0
  fi

  if ! is_managed_by_agentsdlc "${skill_name}"; then
    warn "Refusing to remove '${skill_name}' because it is not marked as managed by agentSDLC."
    return 0
  fi

  rm -rf "${target}"
  remove_management_marker "${skill_name}"
  log "Removed skill: ${skill_name}"
}

for_each_resolved_skill() {
  callback="$1"
  printf "%s\n" "${RESOLVED_SKILLS}" | while IFS= read -r skill_name; do
    [ -n "${skill_name}" ] || continue
    "${callback}" "${skill_name}"
  done
}

list_skills() {
  ensure_dirs

  printf "\nInstalled skills in %s\n\n" "${SKILLS_DIR}"

  found=0
  for entry in "${SKILLS_DIR}"/*; do
    [ -d "${entry}" ] || continue
    found=1
    skill_name="$(basename "${entry}")"
    version_file="$(skill_version_file "${skill_name}")"
    managed="no"
    version="unknown"

    if is_managed_by_agentsdlc "${skill_name}"; then
      managed="yes"
    fi

    if [ -f "${version_file}" ]; then
      version="$(cat "${version_file}")"
    fi

    printf -- "- %s | managed_by_agentsdlc=%s | version=%s\n" "${skill_name}" "${managed}" "${version}"
  done

  if [ "${found}" -eq 0 ]; then
    printf "No installed skills found.\n"
  fi
}

doctor() {
  ensure_dirs
  ensure_dependencies

  printf "\nagentSDLC doctor\n\n"
  printf "Claude dir: %s\n" "${CLAUDE_DIR}"
  printf "Skills dir: %s\n" "${SKILLS_DIR}"
  printf "Meta dir:   %s\n" "${META_DIR}"

  if command -v claude >/dev/null 2>&1; then
    printf "Claude Code CLI found: yes\n"
  else
    printf "Claude Code CLI found: no\n"
  fi

  list_skills
}

main() {
  if [ $# -lt 1 ]; then
    usage
    exit 1
  fi

  command_name="$1"
  shift

  ensure_dependencies
  ensure_dirs

  case "${command_name}" in
    install)
      parse_targets "$@"
      download_archive
      resolve_targets
      for_each_resolved_skill install_one_skill
      printf "\nInstall complete.\n"
      printf "Restart Claude Code and run /help to verify your skills.\n"
      ;;
    update)
      parse_targets "$@"
      download_archive
      resolve_targets
      for_each_resolved_skill update_one_skill
      printf "\nUpdate complete.\n"
      printf "Restart Claude Code and run /help to verify your skills.\n"
      ;;
    uninstall)
      parse_targets "$@"

      if [ "${ALL_REQUESTED}" -eq 1 ]; then
        RESOLVED_SKILLS=""
        for entry in "${SKILLS_DIR}"/*; do
          [ -d "${entry}" ] || continue
          RESOLVED_SKILLS="${RESOLVED_SKILLS}
$(basename "${entry}")"
        done
      else
        RESOLVED_SKILLS="$(printf "%s\n" "${TARGET_SKILLS}" | sed '/^[[:space:]]*$/d')"
      fi

      if [ -z "${RESOLVED_SKILLS}" ]; then
        error "No skills specified for uninstall."
        exit 1
      fi

      for_each_resolved_skill uninstall_one_skill
      printf "\nUninstall complete.\n"
      ;;
    list)
      list_skills
      ;;
    doctor)
      doctor
      ;;
    -h|--help)
      usage
      ;;
    *)
      error "Unknown command: ${command_name}"
      usage
      exit 1
      ;;
  esac
}

main "$@"
