An included document's own elements with content and includes: each
gets the file's content after its own, its own includes are done from
the file holding it, and its paths, own and included, are rewritten to
name the same files from the main document's directory.

::: {include="parts/a.md"}
:::
