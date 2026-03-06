#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-YOUR_GITHUB_USERNAME}"
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

COLOUR_RED="$(printf '\033[31m')"
COLOUR_GREEN="$(printf '\033[32m')"
COLOUR_YELLOW="$(printf '\033[33m')"
COLOUR_BLUE="$(printf '\033[34m')"
COLOUR_RESET="$(printf '\033[0m')"

log() {
  printf "%b\n" "${COLOUR_BLUE}$*${COLOUR_RESET}"
}

success() {
  printf "%b\n" "${COLOUR_GREEN}$*${COLOUR_RESET}"
}

warn() {
  printf "%b\n" "${COLOUR_YELLOW}$*${COLOUR_RESET}"
}

error() {
  printf "%b\n" "${COLOUR_RED}$*${COLOUR_RESET}" >&2
}

cleanup() {
  if [[ -n "${TMP_DIR}" && -d "${TMP_DIR}" ]]; then
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

Examples:
  ./scripts/agentsdlc-installer.sh install --all
  ./scripts/agentsdlc-installer.sh install --skill idea-to-prd
  ./scripts/agentsdlc-installer.sh update --all --force
  ./scripts/agentsdlc-installer.sh uninstall --skill idea-to-prd
EOF
}

ensure_dirs() {
  mkdir -p "${SKILLS_DIR}"
  mkdir -p "${AGENTSDLC_DIR}"
  mkdir -p "${META_DIR}"
  mkdir -p "${VERSIONS_DIR}"
}

ensure_dependencies() {
  local missing=0

  for cmd in curl tar mktemp; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
      error "Missing required command: ${cmd}"
      missing=1
    fi
  done

  if [[ "${missing}" -ne 0 ]]; then
    exit 1
  fi
}

download_archive() {
  TMP_DIR="$(mktemp -d)"
  local archive_file="${TMP_DIR}/repo.tar.gz"

  log "Downloading ${REPO_NAME} from GitHub..."
  curl -fsSL "${ARCHIVE_URL}" -o "${archive_file}"

  log "Extracting archive..."
  tar -xzf "${archive_file}" -C "${TMP_DIR}"
}

repo_root() {
  printf "%s/%s-%s" "${TMP_DIR}" "${REPO_NAME}" "${BRANCH}"
}

manifest_path() {
  printf "%s/manifest/skills.txt" "$(repo_root)"
}

version_value() {
  if curl -fsSL "${RAW_BASE_URL}/manifest/version.txt" >/dev/null 2>&1; then
    curl -fsSL "${RAW_BASE_URL}/manifest/version.txt"
  else
    printf "%s" "${BRANCH}"
  fi
}

read_all_skills() {
  local manifest
  manifest="$(manifest_path)"

  if [[ ! -f "${manifest}" ]]; then
    error "Manifest not found at ${manifest}"
    exit 1
  fi

  grep -v '^[[:space:]]*$' "${manifest}" | grep -v '^[[:space:]]*#'
}

skill_source_dir() {
  local skill_name="$1"
  printf "%s/.claude/skills/%s" "$(repo_root)" "${skill_name}"
}

skill_target_dir() {
  local skill_name="$1"
  printf "%s/%s" "${SKILLS_DIR}" "${skill_name}"
}

skill_version_file() {
  local skill_name="$1"
  printf "%s/%s.version" "${VERSIONS_DIR}" "${skill_name}"
}

is_managed_by_agentsdlc() {
  local skill_name="$1"
  local target
  target="$(skill_target_dir "${skill_name}")"

  [[ -f "${target}/.agentsdlc-managed" ]]
}

write_management_marker() {
  local skill_name="$1"
  local target version_file version
  target="$(skill_target_dir "${skill_name}")"
  version_file="$(skill_version_file "${skill_name}")"
  version="$(version_value)"

  cat > "${target}/.agentsdlc-managed" <<EOF
repo_owner=${REPO_OWNER}
repo_name=${REPO_NAME}
branch=${BRANCH}
skill=${skill_name}
version=${version}
installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

  printf "%s\n" "${version}" > "${version_file}"
}

remove_management_marker() {
  local skill_name="$1"
  local target version_file
  target="$(skill_target_dir "${skill_name}")"
  version_file="$(skill_version_file "${skill_name}")"

  rm -f "${target}/.agentsdlc-managed"
  rm -f "${version_file}"
}

