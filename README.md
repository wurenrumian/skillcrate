# calm-explain

An agent skill for explaining things well.

`calm-explain` explains the way a patient colleague would with a whiteboard: one
thing at a time, stopping to check that it landed. An explanation starts as a
skeleton of named parts plus a table of the core concepts, then grows one block
per turn until the reader can carry the whole model.

## When it applies

Whenever the user asks to explain, clarify, walk through, compare, teach,
annotate, or understand why something behaves a certain way — even when they do
not say "explain". Also for follow-ups where the reader is stuck or conflating
nearby ideas, and for requests like 分层讲 / 一块一块讲 / 继续.

The staged rhythm applies regardless of size: a two-paragraph answer still opens
with the skeleton and stops there. Only an explicit "give me the whole thing at
once" collapses it, and even then the skeleton and concept table still lead.

## How it works

`SKILL.md` fixes the rhythm of the conversation:

1. **Skeleton turn.** 3–7 named parts, one sentence on how they connect, a table of
   the core concepts (short name + one-line gloss), then stop. No mechanism, no
   numbers, no identifiers.
2. **One block per turn.** Each following turn fills in a single block — what it is,
   why it exists, how it joins its neighbours, and what it now lets the reader
   answer. Then stop again. The reader says "继续" or names the next block.
3. **Close.** Bring the skeleton back, say in one sentence what each block now
   holds, and stop.

A block is one cluster of related concepts, capped at 7 new concepts the reader
must hold at once. Blocks are cut by *the problem being solved*, not by files,
chapters, classes or directories; a block that is too big becomes its own small
skeleton, one layer per turn.

**Concept names vs identifiers.** Concepts get a short Chinese phrase or a single
English word (关键路径, 可见性, fence, lease). Class names, function names and
config keys stay out of the prose; they appear once, in a code block or a mapping
table at the end, after the reader knows what to call the thing.

The same rhythm carries long documents and code: the skeleton becomes a map of the
document (what it settles, which parts argue or implement it, what order to read
them in), and each block becomes one claim or one call chain. Key claims carry
**源码事实 / 推断 / 待验证** (or **原文事实** for documents).

## Pairs with geeklens

When `geeklens` produces an annotated reading edition, `calm-explain` is the
explanation protocol for it: geeklens owns the artifact shape, calm-explain owns
the explanation style and evidence labels. `calm-explain` also works on its own.

## Install

Copy or symlink this directory into the agent's skills folder, keeping the
directory name equal to the `name:` field in the frontmatter (`calm-explain`):

```powershell
# OpenCode
Copy-Item -Recurse . "$env:USERPROFILE\.config\opencode\skills\calm-explain"

# Claude
Copy-Item -Recurse . "$env:USERPROFILE\.claude\skills\calm-explain"
```

Or with the Skills CLI:

```bash
npx skills add wurenrumian/calm-explain
```

## Contents

- `SKILL.md` — the skill itself: the turn rhythm, block size, concept naming,
  and the voice rules.
- `reference/examples.md` — a skeleton turn, a block turn with deferred
  identifiers, a long-document skeleton, a term card.
- `reference/math.md` — LaTeX conventions for answers that carry formulas.

## Related

- `geeklens` — focused annotated reading editions of real code (uses this skill's
  explanation protocol).
- `project-memory` — process memory under a project's `./tmp/`.
