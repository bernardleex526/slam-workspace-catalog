#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ALGORITHM="${1:-}"
ROS_DISTRO="${ROS_DISTRO:-noetic}"
WS="${ROOT}/workspaces/${ALGORITHM}_ws"

if [[ -z "${ALGORITHM}" || ! -d "${WS}/src" ]]; then
  echo "Usage: $0 <algorithm-id>" >&2
  echo "Run scripts/fetch.sh <algorithm-id> first." >&2
  exit 2
fi

ROS_SETUP="/opt/ros/${ROS_DISTRO}/setup.bash"
if [[ ! -f "${ROS_SETUP}" ]]; then
  echo "ROS setup not found: ${ROS_SETUP}" >&2
  exit 1
fi

command -v catkin >/dev/null || {
  echo "catkin_tools not found. Install: sudo apt install python3-catkin-tools" >&2
  exit 1
}

source "${ROS_SETUP}"

cd "${WS}"
rosdep install --from-paths src --ignore-src -r -y
catkin config --extend "/opt/ros/${ROS_DISTRO}" --cmake-args -DCMAKE_BUILD_TYPE=Release
catkin build

echo "Build complete. Run:"
echo "source ${ROS_SETUP}"
echo "source ${WS}/devel/setup.bash"
