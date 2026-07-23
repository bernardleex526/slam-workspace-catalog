#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="${1:-}"
ROS_DISTRO="${ROS_DISTRO:-humble}"
WS="${ROOT}/workspaces/${PROJECT}_ws"

if [[ -z "${PROJECT}" || ! -d "${WS}/src" ]]; then
  echo "Usage: $0 <project-id>" >&2
  echo "Run scripts/fetch.sh <project-id> first." >&2
  exit 2
fi

ROS_SETUP="/opt/ros/${ROS_DISTRO}/setup.bash"
if [[ ! -f "${ROS_SETUP}" ]]; then
  echo "ROS setup not found: ${ROS_SETUP}" >&2
  exit 1
fi

source "${ROS_SETUP}"
cd "${WS}"

rosdep install --from-paths src --ignore-src -r -y
colcon build \
  --symlink-install \
  --cmake-args -DCMAKE_BUILD_TYPE=Release

echo "Build complete. Run:"
echo "source ${ROS_SETUP}"
echo "source ${WS}/install/setup.bash"
