#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="${1:-}"
SRC="${ROOT}/workspaces/${PROJECT}_ws/src"
OUT="${ROOT}/locks/${PROJECT}-exact.repos"

if [[ -z "${PROJECT}" || ! -d "${SRC}" ]]; then
  echo "Usage: $0 <project-id>" >&2
  exit 2
fi

mkdir -p "${ROOT}/locks"
vcs export --exact "${SRC}" > "${OUT}"
echo "Wrote ${OUT}"
