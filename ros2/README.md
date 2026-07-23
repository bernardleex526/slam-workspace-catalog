# SLAM ROS 2 Workspace Manager

面向 ROS 2 的 SLAM、定位和导航算法管理仓库。第三方源码通过 `vcstool` 按需下载，
每个算法使用独立 workspace，避免依赖冲突。

本仓库优先收录上游官方支持 ROS 2，或由原作者仓库明确提供 ROS 2 分支的项目。

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

不同项目支持的发行版并不完全一致，运行前应查看上游README。基础工具：

```bash
sudo apt update
sudo apt install -y python3-vcstool python3-colcon-common-extensions python3-rosdep
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

脚本会运行：

```bash
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
```

GLIM、MOLA、RTAB-Map与Autoware依赖较复杂。通用脚本只处理ROS包声明的依赖；
CUDA、指定GTSAM版本或上游`.repos`依赖仍需按照对应官方文档安装。

## 运行环境

```bash
source /opt/ros/humble/setup.bash
source workspaces/kiss_icp_ws/install/setup.bash
```

不要在同一个终端混合source Humble/Jazzy，也不要同时加载多个包含同名包的workspace。

## 版本锁定

项目验证成功后：

```bash
bash scripts/lock.sh kiss_icp
```

生成：

```text
locks/kiss_icp-exact.repos
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
