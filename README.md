# panclude

One `include` attribute for pandoc documents. An element that pandoc's
reader has already parsed says which file its content comes from, and
panclude fills it in:

````markdown
```{.haskell include="src/Main.hs" startLine=10 endLine=24}
```

```{include="header.tex" raw="latex"}
```

::: {include="chapters/intro.md" shift-heading-level-by=1}
:::
````

- **A code block** takes the file's text, verbatim. Whichever filter owns
  the block's class (a table from CSV, a diagram) then sees a block that
  held the text all along.
- **A code block with `raw="FORMAT"`** becomes raw content for that output
  format.
- **A div** is filled with the file read as a document.

**Status: a draft.** [SPEC.md](SPEC.md) is the specification being worked
out; the Lua filter and its test cases are being written. Nothing is
released yet.

## Why an attribute

- pandoc's reader parses the element, so the include works wherever the
  element does: in a list, a block quote, a table cell.
- Nothing needs escaping. To show the syntax in a document, put it in a
  code block: nothing looks inside one.
- Without panclude the document still reads: the element shows whatever
  placeholder it holds.
- Including is one step, done first. A filter that needs a file's content
  does not have to read files itself.

## Two forms of the same behaviour

- `panclude.lua`, a Lua filter for stock pandoc, run before any other
  filter: `pandoc -L panclude.lua ...`. It reads whatever pandoc's Lua can
  read.
- The same step built into [libpandoc](https://github.com/ickc/libpandoc)
  and its bindings, where it reads only inside the directories it is
  given, so that a filter run after it needs no access to files at all.

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
