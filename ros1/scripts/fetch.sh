#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ALGORITHM="${1:-}"

if [[ -z "${ALGORITHM}" ]]; then
  echo "Usage: $0 <algorithm-id>"
  bash "${ROOT}/scripts/list.sh"
  exit 2
fi

MANIFEST="${ROOT}/manifests/${ALGORITHM}.repos"
WS="${ROOT}/workspaces/${ALGORITHM}_ws"

if [[ ! -f "${MANIFEST}" ]]; then
  echo "Unknown algorithm: ${ALGORITHM}" >&2
  bash "${ROOT}/scripts/list.sh"
  exit 2
fi

command -v vcs >/dev/null || {
  echo "vcstool not found. Install: sudo apt install python3-vcstool" >&2
  exit 1
}

mkdir -p "${WS}/src"
vcs import "${WS}/src" < "${MANIFEST}"

while IFS= read -r -d '' gitdir; do
  repo_dir="$(dirname "${gitdir}")"
  git -C "${repo_dir}" submodule update --init --recursive
done < <(find "${WS}/src" -type d -name .git -print0)

echo "Fetched ${ALGORITHM} into ${WS}/src"
