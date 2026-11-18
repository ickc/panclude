The built-in tells files apart after resolving symbolic links: a cycle
through a link is a cycle (the Lua filter ends it at the depth limit).

::: {include="a.md"}
:::
