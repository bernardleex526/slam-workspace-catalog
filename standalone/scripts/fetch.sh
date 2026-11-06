#!/usr/bin/env bash
# Shared implementation: common/scripts/fetch.sh, run against this tree's catalog.
SLAM_TREE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../../common/scripts/fetch.sh
source "${SLAM_TREE_ROOT}/../common/scripts/fetch.sh"
