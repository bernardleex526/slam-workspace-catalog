# 机器人论文与代码跟踪

常用算法与跨领域选型先看 [机器人算法导航](../robotics/README.md)。本页保留具体论文与待发布代码的追踪记录。

最新检索日期：2026-11-20；旧条目保留原核验日期，新条目日期见小节。这里记录研究线索，不是评测排名；代码状态是当日快照。
首次补录包含近期论文和较早但目录尚未收录的算法，不等于全部在本日发布。

## 稠密视觉 SLAM / 3D 基础模型（核验 2026-11-17）

| 工作 | 论文日期 / 出处 | 分类与核心思路 | 官方代码状态 | 目录处理 |
|---|---|---|---|---|
| [Map2SLAM](https://arxiv.org/abs/2611.11169) | 2026-11-08，arXiv v1 | 以冻结的 LingBot-Map 进行流式观测，并维护可被回环修正的 SLAM 状态 | [官方仓库](https://github.com/robbyant-research/Map2SLAM) 当前仅 README，说明代码将发布；[项目页](https://robbyant-research.github.io/Map2SLAM/) | 等待代码，不创建 manifest |
| [Spade-SLAM](https://arxiv.org/abs/2611.01937) | 2026-11-01，arXiv v1 | 自监督稠密视觉 SLAM，使用稀疏对应约束辅助训练 | [官方仓库](https://github.com/JulianPSchmitt/Spade-SLAM) 明确 Code coming soon | 等待代码，不创建 manifest |
| [VGGT-SLAM 2.0](https://arxiv.org/abs/2601.19887) | 2026-01-27 首发，2026-01-30 v2；上游标注 RSS 2026 | RGB 稠密 SLAM，子图对齐、回环验证与因子图优化 | [官方代码](https://github.com/MIT-SPARK/VGGT-SLAM) 已有 main.py、main_realtime.py、setup.sh；main 为 2.0 | 已加入 [standalone](../standalone/README.md)，custom 安装；未本地运行验证 |
| [MASt3R-SLAM](https://arxiv.org/abs/2412.12392) | CVPR 2025，首次目录研究补录 | 利用 3D 重建先验的稠密视觉 SLAM | [官方代码](https://github.com/rmurai0610/MASt3R-SLAM) 已发布，需 CUDA/PyTorch 和权重；[许可](https://github.com/rmurai0610/MASt3R-SLAM/blob/main/LICENSE.md) 为 CC BY-NC-SA 4.0 | 仅研究索引；属于有非商业限制的源码可用项目，不标作无此限制的开源项目 |

VGGT-SLAM 2.0 的 arXiv 摘要仍写代码将发布，但当前官方仓库已有实现和安装流程，
因此代码状态以核验到的仓库为准。其核心代码为 BSD-2-Clause，依赖和模型许可须单独检查。
本文不复制论文中的性能排名，不将作者实验等同于本仓库测得结果。

## LiDAR / LiDAR-inertial（核验 2026-11-18）

| 工作 / 作者 | 论文日期 / 出处 | 分类与核心思路 | 官方代码状态 | 目录处理 |
|---|---|---|---|---|
| [GenZ-LIO: Generalizable LiDAR-Inertial Odometry Beyond Confined--Open Boundaries](https://arxiv.org/abs/2603.16273)，Daehan Lee 等 | 2026-03-17 v1；2026-10-06 v3，arXiv 标注已被 IEEE T-FR 接收 | LiDAR+IMU 里程计；适应狭窄到开阔环境的尺度变化，结合自适应体素与混合残差 | [作者代码](https://github.com/cocel-postech/genz-lio)，GPL-2.0；官方 Noetic/Humble/Jazzy 接口 | 加入 ROS1/ROS2 `genz_lio`，均为 custom；保留完整 checkout；未编译/运行 |
| [LIN-SLAM: Lightweight LiDAR--Inertial Neural SLAM for Real-Time Onboard Navigation](https://arxiv.org/abs/2610.21199)，Shiqi Che、Yijie Liu、Shuo Wang、Wenxin Liu | 2026-10-15 v1，RA-L 投稿预印本，非已确认接收 | 几何 LIO 与神经隐式建图、全局优化结合 | 论文明确接收后发布代码；本轮未找到可确认的完整官方实现 | 仅论文追踪，不创建 manifest；作者 Go2/Jetson 实验不等于本仓库实测 |

## Visual-inertial（核验 2026-11-18）

| 工作 / 作者 | 论文日期 / 出处 | 分类与核心思路 | 官方代码状态 | 目录处理 |
|---|---|---|---|---|
| [sqrtVINS-Based 360 Visual-Inertial SLAM Systems: Hilti-Trimble SLAM Challenge 2026 Entry](https://arxiv.org/abs/2611.20568)，Jungwoo Lee、Hogyun Kim、Jiwon Choi、Jinyong Jeong、Younggun Cho | 2026-11-16 v1，挑战赛技术报告 / arXiv 预印本 | 双鱼眼+IMU，sqrtVINS 前端、视觉回环与 GTSAM 因子图后端 | 本轮未核实完整参赛系统的官方公开仓库；底层 sqrtVINS 不等于完整系统 | 仅论文追踪；[正文](https://arxiv.org/html/2611.20568v1)说明后续观测会修改历史位姿，导出轨迹是非因果的，不据此宣称在线实时性能 |

## VLN / 世界模型与动作策略（核验 2026-11-19）

| 工作 / 作者 | 日期 / 状态 | 核心贡献与适用方向 | 代码与验证边界 |
|---|---|---|---|
| [Learning and Verifying Progress: Closed-Loop Agentic Planning with Progress-Enhanced Execution for Long-Horizon Vision-Language Navigation（LeaP-VLN）](https://arxiv.org/abs/2611.20676)，Kangjie Zhou 等 | 2026-11-16 v1，arXiv 预印本 | 将进度感知执行器和独立进度验证结合，在计划、执行、验证、恢复闭环中处理长程导航误差；[原文](https://arxiv.org/html/2611.20676v1) | 本轮未核实完整官方公开实现与代码许可，先作论文链接；作者仿真/真机结果未在本目录复现 |
| [Progress Predicts Policy（PPP）](https://arxiv.org/abs/2611.22491)，Licheng Zhong、Gim Hee Lee | 2026-11-17 v1，arXiv 预印本 | 将语言条件进度场与共享世界模型组合，用梯度读取连续动作、有限差分读取离散动作，研究不依赖独立动作头的操作策略；[原文](https://arxiv.org/html/2611.22491v1) | 本轮未核实完整官方公开代码与许可；进度梯度没有稳定性或物理进展保证，不能将论文结果推断为安全控制保证 |

本轮以论文提交日期为准，不将聚合站的收录日期当作发表日期。以上仅收录研究链接，不创建 manifest。

## 多传感器里程计与建图（核验 2026-11-20）

| 工作 | 论文日期 / 出处 | 核心思路 | 官方代码状态 | 验证边界 |
|---|---|---|---|---|
| [SE(3)-LIVOM: Adaptive Multi-LiDAR-Inertial-Visual Odometry and Mapping](https://arxiv.org/abs/2611.22047)，Gunhee Shin 等 | 2026-11-17 v1，挑战赛技术报告 / arXiv 预印本 | 多 LiDAR、相机与 IMU 融合，自适应降采样、子图平面优化及增量位姿图 | [官方代码](https://github.com/url-kaist/se3-livom-comfort)已公开，GPL-2.0，有 ROS 1 Noetic Docker 回放流程 | IROS 2026 COMFORT 挑战赛冠军；[论文](https://arxiv.org/html/2611.22047v1)报告 GrandTour 6 个测试场景平均 ATE 为 1.40 cm。CON-4 有 10 帧扫描超过 100 ms、峰值内存 16.7 GB；不能据此保证其他硬件实时。 |
| [Pelorus: Resource-Aware Lidar-Inertial Odometry](https://arxiv.org/abs/2611.22850)，Charlotte Sieh、Mario Porrmann | 2026-11-17 v1，arXiv 预印本 | 固定容量多分辨率局部地图、按相关性淘汰体素与等变状态估计；含 CUDA、Vulkan、Metal 后端 | [官方代码](https://codeberg.org/stelzo/pelorus)已公开，MIT 或 Apache-2.0；[作者 ROS 2 文档](https://pelorus.steado.tech/docs/ros/) | [论文](https://arxiv.org/html/2611.22850v1)表 II：Orin NX 单个 HeLiPR town02:ouster 序列，CUDA 加 4 个 CPU 线程处理 100% 扫描，p95 处理时长 78.1 ms、p95 端到端延迟 173 ms。LIO 不等于带回环的全局 SLAM。 |

## 语义导航 / ObjectNav（核验 2026-11-20）

| 工作 | 论文日期 / 出处 | 核心思路 | 官方代码与验证边界 |
|---|---|---|---|
| [Sim-to-Real Room-Mediated Object-Goal Navigation with ROS 2 and Nav2](https://arxiv.org/abs/2611.19720)，Matthew Chua、Adam Scicluna、Gavin Paul | 2026-11-15 v1；作者标注 ACRA 2026 已接收 | 既有 RPV 策略的实机迁移：房间语义对探索边界打分并向 Nav2 提交导航目标，不输出电机指令 | [ROS 2 桥接](https://github.com/Matthew-K-Chua/rpv-ros2-bridge)与[策略](https://github.com/Matthew-K-Chua/rpv-sim2real-policy)已公开，源码 MIT；SAM 3/YOLOE 等外部权重另核。[论文](https://arxiv.org/html/2611.19720v1)报告 Spot 在单一场地 30/66 次成功，TurtleBot 4 是独立迁移演示。默认启动与论文实验的感知配置不同。 |

## VLA / 潜空间世界模型（核验 2026-11-20）

| 工作 | 论文日期 / 出处 | 核心思路 | 官方代码状态与边界 |
|---|---|---|---|
| [Z-sight: Unifying Vision-Language-Action and Latent World Modeling](https://arxiv.org/abs/2611.24940)，Junjie Ye 等 | 2026-11-18 v1，arXiv 预印本 | 在 VLM 自身视觉表示空间共同预测未来视觉 token 和连续动作，不生成像素视频 | [作者项目页](https://junjieye.com/Z-sight/)提供演示，所指代码链接在本轮核验返回 404，代码、权重和许可未核实，仅追踪[论文](https://arxiv.org/html/2611.24940v1)；作者真机结果未复现。 |

本轮均为链接收录，不新增 manifest，不构建或运行上游算法。

## 后续分类与纳入标准

- 扩展方向：VLN、VLA、世界模型、导航规划、定位、运动控制；默认只加官方链接及说明，保留代码/模型/数据许可边界。
- SLAM 方向：LiDAR / LiDAR-inertial、visual / visual-inertial、RGB-D、multi-sensor、
  dense / neural / Gaussian mapping、multi-agent、loop closure / relocalization。
  无已核实条目的方向暂不创建空表，也不把视觉论文误归入 LiDAR 类。
- 每项至少保留论文或官方来源、传感器/任务类别、论文日期、官方代码链接与发布状态、核验日期。
- 有正式源码、可识别分支和安装说明后，再按官方 ROS1 / ROS2 支持或 standalone 分类。
  新 workspace 项目需对应 manifest，并注明依赖、构建模式和许可限制。
- 仅公告、占位仓库、许可不明和社区移植先追踪；不宣称可复现、不伪造 exact lock。
- 按论文标识和官方仓库去重；版本更新修改原条目，不重复加入。
- 每轮修改后运行 `bash tests/smoke.sh`；它只验证目录和管理脚本，不编译或运行上游算法。

## 更新记录

- 2026-11-17：首次建立研究索引；记录 2 篇 2026 年 11 月论文的待发布代码状态，
  补录 VGGT-SLAM 2.0 工作区条目，并单独注明 MASt3R-SLAM 的非商业许可限制。

- 2026-11-18：新增 11 月 16 日的 360 视觉惯性技术报告；补录 GenZ-LIO 和 LIN-SLAM。GenZ-LIO 同步加入 ROS1/ROS2 清单，不将较早工作称为今日新发布。

- 2026-11-19：新增 LeaP-VLN 与 PPP 研究链接；在机器人导航中补录 LeRobot v0.7.0。保留原条目，不把所有领域强行凑成每日新增。

- 2026-11-20：新增 SE(3)-LIVOM、Pelorus、RPV ObjectNav 公开代码及论文入口；新增 Z-sight 论文追踪（代码未核实）。
