---
name: file-conversion-toolkit
description: 在 Windows / Fedora 本机把文档和文件转换成目标格式，按本机已装工具选路：文档为主（Office、PDF、Markdown、HTML、EPUB、LaTeX），图片与音视频为次。凡是用户要 转格式 / 转换 / 转成 / 导出 / 批量转换，或说『转 pdf』『转 md』这类简写，或问某个转换该用哪个工具，都使用本 skill。不用于纯云端 / API 转换。Local file conversion on Windows or Fedora, routed to whichever tool is actually installed.
---

# 文档与文件转换（File Conversion）

先选对工具，再给最短的正确命令。

回复用用户所用的语言；命令保持英文。

**装了什么工具因主机而异。** §0 探测当前主机，§1 记录上次探测时各机的现状，§2 按**这里实际装了的**选路 —— 绝不按本文档"希望"装了什么。

## 0. 先探测本机

```bash
for t in pandoc soffice markitdown typst magick convert ffmpeg pdftotext pdftoppm gs tesseract qpdf python3 python; do
  command -v "$t" >/dev/null 2>&1 && echo "OK   $t" || echo "MISS $t"
done
```

```powershell
'pandoc','soffice','markitdown','typst','magick','ffmpeg','python' | ForEach-Object {
  $p = Get-Command $_ -ErrorAction SilentlyContinue
  if ($p) { "OK   $_ -> $($p.Source)" } else { "MISS $_" }
}
```

Python 第三方模块要**单独**查 —— 它们只装在 Windows 的解释器里（§7）：

```bash
python3 -c "import importlib.util as u; print([m for m in ('fitz','pdfplumber','pypdf','docx') if u.find_spec(m)])"
```

想走的路线需要本机没有的工具时，直接说明，并给出**已安装**的替代方案。绝不为不存在的工具给命令。

## 1. 本机现状（探测于 2026-10-17）

- **Windows** 承担主力：Pandoc + Python，外加只在这一台的 MarkItDown、Typst、FFmpeg。
- **原生 Fedora**：poppler + Ghostscript 做 PDF，LibreOffice 做 Office —— 但**没有 Pandoc**，"格式 A → B"只能落到 LibreOffice 或 Python。
- **WSL 发行版**：只有 Python 标准库，其余一概没有。在那里收到转换需求，通常意味着"告诉用户缺什么"。

本文件只有 Windows 命令在实机上实测过；Fedora 各项只做了存在性探测，用的是各工具的标准 CLI。任何升级后重新探测（§0）并更新本节。

## 2. 路由：任务 → 工具，优先用已安装的

| 任务 | 首选 | 本机没有时 |
| --- | --- | --- |
| 文档整篇：格式 A → 格式 B | **Pandoc** | LibreOffice（Office ↔ Office、Office → PDF、→ csv/html） |
| DOCX/XLSX/PPTX → PDF，或批量处理 Office | **LibreOffice**（`soffice`） | — |
| 任何东西 → Markdown（阅读 / 喂给 LLM） | **MarkItDown** | `pandoc -t gfm`；Office 先 `soffice --convert-to html` |
| Markdown → 排版好的 PDF | **Pandoc + Typst** | 先 `pandoc -o out.docx` 再 `soffice --convert-to pdf` |
| PDF → 文本 | `pdftotext`（poppler） | Python PyMuPDF；`markitdown`；`gs -sDEVICE=txtwrite` |
| PDF → 表格 | Python `pdfplumber` | — |
| PDF → 每页一张图 | `pdftoppm`（poppler） | Python PyMuPDF；`gs -sDEVICE=png16m` |
| PDF 合并 / 拆分 | Python `pypdf` | `qpdf`；`gs` |
| 图片 → 另一种图片格式 | **ImageMagick**（`magick`） | — |
| 音频或视频 → 另一种格式 | **FFmpeg** | — |

文档是主体，图片和媒体见 §8、§9。

## 3. Pandoc —— 格式互转

```powershell
pandoc in.md    -o out.docx                              # md → docx
pandoc in.md    -o out.docx --reference-doc=template.docx # 套用自己的样式模板
pandoc in.md    -o out.pptx                              # md → 幻灯片
pandoc in.md    -o out.epub
pandoc in.md    -o out.pdf  --pdf-engine=typst           # PDF 必须指定引擎
pandoc in.docx  -o out.md   --extract-media=./media       # docx → md，把图片抽出来
pandoc in.docx  -o out.html -s                            # -s = 独立文件
pandoc in.html  -o out.md
pandoc in.html  -o out.pdf --pdf-engine=typst            # 网页 → PDF
pandoc in.tex   -o out.docx
pandoc in.csv   -o out.md
pandoc in.odt   -o out.docx
pandoc in.<X>   -o out.<Y>                                # 任意受支持的格式对
```

常用参数：`-s`（独立文件）、`--toc`、`--number-sections`、`--metadata title="…"`、`-f gfm` / `-t gfm`。

查它支持什么：

```powershell
pandoc --list-input-formats
pandoc --list-output-formats
```

