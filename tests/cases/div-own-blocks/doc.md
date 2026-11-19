The file's blocks go after the div's own. panclude does not look at the
div's own blocks, but for their includes: `shift-heading-level-by` shifts
the file's headings only.

::: {#ch .chapter include="chapter.md" shift-heading-level-by=1}
## A heading of the div's own

An introduction of the div's own.

- a list
- of the div's own
:::

A paragraph with a leading span, as pandoc-amsthm takes a theorem's
note: it stays the div's first paragraph, and the file's blocks follow.

::: {.theorem include="theorem.md"}
[Pythagoras]{.info}
:::

::: {.theorem include="theorem.md"}
[Pythagoras]{.info} An introduction of the theorem's own.
:::
