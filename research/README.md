# 机器人论文与代码跟踪

常用算法与跨领域选型先看 [机器人算法导航](../robotics/README.md)。本页保留具体论文与待发布代码的追踪记录。

最新检索日期：2026-11-27；旧条目保留原核验日期，新条目日期见小节。这里记录研究线索，不是评测排名；代码状态是当日快照。
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

## 世界动作模型、腿式导航与离线建图（核验 2026-11-21）

| 工作 | 论文 / 发布日期 | 核心思路 | 官方代码、许可与验证边界 |
|---|---|---|---|
| [WAM-Policy: World Action Models with On-Policy Distillation for Quadrupedal Loco-Manipulation](https://arxiv.org/abs/2611.24011)，Junlin Long 等 | 2026-11-18 v1，arXiv 预印本 | 将 LingBot-VA 适配四足机器人，先在策略分布上自蒸馏，再用强化学习专家与多教师蒸馏改进操作 | [训练及评估代码](https://github.com/AIGeeksGroup/WAM-Policy)和[作者权重](https://huggingface.co/AIGeeksGroup/WAM-Policy)分别为 Apache-2.0；[QLM-Bench 基准分支许可](https://raw.githubusercontent.com/AIGeeksGroup/WAM-Policy/qlm-bench/LICENSE)与[数据](https://huggingface.co/datasets/AIGeeksGroup/QLM-Bench)另用 CC BY-NC 4.0。[原文](https://arxiv.org/html/2611.24011v1)报告第二阶段在 10 个仿真任务得 85.0%；第一阶段 Go2 Air 真机 3 个任务共成功 7/30。真机采样 0.159 s/段，含观测编码的闭环为 0.66 s，不是同一时延。 |
| [ROAM: Bridging vision-language reasoning and learned control for legged navigation in the wild](https://arxiv.org/abs/2611.25215)，Takahiro Miki 等 | Science Robotics 2026；作者版 2026-11-18 提交 arXiv | VLM 推断语义地形风险，开放词汇分割生成像素图并融合进高程图，供学习型局部导航及运动策略使用 | [官方 MIT 仓库](https://github.com/leggedrobotics/roam)覆盖 VLM、分割与 ROS 接口，不包含实验整套学习控制系统。[原文](https://arxiv.org/html/2611.25215v1)记录云端 VLM 依赖及人工干预，不能据此推定所有地形无干预可通行。 |
| [lidar_slam v0.12.0](https://github.com/rsasaki0109/lidar_slam/releases/tag/v0.12.0)，Ryohei Sasaki 等维护 | 2026-11-17 发布，本轮补录 | RKO-LIO、离线位姿图与地图导出；新增无需 ROS 2 即可处理 rosbag2 的离线核心预览 | 仓库代码 BSD-2-Clause；[PyPI](https://pypi.org/project/lidarslam/0.12.0/)提供 Linux x86_64/aarch64 的 Python 3.10–3.13 wheel。[发布说明](https://rsasaki0109.github.io/lidar_slam/releases/v0.12.0.html)注明仍有一项精度场景未测，不据此宣称所有数据通过验证。 |
| [Vision-Language Grounded Semantic Navigation for Autonomous Mobile Robots](https://arxiv.org/abs/2611.20558)，Ravindran Vasoor Saravanan 等 | 2026-11-16 v1，arXiv 预印本 | Grounding DINO、深度定位、边界探索和 Nav2 组合；用规则解析物体级短指令，不是长程指令式 VLN | [作者仓库](https://github.com/Ravindran127/Vision-Language-Grounded-Semantic-Navigation-for-Autonomous-Mobile-Robots)可访问，但当前缺核心源码、启动及配置目录，暂作论文追踪。[原文](https://arxiv.org/html/2611.20558v1)只报告单一 Gazebo 场景，检测 3/5 目标、成功执行 2/2 条测试指令，未验证真机。 |

新增条目均为链接，不安装或运行上游算法。

## 腿式状态估计、多机配准与仿真基准（核验 2026-11-22）

| 工作 | 论文 / 发布日期 | 核心思路 | 官方代码与验证边界 |
|---|---|---|---|
| [LocoMuJoCo: A Comprehensive Imitation Learning Benchmark for Whole-Body Control](https://arxiv.org/abs/2611.26293)，Firas Al-Hafez 等 | 2026-11-19 v1，arXiv 预印本；v1.2.0 发布于 2026-11-18 | 统一 MuJoCo CPU、MJX 与 MjWarp GPU 接口开展全身控制实验；新版本加入用可微世界模型训练策略的 SuperMimicJax | [官方版本](https://github.com/robfiras/loco-mujoco/releases/tag/v1.2.0)与 [PyPI 包](https://pypi.org/project/loco-mujoco/1.2.0/)已公开；代码 MIT，AMASS、SMPL 模型等依赖需单独核验条款。未复现训练或验证真机。 |
| [I See You: Initial Multi-Robot LiDAR Registration with Mutual-Observation Checks](https://arxiv.org/abs/2611.26276)，Jonathan Lichtenfeld、Oskar von Stryk | 2026-11-19 v1；作者标注 IEEE SSRR 2026 接收终稿 | 任务前集中式静止配准，通过互相观测检查拒绝不合理的位姿候选 | [MIT 实现](https://github.com/tu-darmstadt-ros-pkg/i-see-you-registration)提供 ROS 2 Jazzy 示例。[原文](https://arxiv.org/html/2611.26276v1)在四机器人实验中报告，含错误位姿的团队配准次数相对减少 38%，不代表所有场景均适用。数据由作者另发，目录未核实下载与许可。 |
| [Proprioceptive Simultaneous Base and Terrain Elevation Estimation for Legged Robot Locomotion（SBEE）](https://arxiv.org/abs/2611.24310)，Michael Maravgakis、Stylianos Piperakis、Panos Trahanias | 2026-11-18 v1，arXiv 预印本 | 将浮动基座左不变 EKF 与足端接触高程图双向耦合，抑制垂直漂移；不提供绝对全局位置与航向 | [原文](https://arxiv.org/html/2611.24310v1)报告 296 m ANYmal-D GrandTour 数据上 ATE 为 1.062 m，较最强本体感知对照低 22.1%。正文写明接收后发布实现，现仅追踪论文。 |

链接收录不等于独立复现或部署验证。

## 地图定位、本体感知与采集质量（核验 2026-11-23）

| 工作 | 论文或更新日期 | 核心思路 | 官方代码与验证边界 |
|---|---|---|---|
| [lidar_localization_ros2](https://github.com/rsasaki0109/lidar_localization_ros2) | 2026-11-22 上游主分支修复，晚于 [v1.11.0](https://github.com/rsasaki0109/lidar_localization_ros2/releases/tag/v1.11.0) | 既有点云地图定位。在需要里程计的离线运行中，等待对应 TF 再启动，并阻止未启用里程计的运行计分 | [维护者报告](https://github.com/rsasaki0109/lidar_localization_ros2/pull/347)：Jazzy 上每例前 40 秒、15 例各运行两次，28 次正确初始化、2 次需手动、0 次错误初始化。这只验证启动，不是全程精度或实机验证。等待器取首个匹配 TF，使用时应隔离回放环境并核对实际发布者。[JEPLO 数据](https://huggingface.co/datasets/ASIG-Lab/JEPLO-Dataset)单独许可，未下载或回放。 |
| [SG-ODOM: Event-Driven Proprioceptive State Estimation with Stability-Gated Contact Updates for Legged Robots](https://arxiv.org/abs/2611.20710)，Francesco Iotti 等 | 2026-11-16 v1，arXiv 预印本 | 高频 IMU 传播，确认足端接触或超时时作运动学修正；有不变 EKF 和固定滞后平滑两个实现 | [官方源码](https://github.com/ori-drs/SG-ODOM)已公开。[原文](https://arxiv.org/html/2611.20710v1)的固定滞后模式在 7 条 ANYmal-D GrandTour 序列上的平均平移 RPE 为 0.157 m（按 1 m 路段），较机载对照低约 25%。不是全局 ATE 或其他平台的实测结果。 |
| [A Practical Proprioceptive Data Collection Utility for the Unitree Go1](https://arxiv.org/abs/2611.26146)，Jack Anders Smitterberg、Tan Chen | 2026-11-19 v1，arXiv 预印本 | 区分主机轮询与传感器实际状态更新，避免用重叠窗口随机分割高估分类性能 | [原文](https://arxiv.org/html/2611.26146v1)报告旧记录器以 500 Hz 轮询，但 51 段记录的不同状态更新速率中位数为 49.9 Hz（依据相邻状态比对，不是设备时间戳）。本轮未核实作者实现和数据，仅收录论文。 |

未安装或运行上游算法；没有更改安装清单。

## 触觉执行、ROS 2 确定性仿真与运动规划（核验 2026-11-24）

| 工作 | 论文日期 | 核心思路 | 官方代码与验证边界 |
|---|---|---|---|
| [FORTH: Grounding Tactile VLA Execution via Forward-Only Proxy-Control Pairing](https://arxiv.org/abs/2611.26744)，Junde Li 等 | 2026-11-19 v1，arXiv 预印本 | 将前向触觉表征、零阶适配与抓握力控制的各阶段目标对应到可测物理量 | [作者仓库](https://github.com/Jordanlllll/FORTH)公开 MIT 的 NumPy 提取实现与部分记录复算示例，不包含论文的完整仿真、VLA 策略或训练权重；不能将复算视为独立重跑或真机结果。 |
| [One Behavior, Out of Order: Deterministic Execution and Parallel Simulation of ROS 2 Applications](https://arxiv.org/abs/2611.26676)，Chengzi Huang 等 | 2026-11-19 v1，arXiv 预印本 | 固定回调读写时间，通过任务依赖关系并行执行，保持同一输入下的模拟输出一致 | [let_ros 源码](https://github.com/ChengziHuang/let_ros)为 Apache-2.0，文档提供 Jazzy 示例和受控节点图配置。[原文](https://arxiv.org/html/2611.26676v1)的加速来自特定负载与硬件，不据此推定普通双机或既有 bag 回放的行为或性能。 |
| [Search-Informed MPPI for Kinodynamic Motion Planning via Monte Carlo Tree Expansion（SI-MPPI）](https://arxiv.org/abs/2611.26763)，Ihab S. Mohamed、Lantao Liu | 2026-11-19 v1，arXiv 预印本 | 蒙特卡洛树扩展选择搜索方向，MPPI 并行生成符合运动约束的局部扩展 | [作者项目页](https://ihabmohamed.github.io/SI-MPPI/)标记代码待发布，先追踪论文。[原文](https://arxiv.org/html/2611.26763v1)评估的是已知静态栅格仿真，不代表动态障碍或实机性能，也不保证最短路线。 |

## 异步动作策略、人形运动与导航可靠性（核验 2026-11-25）

| 工作 / 作者 | 论文日期 / 状态 | 核心思路与适用方向 | 官方代码、许可与验证边界 |
|---|---|---|---|
| [DelayOPSD: On-Policy Self-Distillation from a Synchronous Teacher for Real-time Asynchronous Policies](https://arxiv.org/abs/2611.30534)，Hyeonjae Kim 等 | 2026-11-23 v1，arXiv 预印本 | 在异步策略自身的延时 rollout 上，用执行时刻的同步教师监督读取较早观测和待执行动作的学生；不是给任意现成策略即插即用的修补。 | [官方实现](https://github.com/present091/DelayOPSD)含训练、评估及 YAM 推理流程，代码 Apache-2.0。作者的蒸馏权重尚待发布，YAM 示范及 rollout 数据未公开。[原文](https://arxiv.org/html/2611.30534v1)的 LIBERO/Kinetix 与 YAM 结果均未在本目录复现。 |
| [Motion Mamba 2.0: Autoregressive Diffusion Mamba for Long-Horizon Humanoid Control](https://arxiv.org/abs/2611.29897)，Yue Huang 等 | 2026-11-23 v1，arXiv 预印本 | 通过分阶段扩散与循环记忆，流式生成符合语言和目标约束的人形参考运动；低层执行需要独立控制栈。 | [官方代码](https://github.com/AIGeeksGroup/MotionMamba2.0) Apache-2.0，含训练、评估与仿真桥接；[权重](https://huggingface.co/AIGeeksGroup/MotionMamba2.0)和[数据](https://huggingface.co/datasets/AIGeeksGroup/MotionMamba2.0)有独立发布入口，许可不从代码推定。作者有 Unitree G1 演示，本目录未运行仿真或验证真机。 |
| [Confidently Lost: Silent Failure and Edge Deployment of Dense Visual SLAM under Photon Starvation](https://arxiv.org/abs/2611.30173)，Shrikrishna Bhagirath Rajule、Srinath Neelamagam、Aniket Bera | 2026-11-23 v1，arXiv 预印本 | 分析 MASt3R-SLAM 低照度下的静默失效：正常帧率、高匹配置信度或没有报错，并不代表地图有效。适合作为低光回归测试参考，不是新的 SLAM 系统。 | [原文](https://arxiv.org/html/2611.30173v1)中，在六条 ETH3D 低光序列中，替换为低光适配权重后，满足跟踪工作量条件的轨迹由 1 条增至 5 条，误差仍为米级；Spot 采集后在载荷 AGX Orin 回放，不是在线导航闭环。诊断信号并非通用阈值；作者拟发布代码与权重合并方法，本轮未核实独立发布。 |
| [SuperNav-1.5: Structured Spatial Memory For Agentic Navigation Systems](https://arxiv.org/abs/2611.29912)，Jiarui Guo 等 | 2026-11-23 v1，arXiv 预印本 | 在分区占据图上写入语义记忆节点，在多会话导航中由智能体给出区域先验，再使用几何匹配重定位。 | [原文](https://arxiv.org/html/2611.29912v1)的室内 Unitree Go2 是定性演示，依赖可靠的 LiDAR/深度与里程计；未核实完整官方公开实现与许可，文中引用的 DimOS 不等同于该系统源码。 |

仅收录官方链接与研究说明，不增设安装清单。

## 四足定位、单板机感知与导航仿真（核验 2026-11-26）

| 工作 / 作者 | 论文日期 / 状态 | 核心思路与适用方向 | 官方代码、许可与验证边界 |
|---|---|---|---|
| [AirLeg: A Robust and Accurate Self-Supervised Visual-Inertial-Leg SLAM System](https://arxiv.org/abs/2611.32523)，Kuan Xu 等 | 2026-11-24 v1，arXiv 预印本 | 双窗口融合双目、IMU 与腿部里程计，仿真预训练后用未标注实机数据适配；在线估计可接 bag 回放，全局回环是可选离线阶段。 | [作者仓库](https://github.com/sair-lab/AirLeg)含 ROS 2 Humble 实现和检查点，主体 GPL-3.0，Fast-FoundationStereo 仅限非商业研究。[项目页](https://sairlab.org/AirLeg_homepage/)报告 17 条 GrandTour 测试序列的平均 ATE 0.19 m（无回环）；另用 D455、机身 IMU、关节等信号和 AGX Orin 在 Go2 上测试，约 0.6% 平均终点漂移，不是同一指标。未下载 Go2 数据、编译或回放。 |
| [Seeing to Drive on a Single Board: Attention-Free Depth for Onboard Robot Navigation（DANIEL）](https://arxiv.org/abs/2611.32718)，Itai Mizlish、Boaz Ben-Moshe | 2026-11-24 v1，arXiv 预印本 | 将 Depth Anything V2-Large 蒸馏到无注意力的轻量模型并在 Hailo-8L 上做 INT8 推理，结合相机与地面接触几何估计障碍距离。 | [源码](https://github.com/itaim18/DANIEL) MIT；[发布模型](https://huggingface.co/itaimizlish/daniel-student-depth)和数据 CC BY-NC 4.0。[原文](https://arxiv.org/html/2611.32718v1)的 27.1 FPS 是特定分辨率的深度推理速度；闭环导航主要在仿真庭院中测试，含真实计算板卡的硬件在环，不是四足自主巡检实测。 |
| [GOLD-SLAM: Gaussian-splatting Omnidirectional LiDAR-Depth SLAM](https://arxiv.org/abs/2611.32335)，Weicong Zhang 等 | 2026-11-24 v1，arXiv 预印本 | 在球面域融合全景视觉与 LiDAR/IMU，利用深度指导高斯地图的扩展和裁剪；面向三维重建，不直接生成全覆盖路线。 | [原文](https://arxiv.org/html/2611.32335v1)的 WHOLE 采集用全景双鱼眼相机与 MID360S；Orin NX 16 GB 的降配实现以 1 倍速回放 37 条序列，其中 4 条内存不足。未核实完整官方实现与 WHOLE 下载许可，仅追踪论文。 |
| [Does Research-Paper Context Improve LLM-Generated Quadruped Navigation? An Exploratory Simulation Study](https://arxiv.org/abs/2611.32381)，Barnabas Juhasz、Rolf Pfister | 2026-11-24 v1，arXiv 预印本 | 固定语言模型和步态策略，比较有无论文上下文生成的 Go2 导航控制器，检查理想运动学与物理仿真的差别。 | [原文](https://arxiv.org/html/2611.32381v1)中，一个中途封路任务下，Isaac Sim 物理仿真完成全部四趟的控制器为有上下文 2/8、无上下文 7/8。该结果限于小样本和指定任务，不代表论文上下文或增量重规划普遍有害；未核实可运行的官方代码，未做真机测试。 |

本轮只加入链接与说明，不新增安装清单。

## LiDAR 里程计、四足导航与仿真（核验 2026-11-27）

| 工作 / 作者 | 论文日期 / 状态 | 核心思路与适用方向 | 官方代码、许可与验证边界 |
|---|---|---|---|
| [xFORM: Accelerating Fixed-Lag LiDAR Odometry with Exact Factor Compression](https://arxiv.org/abs/2611.34053)，Ruogu Li、Easton R. Potokar、Michael Kaess | 2026-11-25 v1，arXiv 预印本 | 将固定匹配数据压缩成因子摘要，每对扫描以 34 个标量残差保持原目标和高斯–牛顿系统在精确算术下等价；面向固定时滞 LiDAR 里程计。 | [原文](https://arxiv.org/html/2611.34053v1)在三个数据集的 15 条完整序列上，相对 FORM 报告 CPU 版端到端快 1.1–1.4 倍、GPU 版快 2.0–4.0 倍；不等同于对其他 LIO 或 MID-360L 的比较，也不含全局回环验证。未核实 xFORM 的官方公开实现。 |
| [Autonomous Vineyard Exploration using LiDAR Sensing: A Field Evaluation on Legged-Wheeled Quadruped Robot](https://arxiv.org/abs/2611.34246)，Spencer Sweeney 等 | 2026-11-25 v1；作者标注 ICRA 2026 农业机器人研讨会 | 用 MID-360、FAST-LIO、CMU 局部导航、RANSAC 行线检测和状态机跑 Go2-W；D435i 仅用于记录。 | [原文](https://arxiv.org/html/2611.34246v1)报告单日试验中一次约 370 m 的同一行往返无需干预，但未实现可靠的自主换行；横向偏差相对估计行中心线，并非外部真值。上游为 ROS Noetic / Ubuntu 20.04；完整系统代码未核实，不能据此承诺室内覆盖或普通四足兼容。 |
| [FOCI: Trajectory Optimization on Gaussian Splats for Gaussian Robots](https://arxiv.org/abs/2611.33380)，Mario Gomez Andreu 等 | 2026-11-24 v1，arXiv 预印本；较早版本见 IROS 2025 | 在已有 3D 高斯场景中，同时考虑机器人体形与朝向做轨迹优化。 | [作者实现](https://github.com/leggedrobotics/foci)源码 MIT，公开示例需要继续核对 MA27 和外部场景授权。[原文](https://arxiv.org/html/2611.33380v1)含 ANYmal 真机演示，但明确软碰撞代价偶尔产生碰撞轨迹，不能代替独立碰撞检查。 |
| [livox_gz_sim](https://github.com/mathaimp/livox_gz_sim)，Mathai | [作者公告](https://discourse.openrobotics.org/t/livox-gz-sim-livox-mid-360-and-hap-simulation-for-gazebo-harmonic/59418) 2026-11-01，本轮补录 | 用录制的扫描图样、逐点时间和噪声模型为 Gazebo 场景生成类 Livox 数据，适合在真机前检查消息类型、点时序及仿真接口。 | 源码和引用的 Livox 扫描图样均标 MIT；上游报告在移动仿真传感器上测试 FAST-LIO 的 ROS 2 分支。不是新 SLAM 算法；不保证真实材质、遮挡或 MID-360L 一致性。 |

仅加入链接与说明，不新增安装清单。

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

- 2026-11-21：新增 WAM-Policy、ROAM、lidar_slam v0.12.0 及一项语义导航论文追踪；区分仿真、真机及代码开放范围。

- 2026-11-22：新增 LocoMuJoCo v1.2.0 和 I See You 的论文与代码入口；仅论文追踪 SBEE。

- 2026-11-23：新增 lidar_localization_ros2、SG-ODOM 官方入口与 Go1 采集质量论文，区分启动回归、离线指标与真实硬件验证。

- 2026-11-24：新增 FORTH 与 let_ros 的论文和公开代码链接；仅论文追踪 SI-MPPI。未运行上游实现或更改安装清单。

- 2026-11-25：新增 DelayOPSD、Motion Mamba 2.0 公开代码入口，并追踪 Confidently Lost 与 SuperNav-1.5；未运行上游实现。

- 2026-11-26：新增 AirLeg 和 DANIEL 的代码入口，以及 GOLD-SLAM 和 Go2 导航仿真研究；区分公开实现、论文结果和本目录的验证范围。

- 2026-11-27：新增 FOCI 与 livox_gz_sim 的代码入口，另追踪 xFORM 与 Go2-W 单行自主导航实地评估。
