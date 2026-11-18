The file's blocks fill the div, in place of what was there; the div keeps
its identifier, classes and other attributes, but not `include`, `format`
and `shift-heading-level-by`.

::: {#intro .chapter include="chapters/intro.md" shift-heading-level-by=0 format="markdown" lang="en"}
shown when the step does not run
:::

An empty div is filled too.

::: {include="chapters/intro.md"}
:::
