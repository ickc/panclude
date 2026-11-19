An empty file, without a range, is an empty block.

```{include="empty.txt"}
```

A file of one empty line is an empty block too.

```{include="newline.txt"}
```

Two empty lines are a newline.

```{include="two-newlines.txt"}
```

After text of the block's own, an empty file adds no line, and a file of
one empty line adds one.

```{include="empty.txt"}
own text
```

```{include="newline.txt"}
own text
```

```{include="two-newlines.txt"}
own text
```
