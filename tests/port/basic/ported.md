# The document

::: {include="chapters/a.md"}
:::

::: {include="chapters/b.md"}
:::

::: {include="chapters/a.md" shift-heading-level-by="1"}
:::

::: {include="chapters/notes.txt" format="org"}
:::

An org file without a format: include-files reads it as markdown.

::: {include="chapters/c.org" format="markdown"}
:::

``` python
print("other code blocks are left alone")
```
