# 机器人算法导航：从感知到行动

核验日期：**2026-11-18**。这是以官方链接为主的选型入口，不下载、不复制第三方仓库，也不会自动安装模型或依赖。

来源与版本依据见 [核验快照](SOURCES.md)。

## 如何使用这份目录

- **常用 / 热门不是性能排名**：结合官方工程生态、代表性研究路线、公开实现和社区关注度选取。既保留成熟基线，也收录近期具身模型；不宣称覆盖全部“最火”项目。
- 每行的项目名称跳转到官方仓库，仓库 README 提供论文、安装、模型和示例入口。先看任务与输入，再看接入限制，最后按上游指定版本运行。
- **代码公开 ≠ 权重、数据可自由商用**。许可是本次核验快照；商业使用、分发和训练数据须逐项检查上游 LICENSE、模型卡和数据条款。
- 本仓库只核验来源、目录和文档，**没有编译、训练、运行或评测下列上游项目**。论文中的成功率、速度和真机结果都是作者报告，不是本目录的验证。
- 本页是 **link-only** 导航，不要求 `.repos` manifest；既有 [ROS 1](../ros1/) / [ROS 2](../ros2/) / [standalone](../standalone/) 工作区保持不变。已存在的项目这里只做跨领域导览，不重复复制源码。

## 快速选型

| 你要做什么 | 建议先看的入口 | 不能省略的工作 |
|---|---|---|
| 机器狗离线 LiDAR/IMU 建图 | FAST-LIO2、FAST-LIVO2、GLIM | 时间同步、标定、数据格式及漂移评估 |
| ROS 2 地图定位与避障 | SLAM Toolbox / RTAB-Map + Nav2 + robot_localization | TF、地图坐标、底盘接口与安全停车 |
| 根据自然语言找房间/目标 | NaVILA、StreamVLN、InternNav | 语义决策与局部避障分层，平台适配 |
| 机械臂视觉语言操作 | OpenVLA、openpi、GR00T | 动作空间、相机、控制频率、数据微调 |
| 学习预测环境与规划 | DreamerV3、V-JEPA 2-AC、Cosmos | 区分潜在动力学与视频生成，验证预测误差 |
| 四足/人形行走与动作模仿 | Unitree RL Gym、OCS2、ASAP | 先仿真，核查关节限位、力矩与故障保护 |

## 分类目录

