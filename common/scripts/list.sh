#!/usr/bin/env bash
set -euo pipefail

ROOT="${SLAM_TREE_ROOT:?run this through <tree>/scripts/list.sh}"
column -t -s $'\t' "${ROOT}/catalog.tsv" 2>/dev/null || cat "${ROOT}/catalog.tsv"
