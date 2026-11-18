Without `format`, a file whose extension names a format other than
markdown is read in that format, with pandoc's defaults.

::: {include="a.rst"}
:::

::: {include="b.org"}
:::

::: {include="c.html"}
:::

::: {include="d.tex"}
:::

Markdown, and a file with no extension pandoc knows, are read as the main
document is.

::: {include="e.txt"}
:::

::: {include="f"}
:::