- [建图与 SLAM](#建图与-slam)
- [定位与状态估计](#定位与状态估计)
- [导航与运动规划](#导航与运动规划)
- [VLN：视觉语言导航](#vln视觉语言导航)
- [VLA：视觉语言动作](#vla视觉语言动作)
- [世界模型](#世界模型)
- [运动控制与运动学习](#运动控制与运动学习)
- [配套仿真与训练平台](#配套仿真与训练平台)

## 建图与 SLAM

建图生成环境表示，SLAM 同时估计位姿与地图；LIO/VIO 里程计不一定含全局回环。

| 项目 / 官方入口 | 适用任务与为什么看它 | 许可快照 | 使用前提与限制 |
|---|---|---|---|
| [FAST-LIO2](https://github.com/hku-mars/FAST_LIO) | LiDAR + IMU；迭代滤波式 LIO，适合作为实时里程计/建图基线。 | GPL-2.0 | 已有工作区；不能把里程计误当作带全局回环的完整 SLAM，检查雷达点时间和 IMU。 |
| [FAST-LIVO2](https://github.com/hku-mars/FAST-LIVO2) | LiDAR + IMU + 相机，直接法多传感器融合；研究纹理与几何互补。 | GPL-2.0 | 已有工作区；需要更严格的相机/雷达/IMU 标定和同步。 |
| [ORB-SLAM3](https://github.com/UZ-SLAMLab/ORB_SLAM3) | 单目/双目/RGB-D 与视觉惯性多地图 SLAM；经典视觉基线。 | GPL-3.0 | 查看官方数据集示例；视觉退化、初始化及外部 ROS wrapper 需单独核验。 |
| [GLIM](https://github.com/koide3/glim) | 点云因子图定位建图，可选 GPU 加速；适合高质量 3D 地图工作流。 | MIT | 已有 ROS 2 工作区；GTSAM/gtsam_points、CUDA 与扩展模块需按版本匹配。 |
| [RTAB-Map](https://github.com/introlab/rtabmap) | RGB-D/双目/LiDAR 图优化 SLAM，多会话与定位工作流。 | BSD（见 LICENSE） | ROS 接口在 rtabmap_ros；不要把核心库安装等同于完整机器人集成。 |
| [SLAM Toolbox](https://github.com/SteveMacenski/slam_toolbox) | 2D LiDAR 位姿图 SLAM、继续建图及定位；ROS 2 地面导航入口。 | LGPL-2.1 | 已有工作区；不是 3D SLAM，长期建图模式的资源和实验性限制看上游。 |

## 定位与状态估计

区分连续状态融合、已有地图上的定位、视觉全局重定位。

| 项目 / 官方入口 | 适用任务与为什么看它 | 许可快照 | 使用前提与限制 |
|---|---|---|---|
| [robot_localization](https://github.com/cra-ros-pkg/robot_localization) | EKF/UKF 融合轮速、IMU、GNSS/里程计；估计机器人状态。 | BSD（见 LICENSE） | 已有 ROS 2 工作区；不生成地图，必须配置协方差、坐标系和时间戳。 |
| [AMCL（Nav2）](https://github.com/ros-navigation/navigation2/tree/main/nav2_amcl) | 粒子滤波的 2D 激光地图定位；适合已有栅格地图。 | 按包 LICENSE/package.xml | Nav2 的组成模块，不是另一个独立导航栈；检查初始位姿和激光模型。 |
| [Hierarchical Localization / hloc](https://github.com/cvg/Hierarchical-Localization) | 图像检索、局部特征匹配及几何定位；用于视觉重定位研究。 | Apache-2.0 | 需参考图像/重建地图；特征模型及权重条款独立，不是开箱即用的在线里程计。 |

## 导航与运动规划

导航决策与局部避障仍需底盘执行；机械臂运动规划不等同于移动底盘导航。

| 项目 / 官方入口 | 适用任务与为什么看它 | 许可快照 | 使用前提与限制 |
|---|---|---|---|
| [Nav2（Smac / MPPI / RPP）](https://github.com/ros-navigation/navigation2) | ROS 2 导航系统，整合全局规划、控制器、行为树和恢复；工程选型入口。 | 多许可，按包核验 | Smac、MPPI、Regulated Pure Pursuit 是不同插件路线；需要地图/定位、costmap、TF 和底盘接口。 |
| [MoveIt 2](https://github.com/moveit/moveit2) | 机械臂运动规划、运动学与碰撞检测框架；连接规划器和控制器。 | BSD-3-Clause（依赖另计） | 选择对应 ROS 发行版分支；需要 URDF/SRDF、关节约束和控制器。 |
| [cuRobo](https://github.com/NVlabs/curobo) | CUDA 加速的机器人运动生成，适合并行 IK、碰撞感知轨迹规划。 | Apache-2.0（当前主分支） | 需要兼容 NVIDIA GPU/CUDA 与机器人碰撞模型；不是完整导航/底层伺服栈。 |

## VLN：视觉语言导航

VLN 解决“根据语言去哪里、下一步怎么走”；应与可靠定位、避障和执行控制组合。

| 项目 / 官方入口 | 适用任务与为什么看它 | 许可快照 | 使用前提与限制 |
|---|---|---|---|
| [NaVILA](https://github.com/AnjieCheng/NaVILA) | 腿式机器人视觉语言动作导航；机器狗语言指令执行的代表研究。 | 代码 Apache-2.0；底座/权重另核 | 官方实现和模型入口；按上游部署流程适配，不能假定任意机器狗直接可用。 |
| [StreamVLN](https://github.com/InternRobotics/StreamVLN) | 连续视频与长时记忆的在线 VLN；提供 Go2 部署资料。 | CC-BY-NC-SA-4.0，非商业 | 源码可用但有非商用限制；Habitat、LLaVA-Video 与数据条款另计。 |
| [InternNav](https://github.com/InternRobotics/InternNav) | 包含 InternVLA-N1、NavDP 等的导航平台，适合比较与闭环评估。 | 代码 MIT；InternData-N1 非商业 | 不是单一算法；部分模块标 coming soon，不能把整个平台视为全部已发布。 |

## VLA：视觉语言动作

VLA 将视觉、语言映射到动作策略，多用于操作；动作语义、频率和安全边界须与机器人一致。

| 项目 / 官方入口 | 适用任务与为什么看它 | 许可快照 | 使用前提与限制 |
|---|---|---|---|
| [OpenVLA](https://github.com/openvla/openvla) | 7B 视觉语言动作模型；操作任务微调与跨平台动作适配的代表基线。 | 代码 MIT；模型/底座另核 | 官方微调和评估流程；仍需目标机器人数据及动作规范。 |
| [openpi（π₀ / π₀-FAST / π₀.₅）](https://github.com/Physical-Intelligence/openpi) | 官方通用操作策略库，涵盖 flow-matching 与自回归动作路线。 | 代码 Apache-2.0；Gemma/权重另核 | 提供 checkpoint 和微调示例；π₀.₅ 当前为 flow-matching head，不保证跨硬件零样本成功。 |
| [Isaac GR00T N1.7](https://github.com/NVIDIA/Isaac-GR00T) | 当前官方通用机器人 VLA 入口，含人形/操作任务适配和微调流程。 | 代码 Apache-2.0；权重 NVIDIA Open Model License | N1.7 为本次主分支版本；Cosmos-Reason2-2B 等底座有访问与许可要求。 |

## 世界模型

这里分清潜在动力学、动作条件预测与生成式视频模型；“世界模型”不自动意味着物理精确或可安全控制。

| 项目 / 官方入口 | 适用任务与为什么看它 | 许可快照 | 使用前提与限制 |
|---|---|---|---|
| [DreamerV3](https://github.com/danijar/dreamerv3) | 学习潜在动力学并在想象轨迹中优化策略；世界模型强化学习基线。 | MIT | 官方训练实现与配置；不是现成通用机器狗策略，训练与评估任务须自行定义。 |
| [V-JEPA 2 / 2-AC / 2.1](https://github.com/facebookresearch/vjepa2) | 视频预测表征；2-AC 是动作条件潜在模型，用于研究操作规划。 | 主体 MIT；部分文件 Apache-2.0 | 按模型卡选择；普通视频编码器、2-AC 与 2.1 的功能不同，不能混写成一个控制器。 |
| [NVIDIA Cosmos 3](https://github.com/NVIDIA/cosmos) | 面向物理 AI 的世界基础模型平台，提供预测、生成与推理工作流。 | 当前代码/模型 OpenMDW-1.1 | 这是当前主入口，不沿用旧 Predict2 许可；第三方安全过滤器/模型条款另核。 |

## 运动控制与运动学习

算法输出最终必须服从机器人关节、接触、力矩与实时控制约束。真机前先做仿真和限幅验证。

| 项目 / 官方入口 | 适用任务与为什么看它 | 许可快照 | 使用前提与限制 |
|---|---|---|---|
| [Unitree RL Gym](https://github.com/unitreerobotics/unitree_rl_gym) | Unitree 官方强化学习训练与部署入口，适合四足/人形平台适配。 | BSD-3-Clause | 按机器人型号配置，检查 SDK/仿真版本；不是所有机型共享一个可直接上机策略。 |
| [legged_gym + RSL-RL](https://github.com/leggedrobotics/legged_gym) | 并行仿真 + PPO 的腿式运动经典基线，适合理解 RL locomotion。 | legged_gym BSD-3-Clause；RSL-RL 另见上游 | 上游已迁向 Isaac Lab，旧仓库有限维护；[RSL-RL](https://github.com/leggedrobotics/rsl_rl) 版本需配套。 |
| [OCS2](https://github.com/leggedrobotics/ocs2) | 切换系统最优控制与 MPC；适合接触切换、腿式及移动操作控制研究。 | BSD-3-Clause | 需要动力学、约束和求解器调参；不是可直接代替电机驱动的通用控制器。 |
| [ASAP](https://github.com/LeCAR-Lab/ASAP) | 对齐仿真与真实物理的人形敏捷全身技能学习，RSS 2025 代表路线。 | MIT（资产/数据另核） | 动作数据、机器人参数及部署依赖须准备；作者真机演示不等于本仓库安全验证。 |

## 配套仿真与训练平台

以下是实验基础设施，不应计作独立 SLAM/VLA 算法，也不等同于世界模型。

| 项目 / 官方入口 | 适用任务与为什么看它 | 许可快照 | 使用前提与限制 |
|---|---|---|---|
| [Isaac Lab](https://github.com/isaac-sim/IsaacLab) | 机器人强化/模仿学习的统一仿真训练框架；新腿式学习项目的重要入口。 | 主体 BSD-3-Clause；mimic 扩展 Apache-2.0；仿真器/资产另计 | 检查后端、GPU、操作系统及资产依赖；不能把训练成功当作 sim-to-real 已通过。 |
| [MuJoCo Playground](https://github.com/google-deepmind/mujoco_playground) | 基于 MuJoCo 的机器人学习环境及仿真/真实示例。 | Apache-2.0（外部资产另计） | 按官方示例准备加速与模型依赖；任务和真机适配覆盖不是普适保证。 |

## 持续维护规则

1. 每日覆盖上述领域，优先查官方论文、项目页、作者代码仓库；新增和重大版本变更都可纳入。
2. 每项记录核验日期、任务类别、官方入口、可用性与许可边界。先看已有条目，按论文 ID / 官方仓库去重。
3. 新发现但代码未公开的工作放入 [研究索引](../research/README.md)，不把模型公告或占位 README 当作可运行代码。
4. 默认新增链接和说明，不增加 workspace manifest；只有明确需要按需构建、且安装分类已核实，才扩展原工作区清单。
5. 不依靠 star 数判定效果，不复制排行榜为“最强”；对热点项目同时保留成熟对照基线。
6. 保留旧条目与来源，按事实更新版本、归档/停止维护和许可变化。每日新收录不等于当天新发布。

## 本次更新

2026-11-18：扩展为机器人跨领域导航，共 **27 个入口**（其中 2 个为配套仿真平台）。
保留原 SLAM 工作区；本次只新增本导航文档、来源快照并更新入口说明，不下载第三方源码。
