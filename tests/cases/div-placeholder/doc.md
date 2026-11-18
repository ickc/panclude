A div's placeholder is not looked into: replaced when its include
succeeds, as it was when it fails.

::: {include="part.md"}
```{include="missing-in-placeholder.txt"}
```
:::

::: {include="missing.md"}
```{include="code.txt"}
```
:::
