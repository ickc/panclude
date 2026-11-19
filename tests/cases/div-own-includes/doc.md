A div's own blocks are the document's: their includes are done, from the
file holding the div, whether the div's include succeeds or fails. The
div's include comes first: the warnings of the file it includes come
before those of its own blocks.

::: {include="part.md"}
```{include="code.txt"}
```

```{include="missing-own.txt"}
own text
```
:::

::: {include="missing.md"}
```{include="code.txt"}
```
:::
