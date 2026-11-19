# Changelog

## Unreleased

- `panclude.lua`, the Lua filter for stock pandoc 3.2 or later: the
  `include` attribute on a code block (the file's text, with `startLine`,
  `endLine` and `dedent`), on a code block with `raw="FORMAT"` (raw
  content), and on a div (the file read as a document, with `format` and
  `shift-heading-level-by`, nested includes, and relative image and link
  paths rewritten). A failure leaves the element as it was, with a
  warning in pandoc's log.
- `tests/cases/`, the conformance cases of the specification, as plain
  files, and their runner, `pixi run test`.
- The cases of the step built into libpandoc (`only: builtin`): roots,
  as given and by default, symbolic links leaving them, pandoc's sandbox,
  `untrusted` with and without the host's roots, a cycle through a link,
  a format's own includes; `SPEC.md` has the built-in's rules and
  messages, and the case files `roots` and `untrusted`.
- `tools/port-include-files.lua` rewrites pandoc-ext/include-files'
  blocks into panclude's divs.
- The included content is appended to what the element holds instead of
  replacing it: a code block keeps its text (a YAML header of options for
  the filter owning its class), the file's text after it, and a div its
  blocks, the file's after them. panclude does not look at what the
  element holds, so it needs to know nothing of how the element is
  consumed, and without panclude the element shows what it holds.
