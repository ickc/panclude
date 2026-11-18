A path is judged after symbolic links are resolved: a link staying inside
the roots is followed, one leading out of them is a failure.

```{include="in.txt"}
```

```{include="out.txt"}
placeholder
```

```{include="up/secret.txt"}
placeholder
```

A link out of the roots and back in again is inside:

```{include="up/book/ch.txt"}
```

::: {include="part-link.md"}
:::
