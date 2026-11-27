# Robotics Algorithm Catalog · SLAM Workspaces

机器人算法选型与研究导航，覆盖 **VLN、世界模型、建图、导航、定位、VLA 与运动控制**。
同时保留按需获取、隔离编译的 SLAM **workspace catalog**，不复制第三方源码。

👉 **先看 [机器人算法分类导航](robotics/README.md)**：46 个选型入口，说明用途、许可、接入前提与限制。
新领域默认以链接和说明收录，不要求下载完整仓库。原 ROS 1 / ROS 2 / standalone 脚本用法不变。

> 说明：本仓库包含算法链接导航，以及源码工作区目录（catalog + manifests + 管理脚本），
> **不是** 基准评测套件。当前没有内置 rosbag/MCAP 数据集、指标计算或结果报告，
> 也**不宣称**任何算法已在本仓库完成 bag/metrics benchmark。
> 未来评测框架的接口契约见 [评测接口契约（规划）](#评测接口契约规划)。

## 最新维护

- 2026-11-27：新增 FOCI 高斯地图轨迹优化的代码入口，补录 livox_gz_sim 仿真插件；另追踪 xFORM LiDAR 里程计和 Go2-W 葡萄园导航实地评估。仅更新链接和说明，见 [研究追踪](research/README.md)。

- 2026-11-26：新增 AirLeg（四足视觉惯性与腿里程计）和 DANIEL（单板机视觉深度与导航）官方代码入口；另追踪 GOLD-SLAM 与 Go2 导航仿真方法研究。只更新链接和说明，见 [研究追踪](research/README.md)。

- 2026-11-25：新增 DelayOPSD（异步 VLA）和 Motion Mamba 2.0（人形运动生成）官方代码入口；研究索引新增低光视觉 SLAM 失效分析与 SuperNav-1.5 空间记忆论文。仅更新链接和说明，见 [研究追踪](research/README.md)。

- 2026-11-24：新增 FORTH 触觉抓握执行核心与 let_ros 确定性仿真工具的官方入口；另追踪 SI-MPPI 规划论文。仅新增链接和说明，见 [研究追踪](research/README.md)。

- 2026-11-23：新增 lidar_localization_ros2 和 SG-ODOM 两个定位与状态估计入口；另追踪 Go1 采集质量论文。仅更新链接与说明，见 [研究追踪](research/README.md)。

- 2026-11-22：新增 LocoMuJoCo v1.2.0 与 I See You 官方入口，追踪 SBEE 预印本，并补充现有 [MOLA 工作区](ros2/README.md) 的上游 3.6.0 发布说明。未变更安装清单。

- 2026-11-21：新增 WAM-Policy、ROAM 和 lidar_slam v0.12.0 的官方入口，另追踪一项语义导航仿真研究。仅更新链接与说明，见 [研究追踪](research/README.md)。

- 2026-11-20：新增 SE(3)-LIVOM、Pelorus 和 RPV 实机 ObjectNav 的官方代码入口；研究索引另追踪 Z-sight（代码未核实）。均未新增安装清单，详见 [研究追踪](research/README.md)。

- 2026-11-19：补录 LeRobot v0.7.0；研究索引新增 LeaP-VLN 与 Progress Predicts Policy 两篇近期预印本。代码未核实的论文不当作可运行开源算法。详见 [研究追踪](research/README.md)。

## 目录

- [`robotics/`](robotics/README.md)：跨领域机器人算法链接导航与选型说明，含成熟基线和近期具身模型。

- [`ros1/`](ros1/)：ROS 1 Noetic 项目，包括 FAST-LIO2、FAST-LIVO2、LIO-SAM、
  Point-LIO、R3LIVE、LVI-SAM 等。
- [`ros2/`](ros2/)：官方或上游明确支持 ROS 2 的项目，包括 GLIM、KISS-ICP、
  MOLA、DLIO ROS 2、RTAB-Map、SLAM Toolbox、robot_localization、Nav2 与 Autoware。
- [`standalone/`](standalone/)：没有官方 ROS wrapper、但算法本身值得保留的项目
  （包括 KISS-SLAM、VGGT-SLAM 2.0；后者须按上游流程安装）。
- [`research/`](research/)：按研究方向整理的新论文、代码发布状态和来源；未发布代码
  的论文不进入 workspace 清单。
- [`common/scripts/`](common/scripts/)：三个目录共用的 `catalog.sh` / `list.sh` 以及
  ros2、standalone 共用的 `fetch.sh` / `lock.sh` 实现；各目录 `scripts/` 下保留同名薄封装，
  命令用法不变。

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

## 论文与代码跟踪

首次检索：2026-11-17。研究索引见 [research/README.md](research/README.md)。
2026-11-17 加入 VGGT-SLAM 2.0 的 standalone 清单及 manifest；追踪 Map2SLAM、Spade-SLAM
两篇近期论文的代码发布状态，并记录 MASt3R-SLAM 的非商业许可限制。
这是首次补录，不代表这些项目均在今日发表，也不代表穷尽最新工作。

维护时以论文、作者项目页和官方代码库为依据，区分论文日期、代码状态与核验日期。
新增可获取源码项目必须同步更新 catalog、manifest 和说明；代码尚未发布、许可不明确
或仅有社区移植的候选先进入研究索引。无新信息时不重复添加，不以每日数量为目标。
目录检查不等于算法运行验证；性能结论须注明来自作者，不能写成本仓库评测结果。

### 2026-11-18 更新

- 新增 GenZ-LIO 的 ROS1/ROS2 目录与 manifest（官方 Noetic/Humble/Jazzy，GPL-2.0，
  custom 构建）；保留嵌套 ROS 包所需的完整仓库，说明可选 Livox 驱动的隔离要求。
- 研究索引新增 2026-11-16 的 sqrtVINS-Based 360 挑战赛技术报告，并补录 LIN-SLAM
  待发布代码状态。二者未核实完整官方实现，不创建工作区清单。
- GenZ-LIO 与 LIN-SLAM 是此前工作的补录，不是今日新发表；本轮只做目录检查，
  未编译、运行或独立评测上游算法。
