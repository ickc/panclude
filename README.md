# panclude

One `include` attribute for pandoc documents. An element that pandoc's
reader has already parsed names a file, and panclude appends the file's
content to what the element holds:

````markdown
```{.haskell include="src/Main.hs" startLine=10 endLine=24}
```

```{include="header.tex" raw="latex"}
```

::: {include="chapters/intro.md" shift-heading-level-by=1}
:::
````

- **A code block** gets the file's text, verbatim, after its own.
  Whichever filter owns the block's class (a table from CSV, a diagram)
  then sees a block that held the text all along.
- **A code block with `raw="FORMAT"`** becomes raw content for that output
  format.
- **A div** gets the file's blocks, read as a document, after its own.

**Status: a draft.** [SPEC.md](SPEC.md) is the specification being worked
out; `panclude.lua` implements it, and `tests/cases/` holds the cases
both implementations must pass. Nothing is released yet.

## Usage

### Install

panclude is one Lua file with no dependencies. It needs pandoc 3.2 or
later, and stops with an error on an older one.

```sh
curl -LO https://raw.githubusercontent.com/ickc/panclude/main/panclude.lua
```

### Run it first

```sh
pandoc -L panclude.lua -L other-filter.lua doc.md -o doc.html
```

Put it before every other filter, so that each of them sees the included
content as if it had been written in the document. It handles an element
once: a second run changes nothing but retries what failed.

### A code block: a file's text

````markdown
```{.python .numberLines include="src/main.py" startLine=10 endLine=24 dedent=4}
```
````

An empty block's text becomes the file's text, verbatim (as UTF-8, with
`\n` line endings, without its final newline); a block with text of its
own keeps it, and the file's text follows on the next line (below).
`startLine` and `endLine` (also `start-line`, `end-line`) choose the
file's lines, counted from 1, both included; `dedent=N` removes up to N
leading spaces of each of them. These attributes and `include` go;
everything else stays. When the file's lines are the block's first (no
text of its own) and the block has no `startFrom`, `startFrom` is set to
`startLine`, so that `.numberLines` counts as the source does. A filter
owning the class sees an ordinary block:

````markdown
```{.table include="data.csv"}
```
````

### A code block with `raw`: raw content

````markdown
```{include="preamble.tex" raw="latex"}
```
````

The block becomes a raw block of that format, holding the text the code
block would get (its own, then the file's; ranges and `dedent` as
above).

### A div: a file read as a document

```markdown
::: {#intro .chapter include="chapters/intro.md" shift-heading-level-by=1}
:::
```

The file's blocks go after the div's own; the div keeps its identifier,
classes and other attributes. The file is read

- as the div's `format` says (as `-f` takes it: `format="org"`,
  `format="markdown-smart"`);
- else in the format its extension names, if not markdown (`.rst`,
  `.org`, `.html`, `.tex`, ...);
- else as markdown, with the main document's extensions. Under stock
  pandoc a Lua filter is not told the main reader's name: if your
  document is not pandoc's markdown, give `format` (a libpandoc host
  tells the filter, in `PANDOC_INPUT_FORMAT`).

`shift-heading-level-by=N` shifts its headings (below level 1 a heading
becomes a paragraph). Its metadata is dropped; its footnotes and
reference links are its own. Its own includes are resolved too, each
from its file's directory, 32 deep at most; a file including itself,
directly or not, is a failure (below). An image's or link's relative path in it
is rewritten to name the same file from the main document's directory:
`![](fig.png)` in `chapters/intro.md` becomes `![](chapters/fig.png)`.
URLs, absolute paths and `#fragments` are left alone.

### Content of the element's own

panclude appends: what the element holds stays, before the included
content. It does not look at that content, so whatever consumes the
element tells the two apart. A table filter's options, as a YAML header,
stay with the block, and the data comes from the file:

````markdown
```{.table include="sales.csv"}
---
caption: Sales by region
header: true
---
```
````

The block's text is then the header, a newline, then `sales.csv`'s text;
the filter owning `.table` splits them as it would if the data had been
written in the block. A div keeps its leading paragraph, and the file's
blocks follow:

```markdown
::: {.theorem include="pythagoras.md"}
[Pythagoras]{.info}
:::
```

Without panclude, the element shows what it holds. An empty file adds
nothing; `startLine`, `endLine`, `dedent` and `shift-heading-level-by`
apply to the included content only. An include inside a div's own blocks
is done as any other, from the file holding the div.

### Paths

A relative path starts at the directory of the file holding the element:
the main document's (its first input file's, with several), the
working directory for standard input, an included file's for its own
includes. A path is used as written: no globs, no `~`, no URLs.

### Failures

A missing file, a range that selects nothing, text that is not UTF-8, a
format pandoc cannot read, a cycle: the element is left exactly as it
was, its content and all, and a warning goes to pandoc's log, naming the
path, the file holding it and the reason, never the file's content:

```
[WARNING] Scripting warning at panclude.lua line 157 column 1: panclude: cannot include "src/mian.py" in doc.md: not found
```

The document degrades as it would without panclude. To make a failure
an error, run pandoc with `--fail-if-warnings`.

