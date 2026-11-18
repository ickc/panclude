The include works wherever the element does.

- In a list:

  ```{include="x.txt"}
  ```

> In a block quote:
>
> ::: {include="part.md"}
> :::

+---------------------------+
| In a table cell:          |
|                           |
| ```{include="x.txt"}      |
| ```                       |
+---------------------------+

In a note.[^1]

::: outer
::: {include="part.md"}
:::
:::

[^1]: The note:

    ```{include="x.txt"}
    ```
