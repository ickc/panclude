# panclude: specification (draft)

One behaviour, two implementations: `panclude.lua`, a Lua filter for stock
pandoc, run first; and a step built into libpandoc, named in the filter
list. The attribute is `include`; a div's include fills the div; raw
content is `raw=FORMAT` beside it.

This draft fixes the details both implementations must agree on. Points
marked **(open)** may still change. Nothing is released.

## 1. What is included

An element pandoc's reader has parsed carries `include="PATH"`. The step
replaces the element's content with the file's and never interprets the
content beyond what the element says.

A number in an attribute the step reads is a whole number written in
decimal digits (`7`, `07`; `-1` only where said); anything else
(`0x7`, `1.0`, `x`, empty) is a failure (section 3).

### A code block: the file's text, verbatim

````markdown
```{.haskell include="src/Main.hs" startLine=10 endLine=24 dedent=2}
shown when the step does not run
```
````

- The block's text becomes the file's text: read as UTF-8 (a byte order
  mark at its start dropped), line endings as `\n` (CRLF and a lone CR
  alike), the final newline dropped (a code block's text has none). A
  file's lines are what the newlines separate, the final newline ending
  the last line: an empty file has none, a file of one newline has one,
  empty.
- `startLine`, `endLine` (also `start-line`, `end-line`; given both
  spellings, the hyphenated one is used, as include-code-files does):
  lines counted from 1, both ends included; a number from 1. An
  `endLine` past the last line ends at the last line. A range that
  selects no line (a `startLine` past the last line or after `endLine`,
  any range of an empty file) is a failure; an empty file without a
  range is an empty block.
- `dedent=N`: up to N leading spaces removed from each line; a number
  from 0. Only spaces before the line's first other character count; a
  tab is another character.
- These are pandoc-ext include-code-files' names, and its documents give
  the same result, but for where a relative path starts (section 2),
  `dedent` (include-code-files removes every space among a line's first
  N characters, even after other text), and in corners that filter does
  not handle (its text keeps the final newline and any CR; a failure
  there empties the block; it sets `startFrom` over the block's own).
- Afterwards `include`, the range (both spellings) and `dedent` are
  removed from the block. With `startLine` and no `startFrom` of its own,
  `startFrom` is set to it, as a number (`07` gives `7`), so that
  `.numberLines` shows the source's numbers. (pandoc reads `startFrom`,
  not `start-from`.)
- Everything else on the block stays, so the filter that owns its class
  (a table from CSV, a diagram) sees a block that held the text all
  along.
- Not in this version **(open)**: named snippets
  (pandoc-include-code's `snippet=NAME`), inline code, spans.

### A code block with `raw="FORMAT"`: raw content

````markdown
```{include="header.tex" raw="latex"}
```
````

The block is replaced by a raw block of that format holding the file's
text (ranges and `dedent` as above). A raw block has no attributes: the
code block's identifier, classes and other attributes go with it. An
empty `raw` is a failure.

### A div: the file as a document

```markdown
::: {include="chapters/intro.md" shift-heading-level-by=1}
shown when the step does not run
:::
```

- The file is read as a document and its blocks become the div's content,
  in place of what was there. The div stays, without `include`, `format`
  and `shift-heading-level-by`. The placeholder is never looked into: an
  include inside it is not read, whether the div's include succeeds or
  fails.
- **Format (open):** the div's `format` (as pandoc's `-f` takes it,
  extensions included) if given, with pandoc's defaults for that format;
  else, when the file's extension names a format other than markdown
  (`.rst`, `.org`, `.tex`, `.html`, ..., as pandoc names a format from
  a file name: `.txt` is markdown), that format with pandoc's defaults;
  else the main document's reader and its extensions. The built-in knows
  the main reader exactly. A Lua filter is told the reader's extensions
  (`PANDOC_READER_OPTIONS`) but not its name. Under a libpandoc host the
  environment variable `PANDOC_INPUT_FORMAT` names it, extensions
  included (`commonmark_x-smart`), and the filter uses that. Stock pandoc
  does not set it: the filter assumes markdown, with the document's
  extensions when markdown has them all, else with markdown's defaults
  (the main reader is then not markdown, and its extensions do not fit).
- The file is read with the main document's other reader options (tab
  stop, default image extension, ...), but as a part of a document, not
  a standalone one: so a reader such as rst's does not take a lone first
  heading for the title, which would then go with the metadata.
