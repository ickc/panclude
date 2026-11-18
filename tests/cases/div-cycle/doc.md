A file including itself, directly or not, is a failure: the element that
would close the cycle is left as it was.

::: {include="a.md"}
:::

::: {include="doc.md"}
the main document itself
:::

The same file twice, side by side, is no cycle.

::: {include="b2.md"}
:::

::: {include="b2.md"}
:::
