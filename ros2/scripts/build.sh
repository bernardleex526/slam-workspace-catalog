#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="${1:-}"
ROS_DISTRO="${ROS_DISTRO:-humble}"
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
  echo "WARNING: ${PROJECT} not found in ${CATALOG}; assuming generic build." >&2
  BUILD_MODE="generic"
fi

if [[ "${BUILD_MODE}" != "generic" && "${SLAM_BUILD_ALLOW_NON_GENERIC:-0}" != "1" ]]; then
  cat >&2 <<EOF
${PROJECT} is marked '${BUILD_MODE}' in catalog.tsv.
'${BUILD_MODE}' entries need dedicated upstream install/build flows (pinned
GTSAM/Ceres/CUDA, or the project's own setup/.repos workflow). The generic
script does NOT install those and would likely fail - read the upstream README
and the catalog notes first.
Re-run deliberately with: SLAM_BUILD_ALLOW_NON_GENERIC=1 $0 ${PROJECT}
EOF
  exit 1
fi
if [[ "${BUILD_MODE}" != "generic" ]]; then
  echo "WARNING: building '${BUILD_MODE}' entry ${PROJECT} with the generic script." >&2
fi

ROS_SETUP="/opt/ros/${ROS_DISTRO}/setup.bash"
if [[ ! -f "${ROS_SETUP}" ]]; then
  echo "ROS setup not found: ${ROS_SETUP}" >&2
  echo "Install ROS 2 ${ROS_DISTRO} first, or set ROS_DISTRO to an installed distro." >&2
  exit 1
fi

command -v rosdep >/dev/null || {
  echo "rosdep not found. Install: sudo apt install python3-rosdep" >&2
  echo "Then initialize once: sudo rosdep init && rosdep update" >&2
  exit 1
}
command -v colcon >/dev/null || {
  echo "colcon not found. Install: sudo apt install python3-colcon-common-extensions" >&2
  exit 1
}

source "${ROS_SETUP}"

cd "${WS}"
if ! rosdep install --from-paths src --ignore-src -r -y; then
  cat >&2 <<'EOF'
rosdep install failed. Common causes:
  - rosdep database not initialized: sudo rosdep init && rosdep update
  - apt rules need root: run inside an environment where sudo works
  - pip rules on Ubuntu 22.04+ hit PEP 668 (externally-managed-environment):
    prefer sudo apt install python3-<pkg>, pipx, or a project venv
EOF
  exit 1
fi

colcon build \
  --symlink-install \
  --cmake-args -DCMAKE_BUILD_TYPE=Release

echo "Build complete. Run:"
echo "source ${ROS_SETUP}"
echo "source ${WS}/install/setup.bash"