**输出 PDF 必须指定引擎。** Windows 上唯一的引擎是 Typst（`--pdf-engine=typst`）—— 那边没有 LaTeX。既没有引擎、也没有 Typst 的地方不要硬来：先出 `out.docx`，让 LibreOffice 转 PDF。

**Markdown 方言。** 这批工具里只有 Pandoc 读 Markdown，所以方言有影响时要点名：

```powershell
pandoc in.docx -t gfm -o out.md          # GitHub 风格：表格、任务列表、删除线
pandoc in.md   -f commonmark -o out.html # 严格 CommonMark
pandoc in.md   -f markdown_strict -o out.rst
pandoc in.md   -f markdown_mmd  -o out.md
```

`markdown_strict` 会**丢掉 Pandoc 的扩展**（脚注、定义列表、网格表格）。默认的 `markdown` 输出也不是 GitHub 渲染的那套 —— 要 GitHub 认的 Markdown，显式写 `-t gfm`。

这几台机器上**没有专门的 Markdown 工具**：没有 formatter、linter、预览器，也没有 `cmark` 或 `mdbook`。两个方向都由 Pandoc 覆盖；没有 Pandoc 的地方，最接近的替代是 LibreOffice 的 `html` 导出。

## 4. LibreOffice —— Office 保真与批量

```powershell
soffice --headless --convert-to pdf --outdir . in.docx
soffice --headless --convert-to pdf --outdir . *.docx      # 批量：一次调用，全部文件
soffice --headless --convert-to csv --outdir . in.xlsx
soffice --headless --convert-to docx --outdir . in.odt
soffice --headless --convert-to "pdf:writer_pdf_Export" --outdir . in.docx
```

- 命令在 Windows 和 Fedora 上都叫 `soffice`。它是这几台机器上唯一每台都有的文档工具。
- **批量一次调用完成，绝不写循环。** Windows 实测 6 个 DOCX → PDF：一次调用 **8.6 s**，`ForEach-Object` 循环 **40–70 s**。每次启动约 6 s，用户配置是单实例。
- **对表格用 `--convert-to csv` 只导出第一个工作表。** 其余工作表静默丢弃。要所有工作表，有 MarkItDown 就用它（§5），或者转 `pdf` / `html`，两者都带全部工作表。
- `soffice` **覆盖**已有输出文件且不提示 —— 批量跑可能误盖文件。
- 版面保真重要时（表单、样式、脚注、修订）用 LibreOffice；要 Markdown 或结构化文本时用 Pandoc。

## 5. MarkItDown —— 万物 → Markdown

```powershell
markitdown in.docx -o out.md     # DOCX / PDF / PPTX / XLSX / HTML → Markdown
markitdown in.xlsx               # 每个工作表 → 一个 ## SheetName 小节 + GFM 表格
markitdown in.pdf                # 输出到 stdout
cmd /c "markitdown < in.docx"    # 从 stdin 读
```

- 最适合把干净的 PDF/DOCX/PPTX/XLSX/HTML 转成 Markdown 交给 LLM。
- **XLSX 是最强的场景**：一个工作表都不丢，每个变成 `## SheetName` 标题加一张 Markdown 表。这是这几台机器上最好的多工作表导出。
- 对**带文本层**的 PDF，pdfplumber 抽表比 MarkItDown 好。对**扫描版** PDF 两者都不行 —— 没有文本层可读（§11）。
- **这里没有任何直接的 PDF → DOCX。** 变通是两步：`markitdown in.pdf -o tmp.md`，再 `pandoc tmp.md -o out.docx`。
- 只装在 Windows 上（§1）。其他地方按 §2 回退。

## 6. Typst —— PDF 引擎

只为了给 Pandoc 提供 PDF 后端（§3）；Typst 自己的标记也能直接出 PDF：

```powershell
typst compile in.typ            # Typst 自己的标记 → PDF
```

没有 Typst 的机器不要装它来补 LaTeX —— 直接走 LibreOffice。

## 7. PDF 提取 —— 用本机有的工具

两条路线都各有安装，但在不同主机上：**Fedora 上是 poppler / Ghostscript**，**Windows 上是 Python**。

Fedora（poppler + Ghostscript）：

```bash
pdftotext -layout in.pdf -                  # 文本，保留版面 → stdout
pdftoppm -r 200 -png in.pdf page            # 每页一张 PNG：page-1.png、…
gs -sDEVICE=txtwrite -o out.txt in.pdf      # 用 Ghostscript 取文本
gs -sDEVICE=png16m -r200 -o page-%d.png in.pdf
```

Windows（Python —— 第三方模块**只**装在这里；用 §0 检查）：

```powershell
# PDF → 文本
D:\Python\python.exe -c "import pymupdf; d=pymupdf.open('in.pdf'); print(chr(10).join(p.get_text() for p in d))"

# PDF → 每页一张图
D:\Python\python.exe -c "import pymupdf; d=pymupdf.open('in.pdf'); [p.get_pixmap(dpi=200).save(f'p{i+1}.png') for i,p in enumerate(d)]"

# PDF → 表格
D:\Python\python.exe -c "import pdfplumber; pdf=pdfplumber.open('in.pdf'); print(pdf.pages[0].extract_table())"

# 合并 PDF
D:\Python\python.exe -c "from pypdf import PdfWriter; w=PdfWriter(); w.append('a.pdf'); w.append('b.pdf'); w.write('merged.pdf')"
```

