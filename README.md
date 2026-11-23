# skillcrate

给 coding agent 用的一组 skill，装在一个仓里。

六个 skill 各自独立触发、各自可以单独安装；放在一起是因为它们之间有真实的引用关系（见下），分仓会漂移。

## 装了什么

| skill | 什么时候用 | 依赖 |
|---|---|---|
| `calm-explain` | 讲解 / 澄清 / 拆解 / 对比 / 带读；「讲讲」「解释一下」「讲清楚」 | — |
| `geeklens` | 给一段真实源码做阅读版注解：逐行注释、改前/改后、数据结构手册 | `calm-explain`（强制）、`project-memory`（落盘） |
| `informed-decision` | 需要你拍板但你缺上下文时：影响驱动的 SCQA 简报（基线 / 影响三问 / 核心取舍 / 带代价的选项） | `calm-explain`（风格）、`project-memory`（决策记录） |
| `project-memory` | 项目根 `./tmp/` 的过程记忆、实验记录、当前状态 | — |
| `host-memory` | 主机级记忆（`~/host-memory`）、本机巡检、配置同步 | — |
| `file-conversion-toolkit` | 本地文件格式转换的类型路由（docx / pdf / md / epub / 音视频） | — |

## 关系

```
geeklens ────────── 讲解协议 ──────────▶ calm-explain
geeklens ────────── 落盘 ─────────────▶ project-memory
informed-decision ─ 讲解风格 ──────────▶ calm-explain
informed-decision ─ 决策记录 ──────────▶ project-memory
geeklens ────────── 先读透源码 ───────▶ informed-decision
host-memory ─────── 边界划分 ─────────▶ project-memory
file-conversion-toolkit ── 独立
```

`geeklens` 触发时必须加载 `calm-explain` 的讲解协议（风格唯一来源），产物按 `project-memory` 的约定落在 `./tmp/annotated/`；`informed-decision` 复用同一套讲解风格，决策记录走 project-memory。这三方接口是契约：改 `calm-explain` 的风格规则或 `project-memory` 的落盘约定，要同时改所有引用方（见 `AGENTS.md` §3）。

## 安装

用 Skills CLI，按需装单个：

```bash
npx skills add wurenrumian/skillcrate --skill geeklens --global --yes
```

一次装全部：

```powershell
# Windows
./install.ps1
```

```bash
# Linux / WSL / macOS
./install.sh
```

手工复制也可以，目录名必须与 frontmatter 的 `name:` 一致：

```powershell
Copy-Item -Recurse ./calm-explain "$env:USERPROFILE\.config\opencode\skills\calm-explain"
```

已安装的副本是**派生**的：改这里的 `SKILL.md`，push 之后跑 `npx skills update -g -y` 或重跑安装脚本，副本才会跟上。

## 维护

改任何 skill 前先看 `AGENTS.md`，里面有三条硬约束（目录名、跨 skill 引用、接口成对改动）。

## 不在这个仓里

`concept-atlas`（`concept-atlas-dense-explain`）是独立仓：它有自己的 npm 包、Vite 构建链和测试，体积是其它六个的两个数量级，进来会把 clone 变重。
