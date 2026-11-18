# SLAM 论文与代码跟踪

最新检索日期：2026-11-18；旧条目保留原核验日期，新条目日期见小节。这里记录研究线索，不是评测排名；代码状态是当日快照。
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

## 后续分类与纳入标准

- 方向：LiDAR / LiDAR-inertial、visual / visual-inertial、RGB-D、multi-sensor、
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
