Ranges and `dedent` apply to the file's text only; the block's own text
stays as it is.

```{include="lines.txt" startLine=2 endLine=3 dedent=4}
    the block's own, indented
```

With `.numberLines` and no text of the block's own, `startFrom` is set
to `startLine`, so that the lines show the source's numbers.

```{.numberLines include="lines.txt" startLine=4}
```

With text of the block's own before the file's lines, it is not set.

```{.numberLines include="lines.txt" startLine=4}
own text
```

A `startFrom` of the block's own stays, with text of its own or not.

```{.numberLines include="lines.txt" startLine=4 startFrom=10}
own text
```

```{.numberLines include="lines.txt" startLine=4 startFrom=10}
```
