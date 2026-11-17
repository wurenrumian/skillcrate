# calm-explain

An agent skill for explaining things well.

`calm-explain` writes the way a patient colleague would draw on a whiteboard:
a skeleton of named parts and a concept table up front, then one block per
section in dependency order, closing by fitting the parts back into the
skeleton. The reader sets their own pace; the skill decides what is in view at
any point — never more than a handful of new concepts per section.

## When it applies

Whenever the user asks to explain, clarify, walk through, compare, teach,
annotate, or understand why something behaves a certain way — even when they do
not say "explain". Also for requests like 讲讲 / 解释一下 / 分层讲 / 一块一块讲.

## How it works

`SKILL.md` fixes the shape of the answer:

1. **Skeleton up front.** 3–7 named parts, one sentence on how they connect, a
   table of the core concepts (short name + one-line gloss), then a transition
   that names the order the blocks will follow. No mechanism, no numbers, no
   identifiers.
2. **One block per section.** Each section fills in a single block — what it
   is, why it exists, how it joins its neighbours — and closes with a
   transition sentence. Sections follow dependency order; a different order is
   announced with a reason.
3. **Close.** Bring the skeleton back and say in one sentence what each block
   now holds.

A block is one cluster of related concepts, capped at 7 new concepts the reader
must hold at once. Blocks are cut by *the problem being solved*, not by files,
chapters, classes or directories; a block that is too big becomes its own small
skeleton, one layer per section.

**Concept names vs identifiers.** Concepts get a short Chinese phrase or a
single English word (关键路径, 可见性, fence, lease). Class names, function names
and config keys stay out of the prose; they appear once, in a code block or a
mapping table at the end, after the reader knows what to call the thing.

**Diagrams where it gets dense.** When the relations between concepts and
symbols cannot be laid out in prose without strain — many connections,
branching, irreversible ordering, state transitions — the section carries a
Mermaid diagram (flowchart, sequence, state) instead of a run-on sentence.
Nodes use concept short names; identifiers stay out of the diagram.

The same shape carries long documents and code: the skeleton becomes a map of
the document (what it settles, which parts argue or implement it, what order to
read them in), and each block becomes one claim or one call chain. Key claims
carry **源码事实 / 推断 / 待验证** (or **原文事实** for documents).

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

- `SKILL.md` — the skill itself: the document shape, block size, concept
  naming, diagram placement, and the voice rules.
- `reference/examples.md` — an opening skeleton, a block section with deferred
  identifiers, a long-document skeleton, a term card, a Mermaid sequence
  diagram.
- `reference/math.md` — LaTeX and symbol conventions for answers that carry
  formulas.

## Related

- `geeklens` — focused annotated reading editions of real code (uses this skill's
  explanation protocol).
- `mermaid-diagrams` — syntax reference when diagrams get involved.
- `project-memory` — process memory under a project's `./tmp/`.
