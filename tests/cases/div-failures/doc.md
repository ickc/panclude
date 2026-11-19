Each failure leaves the div exactly as it was, attributes and content,
with a warning.

::: {#id .cls include="missing.md" shift-heading-level-by=1 format="markdown" data-x="y"}
a missing file
:::

::: {include="a-directory"}
a directory
:::

::: {include="https://example.org/x.md"}
a URL
:::

::: {include=""}
an empty path
:::

::: {include="latin1.md"}
not UTF-8
:::
