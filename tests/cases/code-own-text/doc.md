The file's text goes after the block's own, on a line of its own: the
block's text, a newline, the file's. panclude does not look at the
block's text.

An empty block takes the file's text.

```{.table include="sales.csv"}
```

A block with text of its own keeps it.

```{#sales .table include="sales.csv" data-x="y"}
A line of the block's own.
```

A YAML header, then the file: the filter owning the class splits them.

```{.table include="sales.csv"}
---
caption: Sales by region
header: true
---
```

Text of the block's own ending in a blank line keeps it: a blank line
before the file's text.

```{.table include="sales.csv"}
---
caption: Sales by region
---

```

A failure leaves the block as it was, its own text too.

```{.table include="missing.csv"}
---
caption: Sales by region
---
```
