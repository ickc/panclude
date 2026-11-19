With `raw`, the raw block holds the same text: the block's own, a
newline, the file's.

```{include="header.tex" raw="latex"}
\documentclass{article}
```

Ranges and `dedent` apply to the file's text only.

```{include="header.tex" raw="latex" startLine=2 dedent=4}
    % the block's own, indented
```