### What it does not do

- Named snippets, inline code and spans: not in this version.
- URLs, binary formats (docx, xlsx, ...), metadata from a file (use
  `--metadata-file`), text spliced in before pandoc parses the document.
- **It does not restrict what it reads.** The filter reads whatever
  pandoc's Lua can read: any file the process can, `../` and absolute
  paths included. Run it only on documents you trust, or run pandoc
  where it can read only what it may. The step built into libpandoc
  reads only inside the directories it is given.

### From pandoc-ext/include-code-files

Its documents work unchanged and give the same result, but for three
deliberate differences:

- **A relative path starts at the including file's directory**, not at
  pandoc's working directory. The two are the same when you run pandoc
  from the document's directory.
- **`dedent=N` removes up to N leading spaces of a line.**
  include-code-files removes every space among a line's first N
  characters, even after other text (`x   y` with `dedent=4` becomes
  `xy`).
- **A block with text keeps it**, and the file's text follows;
  include-code-files replaces the block's text with the file's. For an
  empty block, the usual case, the two agree.

And in corners: panclude drops the file's final newline (include-code-files
keeps it, which shows as an empty last line in HTML) and any CR, keeps a
`startFrom` the block already has, and on a failure leaves the block as it
was where include-code-files empties it.

### From pandoc-ext/include-files

panclude does not read include-files' block of file names. The porting
filter `tools/port-include-files.lua` rewrites a document's blocks into
panclude's divs, one a file, with the automatic heading shift
(`include-auto`) written out as `shift-heading-level-by`:

```sh
pandoc doc.md -s -f markdown -t markdown -L tools/port-include-files.lua -o ported.md
```

````markdown
```{.include shift-heading-level-by=1}       ::: {include="a.md" shift-heading-level-by=1}
a.md                                    →    :::
// a comment
b.md                                         ::: {include="b.md" shift-heading-level-by=1}
```                                          :::
````

- Run it from the directory you ran pandoc from with include-files:
  include-files opens a name from the working directory, and the port
  rewrites it to start at the document's directory.
- An included file with blocks of its own: port it too, from its own
  directory (include-files reads its names from there), with
  `-M include-auto` if the main document had it.
- Without `format`, include-files reads every file as markdown with
  pandoc's default extensions; the port writes `format="markdown"` where
  panclude would read the file otherwise (a `.org` file, a document read
  with other extensions).
- Each block ported is listed on stderr with the divs it became, so that
  a document pandoc's markdown writer would damage can be ported by hand
  (`-o /dev/null`).

The result differs from include-files' in what panclude does
differently: each file's content is in a div; an image's or link's path
is rewritten from the document's directory, not the working directory,
and a URL in an image is left alone (include-files rewrites
`https://...` images as paths); a heading shifted below level 1 becomes
a paragraph.

## Development

The tests run under pandoc's bundled Lua, so pandoc is the only
dependency; [pixi](https://pixi.sh) provides it:

```sh
pixi run test                      # every spec, with the latest pandoc
pixi run -e pandoc-min test        # with the oldest supported, pandoc 3.2
pixi run gen-cases NAME            # rewrite what a case expects; review with git diff
```

[SPEC.md](SPEC.md), section 7, describes the cases' files, for a runner
of another implementation. The cases marked `only: builtin` (roots,
symbolic links, `untrusted`, pandoc's sandbox) are the step built into
libpandoc's, whose CI runs every case against it; `pixi run test` skips
them.

## Why an attribute

- pandoc's reader parses the element, so the include works wherever the
  element does: in a list, a block quote, a table cell.
- Nothing needs escaping. To show the syntax in a document, put it in a
  code block: nothing looks inside one.
- Without panclude the document still reads: the element shows what it
  holds, and panclude only adds to it.
- Including is one step, done first. A filter that needs a file's content
  does not have to read files itself.

## Two forms of the same behaviour

- `panclude.lua`, a Lua filter for stock pandoc, run before any other
  filter: `pandoc -L panclude.lua ...`. It reads whatever pandoc's Lua can
  read.
- The same step built into [libpandoc](https://github.com/ickc/libpandoc)
  and its bindings, named among the filters as `panclude` (`-F panclude`,
  `"filters": ["panclude", ...]`), where it reads only inside its roots:
  the main document's directory, or the directories it is given
  (`{"type": "panclude", "roots": [...]}`), none under pandoc's sandbox
  or for untrusted options unless given. So a filter run after it needs
  no access to files at all.

One specification and one set of cases hold for both.

## Prior art

The attribute names for code are those of
[pandoc-ext/include-code-files](https://github.com/pandoc-ext/include-code-files)
and [pandoc-include-code](https://github.com/owickstrom/pandoc-include-code),
whose documents work unchanged.
[pandoc-ext/include-files](https://github.com/pandoc-ext/include-files)
includes sub-documents from a code block listing files, and
[panda](https://github.com/CDSoft/panda) has an `include` attribute on
divs and code blocks. pandoc's own discussion of includes is
[jgm/pandoc#553](https://github.com/jgm/pandoc/issues/553).

## License

BSD-3-Clause; see [LICENSE](LICENSE).
