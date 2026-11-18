A format pandoc does not read, and a document that does not parse, are
failures; the message does not quote the file.

::: {include="x.md" format="nonsense"}
unknown format
:::

::: {include="x.md" format=""}
empty format
:::

::: {include="x.md" format="markdown+nonsense"}
unknown extension
:::

::: {include="bad.json" format="json"}
does not parse
:::

::: {include="bad.json"}
does not parse, its format from its extension
:::
