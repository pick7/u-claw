# 🦞 U-Claw

**AI 助手 U 盘制作工具 — 克隆代码，一键制作，双击就能用**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

U-Claw 是一个开源工具集，帮你把 [OpenClaw](https://github.com/openclaw/openclaw) AI 助手打包成 U 盘。插上 U 盘双击运行，或从 U 盘安装到电脑。全部依赖从国内镜像下载，不需要翻墙。

---

## 这个项目能做什么

| # | 功能 | 说明 |
|---|------|------|
| 1 | **制作 U 盘** | `build-usb.sh` 一键下载所有资源，打包成可拷贝到 U 盘的完整目录 |
| 2 | **免安装运行** | U 盘插上电脑，双击 `Mac-Start.command` 或 `Windows-Start.bat` 直接用 |
| 3 | **从 U 盘安装** | 双击 `Mac-Install.command` 或 `Windows-Install.bat`，离线安装到电脑 |
| 4 | **桌面 App** | Electron 桌面版，打包成 DMG/EXE 分发 |
| 5 | **文档 + 官网** | 使用指南、国内镜像说明、AI 模型配置教程 |

## 快速开始

### 制作一个 U 盘（最常用）

```bash
git clone https://github.com/dongsheng123132/u-claw.git
cd u-claw/portable

# 一键制作 U 盘（自动下载 Node.js + OpenClaw + QQ 插件，全部国内镜像）
bash build-usb.sh

# 完成后把 usb-build/U-Claw/ 文件夹拷贝到 U 盘
```

`build-usb.sh` 自动完成：
1. 选择目标平台（Mac / Windows / 全部）
2. 从国内镜像下载 Node.js v22
3. 安装 OpenClaw + QQ 插件
4. 打包成可直接拷贝的目录
5. 可选打包成 tar.gz

### 在自己电脑上搭建（开发/测试）

```bash
cd u-claw/portable
bash setup.sh            # 搭建运行环境
bash Mac-Start.command   # Mac 启动
# 或 Windows-Start.bat   # Windows 启动
```

---

## 项目结构

```
U-Claw/
├── portable/              ← 🔥 U 盘核心
│   ├── build-usb.sh           ⭐ 一键制作 U 盘
│   ├── setup.sh               开发者搭建脚本
│   ├── Mac-Start.command      Mac 免安装启动
│   ├── Mac-Menu.command       Mac 功能菜单（8 项）
│   ├── Mac-Install.command    Mac 从 U 盘安装到电脑
│   ├── Windows-Start.bat      Windows 免安装启动
│   ├── Windows-Menu.bat       Windows 功能菜单
│   ├── Windows-Install.bat    Windows 从 U 盘安装到电脑
│   ├── Config.html            首次配置页面
│   ├── U-Claw.html            导航首页
│   └── migrate.js             配置迁移工具
│
├── u-claw-app/            ← 🖥 桌面安装版（Electron）
│   ├── setup.sh / setup.bat   一键搭建开发环境
│   ├── src/main.js            Electron 主进程
│   └── package.json           依赖 & 构建配置
│
├── website/               ← 🌐 官网 + 教程（u-claw.org）
│   ├── guide.html             使用指南（含国内镜像、搭建教程）
│   ├── index.html             官网首页
│   └── skills.html            技能市场页
│
└── README.md
```

### U 盘上的文件（制作完成后）

```
U-Claw/                         ← 拷贝到 U 盘
├── Mac-Start.command            双击 = Mac 免安装运行
├── Mac-Install.command          双击 = 安装到 Mac
├── Windows-Start.bat            双击 = Windows 免安装运行
├── Windows-Install.bat          双击 = 安装到 Windows
├── Mac-Menu.command             Mac 功能菜单
├── Windows-Menu.bat             Windows 功能菜单
├── Config.html                  配置页面
├── app/                         运行时（~2.3GB）
│   ├── core/                       OpenClaw + QQ 插件
│   └── runtime/
│       ├── node-mac-arm64/         Mac Apple Silicon
│       └── node-win-x64/          Windows 64-bit
└── data/                        用户数据
    ├── .openclaw/                  配置文件
    ├── memory/                     AI 记忆
    └── backups/                    备份
```

## U 盘上的两种用法

### 免安装运行（推荐）

直接从 U 盘运行，不修改电脑任何文件。换电脑插上 U 盘，配置还在。

- Mac: 双击 `Mac-Start.command`
- Windows: 双击 `Windows-Start.bat`

**适合：** 临时电脑、公司电脑、网吧、不想装东西

### 安装到电脑

从 U 盘安装到 `~/.uclaw/`，之后不需要 U 盘也能用。

- Mac: 双击 `Mac-Install.command`
- Windows: 双击 `Windows-Install.bat`

安装逻辑：
1. 检查环境 → 缺什么先从 U 盘离线安装
2. U 盘没有的 → 从国内镜像在线下载
3. 创建启动脚本 → 以后双击 `~/.uclaw/start.command` 启动

## 桌面版（Electron App）

```bash
cd u-claw-app

# 一键安装开发环境（国内镜像）
bash setup.sh      # Mac/Linux
setup.bat           # Windows

# 打包
npm run build:mac-arm64  # → release/*.dmg
npm run build:win        # → release/*.exe
```

## 支持的 AI 模型

### 国产模型（无需翻墙）

| 模型 | 推荐场景 |
|------|----------|
| DeepSeek | 编程首选，极便宜 |
| Kimi K2.5 | 长文档，256K 上下文 |
| 通义千问 Qwen | 免费额度大 |
| 智谱 GLM | 学术场景 |
| MiniMax | 语音多模态 |
| 豆包 Doubao | 火山引擎 |

### 国际模型

Claude · GPT · Gemini（需翻墙或中转）

## 支持的聊天平台

| 平台 | 状态 | 说明 |
|------|------|------|
| QQ | ✅ 已预装 | 输入 AppID + Secret 即可 |
| 飞书 | ✅ 内置 | 企业首选 |
| Telegram | ✅ 内置 | 海外推荐 |
| WhatsApp | ✅ 内置 | Baileys 协议 |
| Discord | ✅ 内置 | — |
| 微信 | ✅ 社区插件 | iPad 协议 |

## 国内镜像

所有脚本默认使用国内镜像，无需翻墙：

| 资源 | 镜像 |
|------|------|
| npm 包 | `registry.npmmirror.com` |
| Node.js | `npmmirror.com/mirrors/node` |
| Electron | `npmmirror.com/mirrors/electron` |

## 参与开发

```bash
git clone https://github.com/dongsheng123132/u-claw.git
cd u-claw/portable
bash setup.sh            # 搭建开发环境
bash Mac-Start.command   # 测试启动
```

### 提交代码

```bash
git checkout -b feat/your-feature
git add -A
git commit -m "feat: your change"
git push -u origin feat/your-feature
```

## 待开发 / 欢迎贡献

- [ ] Windows 便携版完善测试
- [ ] Mac Intel 支持
- [ ] Linux 支持（AppImage）
- [ ] 桌面版自动更新
- [ ] SkillHub 技能市场功能完善
- [ ] 多语言支持（English UI）

## FAQ

**Q: 需要翻墙吗？**
安装不需要。运行需要联网调 API，国产模型无需翻墙。

**Q: 能分发吗？**
MIT 协议，随便复制。

**Q: Mac 提示"未验证的开发者"？**
右键脚本 → 打开。

**Q: U 盘需要多大？**
建议 4GB 以上（完整版约 2.3GB）。

**Q: Windows 需要 WSL？**
不需要，自带 Windows 版 Node.js。

## License

[MIT](LICENSE)

## 联系

- 微信: hecare888
- GitHub: [@dongsheng123132](https://github.com/dongsheng123132)
- 官网: [u-claw.org](https://u-claw.org)

---

**Made with 🦞 by [dongsheng](https://github.com/dongsheng123132)**
