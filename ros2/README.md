# SLAM ROS 2 Workspace Manager

面向 ROS 2 的 SLAM、定位和导航算法管理仓库。第三方源码通过 `vcstool` 按需下载，
每个算法使用独立 workspace，避免依赖冲突。

本仓库优先收录上游官方支持 ROS 2，或由原作者仓库明确提供 ROS 2 分支的项目。

> 本目录是 workspace catalog（清单 + 管理脚本 + lock），不是 benchmark 套件；
> 当前没有内置数据集、指标计算或评测结果。评测接口契约见仓库根
> [`README.md`](../README.md)。

## 支持范围

| 类别 | 项目 |
|---|---|
| LiDAR | KISS-ICP |
| LiDAR + IMU | GLIM、DLIO ROS 2、MOLA |
| RGB-D / Stereo / LiDAR | RTAB-Map ROS 2 |
| 2D建图与定位 | SLAM Toolbox |
| 状态融合 | robot_localization |
| 导航 | Navigation2 |
| 自动驾驶 | Autoware |

状态和用途见 [`catalog.tsv`](catalog.tsv)。

## 推荐环境

- Ubuntu 22.04 + ROS 2 Humble，或
- Ubuntu 24.04 + ROS 2 Jazzy

前提：

- Linux / Ubuntu + bash；安装系统包与 `rosdep install -y` 需要 root/sudo；
- Windows/macOS 本机不直接支持，请使用 WSL2 或 Docker。

不同项目支持的发行版并不完全一致，运行前应查看上游README。基础工具：

```bash
sudo apt update
sudo apt install -y python3-vcstool python3-colcon-common-extensions python3-rosdep
sudo rosdep init && rosdep update
source /opt/ros/humble/setup.bash
```

## 下载

查看项目：

```bash
bash scripts/list.sh
```

按需下载：

```bash
bash scripts/fetch.sh kiss_icp
bash scripts/fetch.sh glim
bash scripts/fetch.sh mola
bash scripts/fetch.sh nav2
```

源码分别进入：

```text
workspaces/kiss_icp_ws/src/
workspaces/glim_ws/src/
workspaces/mola_ws/src/
workspaces/nav2_ws/src/
```

`fetch.sh` 是幂等的：workspace 已存在时重复执行不会重新克隆（exit 0）。
`bash scripts/fetch.sh --update kiss_icp` 会以 `vcs pull` 把已有 workspace 同步到
清单分支并更新 submodule（本地未提交修改可能冲突）。

## 编译

默认使用当前环境的 `ROS_DISTRO`；未设置时使用 Humble：

```bash
bash scripts/build.sh kiss_icp
bash scripts/build.sh slam_toolbox
```

也可以指定发行版：

```bash
ROS_DISTRO=jazzy bash scripts/build.sh kiss_icp
```

脚本会检查 `/opt/ros/<distro>/setup.bash`、`rosdep`、`colcon` 是否可用，缺失时
给出安装命令并友好失败；随后运行：

```bash
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
```

`rosdep` 失败时请检查：

- 是否初始化过：`sudo rosdep init && rosdep update`；
- apt 规则需要 root/sudo；
- pip 规则在 Ubuntu 22.04+ 会触发 PEP 668（externally-managed-environment）：
  优先 `sudo apt install python3-<pkg>`、pipx 或项目 venv，不要盲目使用
  `pip install --break-system-packages`。

`catalog.tsv` 的 `build_mode` 列区分三类条目：

- `generic`：`build.sh` 是推荐路径；
- `heavy`：需要先按上游文档手工安装特定版本依赖；
- `custom`：需要遵循上游专用构建/环境流程（如 Autoware 的 setup 与 `.repos`
  工作流、Isaac ROS Nvblox 的 NVIDIA 环境）。

对 `heavy` / `custom` 条目，`build.sh` 默认**拒绝**执行；确认环境已备好后可显式
覆盖：

```bash
SLAM_BUILD_ALLOW_NON_GENERIC=1 bash scripts/build.sh autoware
```

GLIM、MOLA、RTAB-Map 依赖较复杂。通用脚本只处理ROS包声明的依赖；CUDA、指定
GTSAM版本或上游`.repos`依赖仍需按照对应官方文档安装。

## 运行环境

```bash
source /opt/ros/humble/setup.bash
source workspaces/kiss_icp_ws/install/setup.bash
```

不要在同一个终端混合source Humble/Jazzy，也不要同时加载多个包含同名包的workspace。

## 版本锁定

三个目录（`ros1/`、`ros2/`、`standalone/`）使用统一 lock 策略：

| 文件 | 是否提交 | 用途 |
|---|---|---|
| `locks/<id>-exact.repos` | **提交** | 经验证的复现基线 |
| `locks/<id>-local.repos` | 忽略 | 本地实验快照 |

```bash
bash scripts/lock.sh kiss_icp          # locks/kiss_icp-exact.repos（提交）
bash scripts/lock.sh --local kiss_icp  # locks/kiss_icp-local.repos（不提交）
```

## Nav2集成原则

保持 Navigation2 上游源码不变，在自己的机器人仓库中维护：

```text
robot_description/
robot_bringup/
robot_navigation/
robot_nav_plugins/
robot_bt/
```

优先通过参数、Planner/Controller/Costmap插件和Behavior Tree扩展，避免直接修改
Nav2核心。

## 数据

rosbag2、MCAP、PCD和地图不要提交到Git：

```text
~/slam_data/
├── bags/
├── maps/
├── calibration/
└── results/
```

## 许可证

本仓库仅包含管理脚本和源码清单。第三方项目仍受各自许可证及商业使用条款约束。

## 新增定位、建图与导航项目

```bash
# 地图构建和已有点云地图定位
bash scripts/fetch.sh norlab_icp_mapper

# 新一代 MCL/AMCL 兼容定位
bash scripts/fetch.sh beluga

# GPU 三维重建和 Nav2 代价地图
bash scripts/fetch.sh isaac_ros_nvblox

# 新型 ROS2 导航框架和 Nav2 全覆盖扩展
bash scripts/fetch.sh easynavigation
bash scripts/fetch.sh opennav_coverage
```

注意：

- NorLab ICP Mapper 可通过参数关闭建图并进入 localization-only 模式，也支持
  加载已有地图和外部初始位姿。
- Beluga 与 `nav2_amcl` 接口兼容度较高，包含实例、benchmark 和系统测试。
- Isaac ROS Nvblox 需要 NVIDIA GPU、CUDA 和匹配的 Isaac ROS 环境（catalog 标记
  `custom`）；它需要外部位姿输入，本身不是 SLAM。
- EasyNavigation 是仍在发展的 Nav2 替代框架。生产项目仍建议以 Nav2 为主线，
  EasyNav 作为 GridMap、OctoMap、点云或混合地图导航预研。
- OpenNav Coverage 是 Nav2 扩展，适用于清扫、割草、喷洒、巡检和农田全覆盖，
  不是 Nav2 的替代品。
