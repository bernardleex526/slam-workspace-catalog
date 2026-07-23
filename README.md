# SLAM Algorithm Workspace Catalog

用于按需获取、隔离编译和复现开源 SLAM、定位与导航项目的管理仓库。

## 目录

- [`ros1/`](ros1/)：ROS 1 Noetic 项目，包括 FAST-LIO2、FAST-LIVO2、LIO-SAM、
  Point-LIO、R3LIVE、LVI-SAM 等。
- [`ros2/`](ros2/)：官方或上游明确支持 ROS 2 的项目，包括 GLIM、KISS-ICP、
  MOLA、DLIO ROS 2、RTAB-Map、SLAM Toolbox、robot_localization、Nav2 与 Autoware。

每个算法都使用独立 workspace，通过 `.repos` 清单按需下载，避免不同算法之间的
GTSAM、Ceres、Sophus、PCL、OpenCV及消息包版本冲突。

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

## 重要说明

- 本仓库保存管理脚本和源码清单，不复制第三方项目源码。
- rosbag、MCAP、PCD、PLY和地图数据不应提交到Git。
- 首次跑通后应使用 `scripts/lock.sh` 导出精确commit。
- 每个上游项目继续受其自身许可证及商业使用条款约束。

## 扩展目录

- [`standalone/`](standalone/)：没有官方 ROS wrapper、但算法本身值得保留的项目。
  当前包含 KISS-SLAM，并提供独立的下载、构建和版本锁定脚本。

本仓库同时收录了面向不同任务的扩展：

- 完整三维建图与多会话：Voxel-SLAM、LTAOM、GLIM、MOLA；
- 三维重建：ImMesh、Gaussian-LIC、Isaac ROS Nvblox；
- 地图定位：Beluga、MOLA、NorLab ICP Mapper；
- 导航与探索：Nav2、EasyNavigation、FAR Planner、TARE Planner；
- 全覆盖作业：OpenNav Coverage；
- 规划地图后端：ROG-Map。

`catalog.tsv` 中的 `custom build`、`heavy`、`emerging` 和 `standalone`
标记表示需要遵循上游专用安装流程，不能假设通用编译脚本一定完成全部依赖安装。
