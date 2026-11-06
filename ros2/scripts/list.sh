#!/usr/bin/env bash
# Shared implementation: common/scripts/list.sh, run against this tree's catalog.
SLAM_TREE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../../common/scripts/list.sh
source "${SLAM_TREE_ROOT}/../common/scripts/list.sh"
