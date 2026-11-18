Relative paths, rewritten to name the same file from the main document's
directory:
![](img.png)
![](./img.png)
![](../top.png)
![](sub/deep.png)
[a link](other.md#section)
[a link with a title](other.md "the title")
[a bare word](page)

Not relative, and left alone:
[a URL](https://example.org/x)
[mail](mailto:a@example.org)
![data](data:image/png;base64,AAAA)
[absolute](/abs/path.md)
[network path](//example.org/x)
[a Windows drive](C:/x.md)
[a fragment](#section)
[a query](?q=1)
[empty]()

Raw HTML is not looked into: <img src="raw.png">

::: {include="deeper/b.md"}
:::

A failure here is left as it was, but for its path, which still names the
same file:

::: {include="missing.md"}
placeholder
:::

```{include="missing.txt"}
placeholder
```
