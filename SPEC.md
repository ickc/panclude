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

### A code block: the file's text, verbatim

````markdown
```{.haskell include="src/Main.hs" startLine=10 endLine=24 dedent=2}
shown when the step does not run
```
````

- The block's text becomes the file's text: read as UTF-8 (a byte order
  mark dropped), line endings as `\n`, the final newline dropped (a code
  block's text has none).
- `startLine`, `endLine` (also `start-line`, `end-line`): lines counted
  from 1, both ends included. `dedent=N`: up to N leading spaces removed
  from each line. These are pandoc-ext include-code-files' names, and the
  same documents give the same result (but for where a relative path
  starts, section 2).
- Afterwards `include`, the range and `dedent` are removed from the
  block. With `startLine` and no `startFrom` of its own, `startFrom` is
  set to it, so that `.numberLines` shows the source's numbers.
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
text (ranges and `dedent` as above).

### A div: the file as a document, filling the div

```markdown
::: {include="chapters/intro.md" shift-heading-level-by=1}
shown when the step does not run
:::
```

- The file is read as a document and its blocks become the div's content,
  in place of what was there. The div stays, without `include`, `format`
  and `shift-heading-level-by`.
- **Format (open):** the div's `format` (as pandoc's `-f` takes it)
  if given; else, when the file's extension names a format other than
  markdown (`.rst`, `.org`, `.tex`, `.html`, ...), that format with
  pandoc's defaults; else the main document's reader and its options. The
  built-in knows the main reader exactly. A Lua filter under stock pandoc
  is told its extensions (`PANDOC_READER_OPTIONS`) but not its name, and
  assumes `markdown`; under a libpandoc host it is told
  (`PANDOC_INPUT_FORMAT`).
- `shift-heading-level-by=N`: N added to the level of each heading of the
  included document; a level below 1 becomes a paragraph, as pandoc's own
  option makes it.
- The included document's metadata is dropped.
- Its footnotes and reference links are its own, as with `--file-scope`:
  this is the filter shape, not the preprocessor's.
- **Nested includes** are resolved, each relative to the file that holds
  it, to a depth of 32; a file including itself, directly or not, is a
  failure (section 3).
- **Relative paths in the included content (open):** an image's or
  a link's target that is a relative path is rewritten so that it names
  the same file from the main document's directory (as pandoc-ext
  include-files and pandoc's `rebase_relative_paths` do).

An `include` attribute on any other element is left alone.

## 2. Paths, and what may be read

- A relative `PATH` starts at the directory of the file that holds the
  element: the main document's first input file, or the working directory
  when it comes from standard input.
- No URLs, no globs, no `~`.
- **`panclude.lua`** reads what pandoc's Lua can read: anything the
  process can. Its documentation says so.
- **The built-in** reads only inside its roots: by default the main
  document's directory and below **(open)**; the host may give
  others. A path is checked after symbolic links are resolved. With
  libpandoc's `untrusted`, there are no roots unless the host gives some,
  so every include fails. In the directory sandbox the mounts are all
  there is.

## 3. Failures

A file missing, unreadable or outside the roots, a range that selects
nothing, text that is not UTF-8, a format pandoc does not know, a document
that does not parse, a cycle, the depth limit:

- **the element is left exactly as it was**, attribute and placeholder,
  and
- **a warning** through pandoc's log names the path, the reason, and the
  file holding the element **(open)**: so pandoc's
  `--fail-if-warnings` is the strict mode, and without it the document
  degrades as it does where the step is absent.

No message shows a file's content.

## 4. Order

The step runs before every other filter: `-L panclude.lua` first on a
pandoc command line; in a libpandoc host, the reserved name `panclude` in
the filter list, as `citeproc` is one. An element it handled no longer has
`include`, so running it twice changes nothing.

## 5. Left out

The preprocessor shape (text spliced in before parsing); metadata from a
file (`--metadata-file`); data a filter needs that is not an include (a
bibliography: `citeproc-files`); binary formats; URLs.

## 6. What existing documents need

- pandoc-ext include-code-files: nothing, but for a document outside the
  working directory (its paths start at the working directory).
- pandoc-ext include-files: a porting filter rewrites each
  ```` ```{.include} ```` block into one div a file, its automatic heading
  shift written out as `shift-heading-level-by`.
- A filter with an include of its own for its block's content (pantable's
  `include:` key in the block's YAML): the file name moves to the
  attribute, and the block keeps its options.

## 7. Conformance

A directory of cases, each a document, the files it names, the expected
document as pandoc's JSON, and the expected warnings. One runner runs
every case against `pandoc -L panclude.lua` and against a libpandoc host
with the built-in; the cases about roots, `untrusted` and the sandbox are
the built-in's alone.
