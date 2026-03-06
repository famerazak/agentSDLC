#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="famerazak"
REPO_NAME="agentSDLC"
BRANCH="main"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/scripts/agentsdlc-installer.sh" install "$@"