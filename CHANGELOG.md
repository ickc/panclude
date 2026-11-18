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
- `tools/port-include-files.lua` rewrites pandoc-ext/include-files'
  blocks into panclude's divs.
