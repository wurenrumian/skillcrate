# file-conversion-toolkit

本地文件转换的**路由 skill**：一个文档优先的决策指南，把转换任务按"当前主机实际装了什么"路由到正确的工具，并写明能力边界与已知陷阱。

`SKILL.md` 是 skill 本体。它是主机感知的：§0 探测机器，§1 记录上次探测时各机的现状，§2 按实际安装的工具选路，而不是按假设的工具链。

## 状态

发布自 `skillcrate` 仓，作为全局 `npx skills` skill 安装：

```bash
npx skills add wurenrumian/skillcrate --global --skill file-conversion-toolkit --yes
```

它同时登记在 dotfiles 清单（`dot_config/agent-skills/skills.json`）里，其安装脚本会在每台主机上执行这条 `npx skills add` —— 清单项必须指向 `skillcrate` 仓。各 agent 技能目录下的已装副本是**派生**的：改这里的 `SKILL.md`、push，然后重跑安装脚本（或 `npx skills update -g -y`）让副本跟上。

## 覆盖范围

文档是主体。

| 工具 | 作用 |
| --- | --- |
| Pandoc | 文档格式互转（md、docx、html、epub、odt、rst、latex、pptx） |
| LibreOffice | Office 保真与批量 → PDF |
| MarkItDown | 万物 → Markdown；音频 → 转写 |
| Typst | Windows 上 Pandoc 的 PDF 引擎（那边没有 LaTeX） |
| poppler（`pdftotext`、`pdftoppm`） | Linux 上 PDF → 文本、PDF → 页图 |
| Ghostscript | Linux 上 PDF 取文本 / 栅格化的兜底 |
| Python（PyMuPDF / pdfplumber / pypdf） | PDF → 文本、表格、图片；合并 / 拆分（Windows） |
| ImageMagick | 图片（次要） |
| FFmpeg | 音视频（次要）、MarkItDown 音频、HyperFrames 渲染 |

有意**排除**：通用压缩包、构建工具链，以及一切不是"转换"的事。

## 维护

升级任何工具后重新探测，并把日期更新到 `SKILL.md` §1：

```bash
for t in pandoc soffice markitdown typst magick convert ffmpeg pdftotext pdftoppm gs tesseract qpdf python3; do command -v "$t" >/dev/null && echo "OK   $t" || echo "MISS $t"; done
```

```powershell
pandoc --version; markitdown -v; typst --version; magick -version; ffmpeg -version
magick -list format | Select-String -Pattern 'HEIC|AVIF|WEBP|PSD|SVG|DNG|PDF'
pandoc --list-output-formats
```

## 相关备注

- Windows 上工具以便携方式装在 `D:\Tools\`，通过**用户** PATH 暴露；它们是 `.exe`，所以在 WSL 发行版里不能按裸命令名调用。
- Windows 上**没有 Ghostscript 也没有 LaTeX**，Windows 的路由依赖这两个缺席。Fedora 正好相反：有 Ghostscript 和 poppler，但没有 Pandoc、MarkItDown、Typst、FFmpeg。
- 在 Windows 上重装 FFmpeg 是恢复 MarkItDown 音频转写的办法。