parse_targets() {
  ALL_REQUESTED=0
  FORCE=0
  TARGET_SKILLS=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all)
        ALL_REQUESTED=1
        shift
        ;;
      --skill)
        if [[ $# -lt 2 ]]; then
          error "--skill requires a value"
          exit 1
        fi
        TARGET_SKILLS+=("$2")
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
  if [[ "${ALL_REQUESTED}" -eq 1 ]]; then
    mapfile -t RESOLVED_SKILLS < <(read_all_skills)
  elif [[ "${#TARGET_SKILLS[@]}" -gt 0 ]]; then
    RESOLVED_SKILLS=("${TARGET_SKILLS[@]}")
  else
    warn "No skill specified. Defaulting to --all"
    mapfile -t RESOLVED_SKILLS < <(read_all_skills)
  fi
}

check_skill_exists_in_archive() {
  local skill_name="$1"
  local src
  src="$(skill_source_dir "${skill_name}")"

  if [[ ! -d "${src}" ]]; then
    error "Skill '${skill_name}' not found in repo archive"
    return 1
  fi

  if [[ ! -f "${src}/SKILL.md" ]]; then
    error "Skill '${skill_name}' is missing SKILL.md"
    return 1
  fi
}

install_one_skill() {
  local skill_name="$1"
  local src target
  src="$(skill_source_dir "${skill_name}")"
  target="$(skill_target_dir "${skill_name}")"

  check_skill_exists_in_archive "${skill_name}"

  if [[ -e "${target}" ]]; then
    if is_managed_by_agentsdlc "${skill_name}"; then
      if [[ "${FORCE}" -eq 1 ]]; then
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
  success "Installed skill: ${skill_name}"
}

update_one_skill() {
  local skill_name="$1"
  local src target
  src="$(skill_source_dir "${skill_name}")"
  target="$(skill_target_dir "${skill_name}")"

  check_skill_exists_in_archive "${skill_name}"

  if [[ ! -e "${target}" ]]; then
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
  success "Updated skill: ${skill_name}"
}

uninstall_one_skill() {
  local skill_name="$1"
  local target
  target="$(skill_target_dir "${skill_name}")"

  if [[ ! -e "${target}" ]]; then
    warn "Skill '${skill_name}' is not installed."
    return 0
  fi

  if ! is_managed_by_agentsdlc "${skill_name}"; then
    warn "Refusing to remove '${skill_name}' because it is not marked as managed by agentSDLC."
    return 0
  fi

  rm -rf "${target}"
  remove_management_marker "${skill_name}"
  success "Removed skill: ${skill_name}"
}

list_skills() {
  ensure_dirs

  printf "\nInstalled skills in %s\n\n" "${SKILLS_DIR}"

  if [[ ! -d "${SKILLS_DIR}" ]]; then
    printf "No skills directory found.\n"
    return 0
  fi

  local found=0
  local entry skill_name version_file version managed

  for entry in "${SKILLS_DIR}"/*; do
    [[ -d "${entry}" ]] || continue
    found=1
    skill_name="$(basename "${entry}")"
    version_file="$(skill_version_file "${skill_name}")"
    managed="no"
    version="unknown"

    if is_managed_by_agentsdlc "${skill_name}"; then
      managed="yes"
    fi

    if [[ -f "${version_file}" ]]; then
      version="$(cat "${version_file}")"
    fi

    printf "- %s | managed_by_agentsdlc=%s | version=%s\n" "${skill_name}" "${managed}" "${version}"
  done

  if [[ "${found}" -eq 0 ]]; then
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

  if [[ -d "${SKILLS_DIR}" ]]; then
    printf "Skills dir exists: yes\n"
  else
    printf "Skills dir exists: no\n"
  fi

  if command -v claude >/dev/null 2>&1; then
    printf "Claude Code CLI found: yes\n"
  else
    printf "Claude Code CLI found: no\n"
  fi

  printf "\nManaged skills:\n"
  list_skills
}

main() {
  if [[ $# -lt 1 ]]; then
    usage
    exit 1
  fi

  local command="$1"
  shift

  ensure_dependencies
  ensure_dirs

  case "${command}" in
    install)
      parse_targets "$@"
      download_archive
      resolve_targets
      for skill_name in "${RESOLVED_SKILLS[@]}"; do
        install_one_skill "${skill_name}"
      done
      printf "\n"
      success "Install complete."
      printf "Restart Claude Code and run /help to verify your skills.\n"
      ;;
    update)
      parse_targets "$@"
      download_archive
      resolve_targets
      for skill_name in "${RESOLVED_SKILLS[@]}"; do
        update_one_skill "${skill_name}"
      done
      printf "\n"
      success "Update complete."
      printf "Restart Claude Code and run /help to verify your skills.\n"
      ;;
    uninstall)
      parse_targets "$@"
      if [[ "${ALL_REQUESTED}" -eq 1 ]]; then
        mapfile -t RESOLVED_SKILLS < <(
          if [[ -d "${SKILLS_DIR}" ]]; then
            find "${SKILLS_DIR}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;
          fi
        )
      else
        RESOLVED_SKILLS=("${TARGET_SKILLS[@]}")
      fi

      if [[ "${#RESOLVED_SKILLS[@]}" -eq 0 ]]; then
        error "No skills specified for uninstall."
        exit 1
      fi

      for skill_name in "${RESOLVED_SKILLS[@]}"; do
        uninstall_one_skill "${skill_name}"
      done
      printf "\n"
      success "Uninstall complete."
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
      error "Unknown command: ${command}"
      usage
      exit 1
      ;;
  esac
}

main "$@"