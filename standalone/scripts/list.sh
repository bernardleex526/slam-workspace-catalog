#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
column -t -s $'\t' "${ROOT}/catalog.tsv" 2>/dev/null || cat "${ROOT}/catalog.tsv"
