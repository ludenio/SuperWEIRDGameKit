[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)

# SuperWEIRD 游戏套件

嗨！我们在 [Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) 正在开发 [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github)（在 [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github) 查看游戏）。这是一款使用 [Defold](https://defold.com) 引擎制作的合作游戏，围绕使用类似旅鼠的机器人进行系统设计与自动化。

在早期开发阶段，我们对美术风格和玩法做了许多实验。我们认为这些可能对其他开发者有帮助，因此决定将这些实验中的代码、纹理与动画以开放的 [CC0](LICENSE) 许可发布。

在这个仓库中，你会找到六种不同的视觉风格（[video](https://youtu.be/RJwOEDY3MP4)），以及商店/生产模拟器的玩法逻辑。玩家需要完成客户订单并扩展产线。你可以试玩 [demo on itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github)。

[![Project Video](youtube_intro_cover.png)](https://youtu.be/Jjm47KMF-V0)

加入我们的 [Discord](https://discord.gg/ludenio)，告诉我们你会用这些原型做些什么。或者关注我们的 [YouTube channel](https://www.youtube.com/@ludenio) —— 里面有很多精彩内容，包括 [SuperWEIRD dev diaries](https://www.youtube.com/@ludenio/videos)。

链接：
- Discord（我们每天都在）：https://discord.gg/ludenio
- YouTube：https://www.youtube.com/@ludenio
- 含更新与文字开发日志的通讯：https://ludenio.substack.com/
- Twitter（X）：https://x.com/luden_io

# 合作伙伴

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

SuperWEIRD 得到 [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun) 的支持。该慈善基金致力于让来自不同社区的孩子能够接触科学与技术。他们认为数学是未来创新的基石，并资助那些激发和培养数学人才的机构。如果你对其他教育项目感兴趣，可以了解一下 Carina Initiatives 的合作伙伴：

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# 快速开始

1. 安装 Defold Editor：https://defold.com
2. 克隆或下载本仓库。
3. 在 Defold Editor 中打开项目文件夹。
4. 构建并运行项目。

注意：编辑 Spine 动画需要 Spine Editor。

# 项目结构

1. 加载
   - `loader` —— 随游戏一起启动，常驻内存，并通过 Collection Proxy 管理集合的加载/卸载；启动时初始化开始菜单。
   - `menu` —— 游戏启动时显示的开始菜单。

2. 核心
   - `main` —— 通用游戏代码：各个世界共用的脚本和模块；包含全部游戏逻辑。
   - `assets` —— 游戏资源：纹理、Spine 模型、瓦片地图和图集。每个世界都有自己的文件夹 `world_1`、`world_2` 等，包含独特的美术。
   - `worlds` —— 世界的可视化配置：集合与游戏对象。每个世界都是 `world_1`、`world_2` 等中的一个独立集合。

3. 额外内容
   - `SuperWEIRDGameKit_assets` —— 项目中使用的整理后的图形与 Spine 模型集。

# 世界管理逻辑

- 通过 `loader` 进行世界切换，负责加载与卸载集合。
- 世界自定义：在 `worlds/world_X` 中更新视觉参数和游戏对象，在 `assets/world_X` 中更新图形资源。

## 添加新世界

1. 创建文件夹 `assets/world_N` 和 `worlds/world_N`。
2. 从现有世界复制模板。
3. 在加载器/菜单的代码中注册新世界（参见 `main` 中的逻辑）。
4. 确保集合与资源正确关联。
