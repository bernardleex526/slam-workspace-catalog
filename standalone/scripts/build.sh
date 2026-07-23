#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="${1:-}"
WS="${ROOT}/workspaces/${PROJECT}_ws"

if [[ "${PROJECT}" != "kiss_slam" || ! -d "${WS}/src/kiss-slam" ]]; then
  echo "Usage: $0 kiss_slam" >&2
  echo "Run scripts/fetch.sh kiss_slam first." >&2
  exit 2
fi

command -v make >/dev/null || {
  echo "make not found. Install build-essential first." >&2
  exit 1
}

cd "${WS}/src/kiss-slam"
make editable

echo "KISS-SLAM installed in editable mode."
echo "Run: kiss_slam_pipeline --help"
