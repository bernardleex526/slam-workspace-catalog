# Standalone SLAM Workspace Manager

这里收录没有官方 ROS 包、但算法本身值得保留的 SLAM 项目。项目仍使用独立
workspace，避免 Python、CMake 和系统库依赖与 ROS workspace 相互污染。

> 本目录是 workspace catalog（清单 + 管理脚本 + lock），不是 benchmark 套件；
> 当前没有内置数据集、指标计算或评测结果。评测接口契约见仓库根
> [`README.md`](../README.md)。

## 前提

- Linux / **Ubuntu 22.04 或 24.04**（Python 3），bash；
- 安装系统包需要 root/sudo；
- Windows/macOS 本机不直接支持，请使用 WSL2 或 Docker。

```bash
sudo apt update
sudo apt install -y python3-vcstool build-essential libeigen3-dev libsuitesparse-dev \
                    python3-pip python3-venv
```

## 当前项目

- KISS-SLAM：PRBonn 发布的完整 3D LiDAR SLAM，包含 KISS-ICP、回环检测和图优化。
  上游提供 Python/C++ CLI，但没有官方 ROS1/ROS2 wrapper。

## 使用

```bash
bash scripts/list.sh
bash scripts/fetch.sh kiss_slam

python3 -m venv .venv
source .venv/bin/activate
bash scripts/build.sh kiss_slam

kiss_slam_pipeline --help
```

`fetch.sh` 是幂等的：workspace 已存在时重复执行不会重新克隆（exit 0）。
`bash scripts/fetch.sh --update kiss_slam` 会以 `vcs pull` 把已有 workspace 同步
到清单分支并更新 submodule（本地未提交修改可能冲突）。

`build.sh` 会检查 `make`、`python3`、`pip` 与 PEP 668：Ubuntu 22.04+ 的系统
Python 是 externally-managed，直接 `pip install` 会被拒绝；脚本会友好失败并提示
先创建 venv（如上）。请勿在共享环境使用 `--break-system-packages`。

如需接入 ROS2，建议另建薄封装包，只完成 `PointCloud2` 输入以及
`Odometry`、`Path`、TF 和地图输出，不要直接修改上游核心算法。

## 版本锁定

与 `ros1/`、`ros2/` 使用统一 lock 策略：

| 文件 | 是否提交 | 用途 |
|---|---|---|
| `locks/<id>-exact.repos` | **提交** | 经验证的复现基线 |
| `locks/<id>-local.repos` | 忽略 | 本地实验快照 |

```bash
bash scripts/lock.sh kiss_slam          # locks/kiss_slam-exact.repos（提交）
bash scripts/lock.sh --local kiss_slam  # locks/kiss_slam-local.repos（不提交）
```

`catalog.tsv` 的 `build_mode` 列区分 `generic` / `heavy` / `custom`；对非
`generic` 条目 `build.sh` 默认拒绝执行，确认依赖已备好后可用
`SLAM_BUILD_ALLOW_NON_GENERIC=1` 显式覆盖。
