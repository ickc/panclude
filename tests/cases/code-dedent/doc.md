dedent=N removes up to N leading spaces of each line: not tabs, and not
spaces after other text.

```{include="indented.txt" dedent=4}
```

Zero removes nothing.

```{include="indented.txt" dedent=0}
```

With a range.

```{include="indented.txt" startLine=3 endLine=3 dedent=2}
```
