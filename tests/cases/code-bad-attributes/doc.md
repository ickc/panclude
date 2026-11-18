A line number is a whole number from 1, and dedent a whole number, in
decimal: anything else is a failure, and the block is left as it was.

```{include="x.txt" startLine="x"}
not a number
```

```{include="x.txt" startLine=0}
zero
```

```{include="x.txt" endLine="-1"}
negative
```

```{include="x.txt" startLine="0x1"}
hexadecimal
```

```{include="x.txt" end-line="1.0"}
a fraction, hyphenated
```

```{include="x.txt" dedent="2.0"}
a fraction
```

```{include="x.txt" dedent="-1"}
negative
```

```{include="x.txt" dedent=""}
empty
```