- `shift-heading-level-by=N`: N, a number that may be negative, added to
  the level of each heading of the included document, those it includes
  in turn too (so shifts add up through nesting). A level below 1 becomes
  a paragraph of the heading's text, as pandoc's own option makes it
  (pandoc's exception, a heading taken for the title, does not arise:
  the metadata is dropped).
- The included document's metadata is dropped.
- Its footnotes and reference links are its own, as with `--file-scope`:
  this is the filter shape, not the preprocessor's.
- **Nested includes** are resolved, each relative to the file that holds
  it, to a depth of 32: the main document's includes are at depth 1,
  theirs at depth 2, and an include at depth 33, of either kind, is a
  failure. A div including a file that is including it, directly or not
  (the main document included), is a failure (section 3); the same file
  twice side by side is not. A code block may include any file, the one
  holding it too: it reads no further. The Lua filter tells two files
  apart by their paths, with `.` and `..` resolved as text, so a cycle
  through a symbolic link or a name differing in case ends at the depth
  limit; the built-in resolves links.
- **Relative paths in the included content (open):** an image's or
  a link's target that is a relative path is rewritten so that it names
  the same file from the main document's directory. A target is a
  relative path unless it is empty, starts with `#`, `?`, `/` or `\`, or
  starts with a URL scheme (letters, then `:`, which takes in a Windows
  drive such as `C:`). It is rewritten by putting the directory part of
  the `include` path in front, as written, with `/` (on Windows, `\` in
  the `include` path counts as `/`), and a leading `./` of either
  dropped: `![](img.png)` in `chapters/a.md` becomes
  `![](chapters/img.png)`. `..` is kept (`chapters/../img.png`), as
  pandoc's own `rebase_relative_paths` keeps it, which leaves symbolic
  links to the system. Done at each level of nesting, this names the file
  from the main document's directory. The `include` of an element whose
  include failed inside included content is rewritten the same way, so
  that it still names the same file. Raw content is not looked into.

An `include` attribute on any other element (a span, inline code, a
heading, an image, a link, ...) is left alone, without a warning.

## 2. Paths, and what may be read

- A relative `PATH` starts at the directory of the file that holds the
  element: for the main document, its first input file's (pandoc joins
  several input files into one document before any filter runs, so
  which one an element came from is not known), or the working directory
  when it comes from standard input.
- A path is taken as written: no globs, no `~`. A URL (a scheme of two
  letters or more, then `:`, such as `https:` or `file:`) is a failure,
  and so is an empty path. When the main document is itself read from a
  URL, every include fails: there is no directory to start from.
- **`panclude.lua`** reads what pandoc's Lua can read: anything the
  process can. Its documentation says so.
- **The built-in** reads only inside its roots: by default the main
  document's directory and below **(open)**; the host may give
  others. A path is checked after symbolic links are resolved. With
  libpandoc's `untrusted`, there are no roots unless the host gives some,
  so every include fails. In the directory sandbox the mounts are all
  there is.

## 3. Failures

A file missing, unreadable or outside the roots, an attribute's number
that is not one (section 1), an empty `raw`, a range that selects
nothing, text that is not UTF-8, a format pandoc does not know, a
document that does not parse, a cycle, the depth limit, a URL, an empty
path, a main document read from a URL:

- **the element is left exactly as it was**, attribute and placeholder
  (but for the rewriting of its path when it is inside included content,
  section 1), and
- **a warning** through pandoc's log names the path, the reason, and the
  file holding the element **(open)**: so pandoc's
  `--fail-if-warnings` is the strict mode, and without it the document
  degrades as it does where the step is absent.

No message shows a file's content: pandoc's own message when a document
does not parse can quote it, so it is not passed on. The message is

```
panclude: cannot include "PATH" in FILE: REASON
```

with `PATH` as the element gives it, `FILE` the file holding the element
(the main document's first input file as given on the command line,
`standard input`, or an included file's path as opened, from the working
directory), and `REASON` one of:

| failure | `REASON` |
|---|---|
| no such file | `not found` |
| the file cannot be opened or read (a directory, no permission) | `cannot be read` |
| outside the roots (the built-in) | `outside the roots` |
| a number that is not one | `startLine="x" is not a whole number from 1` (also `endLine`, `start-line`, `end-line`, as written); `dedent="x" is not a whole number`; `shift-heading-level-by="x" is not a whole number` |
| an empty `raw` | `raw="" names no format` |
| a range that selects nothing | `the range selects none of the file's N lines` |
| not UTF-8 | `not UTF-8` |
| an unknown format, an extension the format does not have, a document that does not parse | `pandoc cannot read it as "FORMAT"` |
| a cycle | `a cycle: the file is already being included` |
| the depth limit | `more than 32 nested includes` |
| a URL | `a URL is not a path` |
| an empty path | `the path is empty` |
| the main document read from a URL | `the document is a URL, so no file is included` |

