Lines 3 to 5; startFrom is set to startLine.

```{.numberLines include="lines.txt" startLine=3 endLine=5}
```

From line 8 to the end.

```{include="lines.txt" startLine=8}
```

Up to line 2: no startFrom without startLine.

```{include="lines.txt" endLine=2}
```

One line.

```{include="lines.txt" startLine=4 endLine=4}
```

An end past the last line ends at the last line.

```{include="lines.txt" startLine=9 endLine=99}
```

A startFrom of the block's own stays.

```{.numberLines include="lines.txt" startLine=3 endLine=4 startFrom=100}
```

Leading zeros are decimal.

```{include="lines.txt" startLine=07 endLine=08}
```
