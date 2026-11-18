# The document

```{.include}
chapters/a.md

// a comment, and an empty line above
chapters/b.md
```

```{#id .include shift-heading-level-by=1}
chapters/a.md
```

```{.include format="org"}
chapters/notes.txt
```

An org file without a format: include-files reads it as markdown.

```{.include}
chapters/c.org
```

```{.include}
// only comments: the block goes
```

```python
print("other code blocks are left alone")
```
