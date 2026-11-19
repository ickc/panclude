The file's blocks go after the div's own; the div keeps its identifier,
classes and other attributes, but not `include`, `format` and
`shift-heading-level-by`.

::: {#intro .chapter include="chapters/intro.md" shift-heading-level-by=0 format="markdown" lang="en"}
The div's own paragraph, before the file's blocks.
:::

An empty div is filled too.

::: {include="chapters/intro.md"}
:::
