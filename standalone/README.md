# Standalone SLAM Workspace Manager

这里收录没有官方 ROS 包、但算法本身值得保留的 SLAM 项目。项目仍使用独立
workspace，避免 Python、CMake 和系统库依赖与 ROS workspace 相互污染。

## 当前项目

- KISS-SLAM：PRBonn 发布的完整 3D LiDAR SLAM，包含 KISS-ICP、回环检测和图优化。
  上游提供 Python/C++ CLI，但没有官方 ROS1/ROS2 wrapper。

## 使用

```bash
sudo apt install -y python3-vcstool build-essential libeigen3-dev libsuitesparse-dev

bash scripts/list.sh
bash scripts/fetch.sh kiss_slam
bash scripts/build.sh kiss_slam
kiss_slam_pipeline --help
```

如需接入 ROS2，建议另建薄封装包，只完成 `PointCloud2` 输入以及
`Odometry`、`Path`、TF 和地图输出，不要直接修改上游核心算法。

首次验证完成后可锁定源码版本：

```bash
bash scripts/lock.sh kiss_slam
```
