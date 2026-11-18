The built-in reads only inside its roots: by default the main document's
directory (here book/) and below. A path is judged as written (`.` and
`..` by its text), whether or not the file exists.

```{include="ch.txt"}
```

```{include="sub/../ch.txt"}
```

```{include="../book/sub/x.txt"}
```

Outside:

```{include="../secret.txt"}
placeholder
```

```{include="sub/../../secret.txt"}
placeholder
```

```{include="../missing.txt"}
placeholder
```

```{include="/etc/passwd"}
placeholder
```

::: {include="../secret.txt"}
placeholder
:::