When an element has more than one fault, the first of these checks
gives the reason: the element's attributes, the path, the depth, a
cycle, the file, its range, its format.

The Lua filter warns with `pandoc.log.warn`, which pandoc 3.2 added; it
needs pandoc 3.2 or later. Its warnings are `ScriptingWarning`s in
pandoc's log (`--log`), the message as above.

## 4. Order

The step runs before every other filter: `-L panclude.lua` first on a
pandoc command line; in a libpandoc host, the reserved name `panclude` in
the filter list, as `citeproc` is one. An element it handled no longer has
`include`, so running it twice changes nothing, but for an element whose
include failed, which the second run tries again (with a warning again;
for a cycle or the depth limit, one level further).

## 5. Left out

The preprocessor shape (text spliced in before parsing); metadata from a
file (`--metadata-file`); data a filter needs that is not an include (a
bibliography: `citeproc-files`); binary formats (their files are not
UTF-8 text, so they fail as such); URLs.

## 6. What existing documents need

- pandoc-ext include-code-files: nothing, but for a document outside the
  working directory (its paths start at the working directory), `dedent`
  of lines with spaces after other text, and the corners of section 1.
- pandoc-ext include-files: a porting filter
  (`tools/port-include-files.lua`) rewrites each ```` ```{.include} ````
  block into one div a file, its automatic heading shift written out as
  `shift-heading-level-by`.
- A filter with an include of its own for its block's content (pantable's
  `include:` key in the block's YAML): the file name moves to the
  attribute, and the block keeps its options.

## 7. Conformance

A directory of cases, `tests/cases/`, one directory a case. One runner
runs every case against `pandoc -L panclude.lua` (`spec/cases_spec.lua`),
another will run them against a libpandoc host with the built-in; the
cases about roots, `untrusted` and the sandbox will be the built-in's
alone. A case is plain files, in the case's directory, which is the
working directory pandoc runs in:

| file | |
|---|---|
| `doc.md` | the document, and beside it the files it names |
| `args` | optional: pandoc's arguments, one a line, the document's path among them; without it, `doc.md`. A line with `{panclude}` stands for the step there (the Lua runner puts the filter's path in its place: `--lua-filter={panclude}`); without such a line, the runner puts the step first |
| `stdin` | optional: the document, given on standard input; then `args` defaults to none |
| `env` | optional: `NAME=VALUE` lines, set in pandoc's environment (`PANDOC_INPUT_FORMAT` is otherwise empty for the Lua filter) |
| `only` | optional: `lua` or `builtin`, the one implementation the case is for |
| `expected.native` | the document expected, as pandoc's native format; the runner reads it with the same pandoc and compares the two as that pandoc writes them (`-s -t native`), so the native writer's layout, which changes between versions, does not matter. Absent when pandoc is expected to fail |
| `warnings` | optional: the warnings expected, one a line, in order, as pandoc's log (`--log`) gives them: a filter's `message`, any other warning's `pretty` text. Without it, none |
| `status` | optional: pandoc's exit status expected; without it, 0 |

`pixi run gen-cases NAME` writes `expected.native`, `warnings` and
`status` from what the filter does, for review before they are
committed.
