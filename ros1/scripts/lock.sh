#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ALGORITHM="${1:-}"
SRC="${ROOT}/workspaces/${ALGORITHM}_ws/src"
OUT="${ROOT}/locks/${ALGORITHM}-exact.repos"

if [[ -z "${ALGORITHM}" || ! -d "${SRC}" ]]; then
  echo "Usage: $0 <algorithm-id>" >&2
  exit 2
fi

mkdir -p "${ROOT}/locks"
vcs export --exact "${SRC}" > "${OUT}"
echo "Wrote ${OUT}"
