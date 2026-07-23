# SLAM ROS 1 Workspace Manager

面向 ROS 1 Noetic 的 SLAM 算法管理仓库。第三方源码不直接复制进本仓库，而是通过
`vcstool` 清单按需下载；每个算法使用独立 workspace，避免 GTSAM、Ceres、Sophus、
PCL 和消息包之间的版本冲突。

## 支持范围

| 类别 | 算法 |
|---|---|
| LiDAR + IMU | FAST-LIO2、LIO-SAM、Point-LIO、Faster-LIO、DLIO、SC-LIO-SAM、PV-LIO |
| LiDAR + Camera + IMU | FAST-LIVO2、R3LIVE、R2LIVE、LVI-SAM、MINS |
| LiDAR / 图优化 | HDL Graph SLAM、Cartographer、LeGO-LOAM、A-LOAM |
| Visual + IMU | VINS-Fusion、OpenVINS、Kimera-VIO |

项目状态与传感器类型见 [`catalog.tsv`](catalog.tsv)。

## 环境

推荐：

- Ubuntu 20.04
- ROS Noetic
- `python3-vcstool`
- `python3-catkin-tools`
- `rosdep`

初始化基础工具：

```bash
sudo apt update
sudo apt install -y python3-vcstool python3-catkin-tools python3-rosdep
source /opt/ros/noetic/setup.bash
```

## 下载指定算法

```bash
bash scripts/fetch.sh fast_lio
bash scripts/fetch.sh fast_livo2
bash scripts/fetch.sh lio_sam
```

源码将分别下载到：

```text
workspaces/fast_lio_ws/src/
workspaces/fast_livo2_ws/src/
workspaces/lio_sam_ws/src/
```

查看可用算法：

```bash
bash scripts/list.sh
```

## 编译指定算法

```bash
bash scripts/build.sh fast_lio
```

编译脚本会：

1. 加载 `/opt/ros/noetic/setup.bash`；
2. 用 `rosdep` 安装 `package.xml` 中声明的依赖；
3. 使用 `catkin build` 以 Release 模式编译当前算法的独立 workspace。

部分论文仓库还要求手动安装固定版本依赖。例如：

- LIO-SAM / LVI-SAM：GTSAM；
- FAST-LIVO2：Sophus、Vikit、OpenCV；
- Cartographer：Abseil、Ceres、Protobuf 等；
- Kimera-VIO：GTSAM、OpenGV、DBoW2 等。

运行前必须阅读相应上游 README。通用脚本不会擅自替换系统库版本。

## 运行

编译完成后：

```bash
source /opt/ros/noetic/setup.bash
source workspaces/fast_lio_ws/devel/setup.bash
roslaunch fast_lio mapping_avia.launch
```

每个终端只加载一个算法 workspace；不要在同一个终端混合 source 多个可能冲突的
workspace。

## 锁定版本

首次验证成功后导出精确 commit：

```bash
bash scripts/lock.sh fast_lio
```

结果写入：

```text
locks/fast_lio-exact.repos
```

部署时优先使用锁定清单：

```bash
vcs import workspaces/fast_lio_ws/src < locks/fast_lio-exact.repos
```

## 数据与私有配置

不要提交 rosbag、PCD、PLY、数据库或密钥。推荐将数据放在仓库外：

```text
~/slam_data/
├── bags/
├── maps/
├── calibration/
└── results/
```

可将自有传感器配置放到 `configs/<algorithm>/`，但提交前检查是否包含设备序列号、
内网地址或敏感定位数据。

## 许可证

本仓库仅包含管理脚本和源码清单。每个第三方项目仍受其自身许可证约束；尤其注意
GPL、学术用途限制以及商业授权条款。

## 新增建图与导航项目

```bash
# 完整 LiDAR-Inertial SLAM、多会话和全局优化
bash scripts/fetch.sh voxel_slam
bash scripts/fetch.sh ltaom

# 实时网格及高质量视觉地图
bash scripts/fetch.sh immesh
bash scripts/fetch.sh gaussian_lic

# 三维导航、探索和规划地图
bash scripts/fetch.sh far_planner
bash scripts/fetch.sh tare_planner
bash scripts/fetch.sh rog_map
```

注意：

- Voxel-SLAM 面向 Ubuntu 20.04/ROS Noetic，并提供 Livox、HILTI、MARS 和
  MID360 数据实例。
- ImMesh 需要 CGAL、OpenGL 等额外依赖。
- Gaussian-LIC 属于重型研究环境，需要 CUDA、LibTorch、TensorRT、
  OpenCV-CUDA 和 Coco-LIC；建议使用独立系统镜像或容器。
- FAR Planner 与 TARE Planner 的仓库本身带有专用 workspace 和仿真环境，
  下载后应按上游说明编译，不保证通用 `scripts/build.sh` 直接成功。
- ROG-Map 是面向规划的三维占据地图后端，不负责估计机器人位姿。
