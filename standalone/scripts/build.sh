#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="${1:-}"
WS="${ROOT}/workspaces/${PROJECT}_ws"
CATALOG="${ROOT}/catalog.tsv"

if [[ -z "${PROJECT}" || ! -d "${WS}/src" ]]; then
  echo "Usage: $0 <project-id>" >&2
  echo "Run scripts/fetch.sh <project-id> first." >&2
  exit 2
fi

# Guard: refuse generic builds for heavy/custom entries unless explicitly allowed.
BUILD_MODE="$(awk -F '\t' -v id="${PROJECT}" '$1==id {print $5; exit}' "${CATALOG}")"
if [[ -z "${BUILD_MODE}" ]]; then
  echo "Unknown project id in catalog: ${PROJECT}" >&2
  exit 2
fi
if [[ "${BUILD_MODE}" != "generic" && "${SLAM_BUILD_ALLOW_NON_GENERIC:-0}" != "1" ]]; then
  cat >&2 <<EOF
${PROJECT} is marked '${BUILD_MODE}' in catalog.tsv.
'${BUILD_MODE}' entries need dedicated upstream install/build flows. The generic
script does NOT install those - read the upstream README and the catalog notes
first.
Re-run deliberately with: SLAM_BUILD_ALLOW_NON_GENERIC=1 $0 ${PROJECT}
EOF
  exit 1
fi

# Only entries with a known standalone build path are supported generically.
if [[ "${PROJECT}" != "kiss_slam" ]]; then
  echo "No generic build path is known for standalone entry: ${PROJECT}" >&2
  echo "Currently supported: kiss_slam" >&2
  exit 1
fi

command -v make >/dev/null || {
  echo "make not found. Install: sudo apt install build-essential" >&2
  exit 1
}
command -v python3 >/dev/null || {
  echo "python3 not found. Install: sudo apt install python3" >&2
  exit 1
}
python3 -m pip --version >/dev/null 2>&1 || {
  echo "pip not found for python3. Install: sudo apt install python3-pip" >&2
  exit 1
}

# PEP 668 guard: Ubuntu 22.04+ system Python refuses pip installs unless a venv
# is used. Fail with clear guidance instead of breaking system packages.
if [[ -z "${VIRTUAL_ENV:-}" ]]; then
  MANAGED="$(python3 - <<'PY'
import os, sys, sysconfig
if sys.prefix == sys.base_prefix:
    stdlib = sysconfig.get_path("stdlib")
else:
    stdlib = sysconfig.get_path("stdlib", vars={"installed_base": sys.base_prefix})
print("yes" if os.path.exists(os.path.join(stdlib, "EXTERNALLY-MANAGED")) else "no")
PY
)"
  if [[ "${MANAGED}" == "yes" ]]; then
    cat >&2 <<'EOF'
This Python environment is externally managed (PEP 668): a system-wide pip
editable install would fail. Use a virtual environment instead:

  python3 -m venv .venv && source .venv/bin/activate
  bash scripts/build.sh kiss_slam

(or install via pipx). Avoid pip install --break-system-packages in shared
environments.
EOF
    exit 1
  fi
  echo "WARNING: no active virtualenv; installing into system site-packages." >&2
fi

cd "${WS}/src/kiss-slam"
make editable

echo "KISS-SLAM installed in editable mode."
echo "Run: kiss_slam_pipeline --help"