Windows 上一律显式调用 `D:\Python\python.exe` —— 裸 `python` 会解析到 Windows 应用商店的占位程序。Fedora 上是 `python3`，且 PDF 模块**没装**：要么用上面的 poppler / `gs`，要么征得用户同意后安装（`python3 -m pip install --user pymupdf pdfplumber pypdf`）。

不要用 ImageMagick 读 PDF：它需要 Ghostscript **且** ImageMagick 策略放行，即使有 `gs` 也不可靠（§10.2）。

## 8. 图片 —— ImageMagick

```powershell
magick in.heic out.jpg                            # 格式转换
magick in.png -resize 50% out.webp
magick in.png -resize "1920x1080>" out.jpg        # 必须加引号：> 是几何修饰符
magick in.png -crop 800x600+100+50 +repage out.png
magick in.png -quality 85 -strip out.jpg
magick in.png watermark.png -gravity southeast -composite out.png
magick montage *.jpg -tile 4x -geometry +5+5 sheet.jpg    # 输出文件名放在最后
magick identify -verbose in.png

# 扫描件 → 单个多页 PDF（写 PDF 可以，读不行）
magick scan1.png scan2.png -page A4 scans.pdf
```

`magick` 在 Windows 和 Fedora 上都是 ImageMagick 7。Fedora 上还有旧别名 `convert` —— 但 Windows 上 `convert` 是磁盘管理工具（§10.1），所以一律写 `magick`，命令在两边都对。

**Windows** 版的格式支持（其他地方用 `magick -list format` 复查）：

- 可读**且**可写：`AVIF`、`WEBP`、`JXL`、`PSD`、`TIFF`、`SVG`、`EPS`、`PNG`、`JPEG`
- **只可写**：`PDF` —— 写可以，读失败（Windows 上没装 Ghostscript）
- **只可读**：`HEIC`、`HEIF`、`DNG`、`CR2`、`NEF`、`ARW` —— 所以 `HEIC → JPG` 可以，**`JPG → HEIC` 不行**

与文档相关：把扫描页图片、截图或 iPhone 的 HEIC 照片喂给文档工具之前，先这样转一道。

## 9. 音视频 —— FFmpeg（次要）

```powershell
ffmpeg -i in.mkv -c copy out.mp4                                  # 换容器，不重编码
ffmpeg -i in.mkv -c:v libx264 -crf 23 -c:a aac -b:a 192k out.mp4 # 重编码
ffmpeg -i in.mp4 -vn -c:a libmp3lame -q:a 2 out.mp3               # 抽音轨
ffmpeg -i in.mp4 -vf scale=1280:-2 out.mp4
ffprobe -hide_banner -show_format -show_streams in.mkv
```

脚本里加 **`-y`**，否则 FFmpeg 会卡在覆盖提示上。FFmpeg 只装在 Windows 上（§1）—— 它也是 MarkItDown 音频转写和 HyperFrames 渲染器的前置依赖。

唯一与文档沾边的用法：**音频 → 文本**，用 `markitdown`（§5），需要 `PATH` 上有 FFmpeg **且**联网。

## 10. 陷阱

1. **Windows 上的 `convert` 不是 ImageMagick** —— `C:\WINDOWS\system32\convert.exe` 是磁盘管理工具。一律用 `magick`（在 Fedora 上也是对的）。
2. **ImageMagick 不碰 PDF** —— Windows 上根本没有 Ghostscript；Fedora 上有 `gs`，但 `policy.xml` 仍可能拒绝 PDF coder。PDF 一律用 poppler 或 PyMuPDF。
3. **Windows 工具不算 WSL 工具** —— `D:\Tools\*` 都是 `.exe`；在 WSL 发行版里，它们不以裸命令名出现在 `PATH` 上。
4. **改过 PATH 要开新终端。**
5. **Windows 上的 LibreOffice 是用 `msiexec /a` 解包的** —— 没有注册表项、没有文件关联、没有卸载程序（"卸载" = 删掉 `D:\Tools\LibreOffice`）。每次运行会打一条无害的 `<prefix>` 警告。

## 11. 缺口

与文档相关但未安装的：

`Ghostscript` 和 `poppler`（Windows 上）· `Pandoc`、`MarkItDown`、`Typst`、`FFmpeg`（Fedora 上，原生和 WSL 都是）· `qpdf` · `Tesseract`（本地 OCR）· Pandoc 的 LaTeX 引擎（所有机器）

- **扫描版 PDF 的 OCR**：这几台机器都没有本地方案。PDF 必须自带文本层；否则只能走云端。
- **带版面的 PDF → DOCX**：本地做不到。只有经 Markdown 往返，版面会丢。
- **`qpdf`** 值得在需要 PDF 修复 / 线性化时装上：Windows 和 Fedora 都没有。