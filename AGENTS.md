# 仓库约定

这些 skill 共享一个仓，但**安装时是各自独立的**：`npx skills add` 只复制被选中的那个目录。下面的规则都是为这一点服务的。

## 1. 目录名 = skill 名

- 一个 skill 一个目录：`<name>/SKILL.md`，`name` 必须与 frontmatter 的 `name:` 完全一致。
- 一个 skill 目录里只允许一个 `SKILL.md`；目录内不要嵌套别的 skill。
- 根目录不放 `SKILL.md`（否则 `npx skills add wurenrumian/skillcrate` 会把仓根当成一个 skill）。
- 新增 skill：建目录 → 写 `SKILL.md`（含 name/description）→ 写 `README.md` → 加进根 `README.md` 的表和 `install.ps1` / `install.sh` 的列表 → 在 `AGENTS.md` 的接口表里登记它引用了谁。

## 2. 不引用 skill 目录之外的文件

安装时只有该 skill 的目录会被复制到用户机器上。所以：

- 正文里**不能**出现 `../calm-explain/xxx.md`、`../../AGENTS.md` 这类路径。
- 跨 skill 只能写「按 `X` 的规则」，正文宁可各自保留一份，也不要为了去重而建共享文件。
- 根目录的 `README.md` / `AGENTS.md` 只给维护者看，运行时不依赖它们。

## 3. 接口改动要成对提交

下面这些是契约，动一边必须同一个 commit 里动另一边：

| 契约 | 位置 |
|---|---|
| 讲解风格、术语承接与命名确认、证据三档标签、篇幅跟随难度 | `calm-explain/SKILL.md` ← `geeklens/SKILL.md`、`informed-decision/SKILL.md` 只引用不复述 |
| 阅读版落在 `./tmp/annotated/`、`tags` front-matter、`STATE.md` 关键链接、`archive/annotated/` | `geeklens/SKILL.md` ↔ `project-memory/SKILL.md` + `references/` |
| 决策记录落在 `./tmp/docs/memory/`、何时记何时不记 | `informed-decision/SKILL.md` ↔ `project-memory/SKILL.md` |
| 主机级 vs 项目级记忆的边界 | `host-memory/SKILL.md` ↔ `project-memory/SKILL.md` |

改 `project-memory` 的脚本或样本库后先跑：

```bash
python project-memory/tests/run_tests.py
```

## 4. 提交与行尾

- 一个 skill 的改动用 `<skill>:` 前缀，跨 skill 用 `all:`，仓级用 `chore:` / `docs:`。
- 全仓 LF（根 `.gitattributes` 已锁），不要提交 CRLF 文件。
- 不提交依赖与产物：`node_modules/`、`__pycache__/`、`.memory-cache.json` 已在 `.gitignore`。

## 5. 历史

大部分 skill 是用 `git subtree add` 并进来的，原仓的 commit（含 SHA 和日期）都在本仓历史里；`informed-decision` 是并库后直接在本仓写的。上游旧仓已归档，**不要再 `git subtree pull`**；从现在起本仓是唯一来源。
