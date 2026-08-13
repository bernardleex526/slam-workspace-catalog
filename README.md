# SLAM Algorithm Workspace Catalog

按需获取、隔离编译、可复现地管理开源 SLAM、定位与导航项目的 **workspace catalog**
仓库。

> 说明：本仓库是一个源码工作区目录（catalog + manifests + 管理脚本），
> **不是** 基准评测套件。当前没有内置 rosbag/MCAP 数据集、指标计算或结果报告，
> 也**不宣称**任何算法已在本仓库完成 bag/metrics benchmark。
> 未来评测框架的接口契约见 [评测接口契约（规划）](#评测接口契约规划)。

## 目录

- [`ros1/`](ros1/)：ROS 1 Noetic 项目，包括 FAST-LIO2、FAST-LIVO2、LIO-SAM、
  Point-LIO、R3LIVE、LVI-SAM 等。
- [`ros2/`](ros2/)：官方或上游明确支持 ROS 2 的项目，包括 GLIM、KISS-ICP、
  MOLA、DLIO ROS 2、RTAB-Map、SLAM Toolbox、robot_localization、Nav2 与 Autoware。
- [`standalone/`](standalone/)：没有官方 ROS wrapper、但算法本身值得保留的项目
  （当前为 KISS-SLAM）。

每个算法都使用独立 workspace，通过 `.repos` 清单按需下载，避免不同算法之间的
GTSAM、Ceres、Sophus、PCL、OpenCV及消息包版本冲突。

## 前提条件

脚本面向 **Linux / Ubuntu** 上的 **bash**（4.x）：

| 目录 | 系统要求 |
|---|---|
| `ros1/` | Ubuntu 20.04 + ROS Noetic |
| `ros2/` | Ubuntu 22.04 + ROS 2 Humble，或 Ubuntu 24.04 + ROS 2 Jazzy |
| `standalone/` | Ubuntu 22.04/24.04（Python 3） |

- 安装系统包需要 root：`sudo apt install ...`；`rosdep install -y` 解析到 apt
  规则时同样需要 sudo。请在有 sudo 权限的账户下操作。
- Windows/macOS 本机不直接支持：请使用 WSL2 或 Docker 容器运行上述命令。
- 本仓库不内置第三方源码，源码由你在本机按需 `fetch.sh` 获取。

## 快速开始

ROS 1：

```bash
cd ros1
bash scripts/list.sh
bash scripts/fetch.sh fast_lio
bash scripts/build.sh fast_lio
```

ROS 2：

```bash
cd ros2
bash scripts/list.sh
bash scripts/fetch.sh kiss_icp
bash scripts/build.sh kiss_icp
```

详细的环境、依赖、版本锁定和运行说明分别见：

- [ROS 1 使用说明](ros1/README.md)
- [ROS 2 使用说明](ros2/README.md)
- [Standalone 使用说明](standalone/README.md)

## fetch 幂等行为

`scripts/fetch.sh <id>` 是幂等的：

- 首次执行：按 `manifests/<id>.repos` 克隆到 `workspaces/<id>_ws/src/` 并初始化
  submodule；
- 再次执行：workspace 已存在时**不做任何事**（exit 0），并提示如何继续；
- `scripts/fetch.sh --update <id>`：对已有 workspace 执行 `vcs pull` 同步到清单
  指定的分支，随后更新 submodule。本地未提交修改可能产生冲突，属预期行为。

## 版本锁定（lock 策略）

三个目录（`ros1/`、`ros2/`、`standalone/`）采用**统一**策略：

| 文件 | 是否提交 | 用途 |
|---|---|---|
| `locks/<id>-exact.repos` | **提交** | 经验证的复现基线，用精确 commit 固定 |
| `locks/<id>-local.repos` | 忽略（gitignore） | 个人机器/实验分支的本地快照 |

首次跑通后：

```bash
bash scripts/lock.sh <id>            # 写 locks/<id>-exact.repos（提交）
bash scripts/lock.sh --local <id>    # 写 locks/<id>-local.repos（本地，不提交）
```

部署/复现时优先使用锁定清单：

```bash
vcs import workspaces/<id>_ws/src < locks/<id>-exact.repos
```

## build_mode 约定

`catalog.tsv` 的 `build_mode` 列统一取 `generic`、`heavy` 或 `custom`：

- `generic`：`scripts/build.sh` 是推荐构建路径；
- `heavy`：需要先按上游文档手动安装大量外部依赖（特定版本 GTSAM/Ceres/CUDA
  等），通用脚本默认**拒绝**构建以免误导；
- `custom`：上游自带专用构建/环境流程（Docker、自建 workspace、NVIDIA 环境等），
  通用脚本不适用，默认**拒绝**构建。

对 heavy/custom 条目，确认已按上游说明准备好环境后可显式覆盖：

```bash
SLAM_BUILD_ALLOW_NON_GENERIC=1 bash scripts/build.sh <id>
```

## 评测接口契约（规划）

当前仓库只保证三件事：**可获取、可编译、可复现**。评测功能不在当前范围内，
以下仅为未来扩展预留的最小接口契约：

```text
~/slam_data/
├── bags/            # 输入：<dataset>-<sequence>.bag|.mcap（不提交到 Git）
├── maps/            # 输入/输出：参考地图、生成地图
├── calibration/     # 传感器外参/内参
└── results/         # 输出：每 (算法, 数据集) 一个目录
    └── <id>/<dataset>/
        ├── traj_est.txt     # TUM 格式估计轨迹（时间 tx ty tz qx qy qz qw）
        ├── map.pcd|map.ply  # 生成地图
        └── metrics.json     # 指标（ATE/RPE/召回率等字段，TBD）
```

拟议统一入口（待评测框架落地后启用；当前**不存在** `eval.sh`）：

```bash
bash eval.sh <id> <dataset> [--output ~/slam_data/results]
```

边界说明：

- 评测实现（指标计算、可视化、报告）计划作为独立组件/仓库接入，不在本仓库内
  实现；
- 复现基线固定来自 `locks/<id>-exact.repos`；
- 在评测框架落地前，本仓库**不宣称**任何 bag/metrics benchmark 结果。

## 测试与 CI

轻量 smoke 测试（不联网、不编译、不下载源码）：

```bash
bash tests/smoke.sh
```

覆盖：所有脚本 `bash -n` 语法检查、catalog 与 manifest 一致性、非法 id 行为、
lock 文件命名/ignore 策略。CI 见 [`.github/workflows/ci.yml`](.github/workflows/ci.yml)。

## 重要说明

- 本仓库保存管理脚本和源码清单，不复制第三方项目源码。
- rosbag、MCAP、PCD、PLY和地图数据不应提交到Git。
- 每个上游项目继续受其自身许可证及商业使用条款约束。

## 收录扩展

本仓库同时收录了面向不同任务的扩展：

- 完整三维建图与多会话：Voxel-SLAM、LTAOM、GLIM、MOLA；
- 三维重建：ImMesh、Gaussian-LIC、Isaac ROS Nvblox；
- 地图定位：Beluga、MOLA、NorLab ICP Mapper；
- 导航与探索：Nav2、EasyNavigation、FAR Planner、TARE Planner；
- 全覆盖作业：OpenNav Coverage；
- 规划地图后端：ROG-Map。

`catalog.tsv` 中的 `heavy`、`custom` 标记表示需要遵循上游专用安装流程，不能假设
通用编译脚本一定完成全部依赖安装。
