# SLAM 论文与代码跟踪

核验日期：2026-11-17。这里记录研究线索，不是评测排名；代码状态是当日快照。
首次补录包含近期论文和较早但目录尚未收录的算法，不等于全部在本日发布。

## 稠密视觉 SLAM / 3D 基础模型

| 工作 | 论文日期 / 出处 | 分类与核心思路 | 官方代码状态 | 目录处理 |
|---|---|---|---|---|
| [Map2SLAM](https://arxiv.org/abs/2611.11169) | 2026-11-08，arXiv v1 | 以冻结的 LingBot-Map 进行流式观测，并维护可被回环修正的 SLAM 状态 | [官方仓库](https://github.com/robbyant-research/Map2SLAM) 当前仅 README，说明代码将发布；[项目页](https://robbyant-research.github.io/Map2SLAM/) | 等待代码，不创建 manifest |
| [Spade-SLAM](https://arxiv.org/abs/2611.01937) | 2026-11-01，arXiv v1 | 自监督稠密视觉 SLAM，使用稀疏对应约束辅助训练 | [官方仓库](https://github.com/JulianPSchmitt/Spade-SLAM) 明确 Code coming soon | 等待代码，不创建 manifest |
| [VGGT-SLAM 2.0](https://arxiv.org/abs/2601.19887) | 2026-01-27 首发，2026-01-30 v2；上游标注 RSS 2026 | RGB 稠密 SLAM，子图对齐、回环验证与因子图优化 | [官方代码](https://github.com/MIT-SPARK/VGGT-SLAM) 已有 main.py、main_realtime.py、setup.sh；main 为 2.0 | 已加入 [standalone](../standalone/README.md)，custom 安装；未本地运行验证 |
| [MASt3R-SLAM](https://arxiv.org/abs/2412.12392) | CVPR 2025，首次目录研究补录 | 利用 3D 重建先验的稠密视觉 SLAM | [官方代码](https://github.com/rmurai0610/MASt3R-SLAM) 已发布，需 CUDA/PyTorch 和权重；[许可](https://github.com/rmurai0610/MASt3R-SLAM/blob/main/LICENSE.md) 为 CC BY-NC-SA 4.0 | 仅研究索引；属于有非商业限制的源码可用项目，不标作无此限制的开源项目 |

VGGT-SLAM 2.0 的 arXiv 摘要仍写代码将发布，但当前官方仓库已有实现和安装流程，
因此代码状态以核验到的仓库为准。其核心代码为 BSD-2-Clause，依赖和模型许可须单独检查。
本文不复制论文中的性能排名，不将作者实验等同于本仓库测得结果。

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
