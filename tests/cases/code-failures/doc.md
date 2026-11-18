Each failure leaves the block exactly as it was, with a warning.

```{#id .c include="missing.txt" startLine=1 dedent=2 data-x=y}
a missing file
```

```{include="a-directory"}
a directory
```

```{include="https://example.org/x.txt"}
a URL
```

```{include="file:a-directory/file.txt"}
a file URL
```

```{include=""}
an empty path
```

```{include="missing.txt" raw="latex"}
the raw form
```
