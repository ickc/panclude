--[[
port-include-files.lua: a pandoc Lua filter that rewrites a document's
pandoc-ext/include-files blocks into panclude's divs, one div a file.

    ```{.include shift-heading-level-by=1}      ::: {include="a.md" shift-heading-level-by=1}
    a.md                                         :::
    // a comment                           ->
    b.md                                         ::: {include="b.md" shift-heading-level-by=1}
    ```                                          :::

- Each line names a file; lines starting with `//` are comments, and
  empty lines are skipped. The block's other attributes go with it, as
  include-files drops the block.
- `shift-heading-level-by` is written out on each div: the block's own,
  or with `include-auto` in the metadata, the level of the last heading
  before the block, as include-files computes it. A shift of 0 is not
  written. `include-auto` is removed from the metadata.
- `format` is kept. Without one, include-files reads every file as
  markdown with pandoc's default extensions; panclude reads a file whose
  extension names another format in that format, and markdown with the
  document's extensions. So `format="markdown"` is written whenever the
  two would differ.
- include-files opens a path from the working directory; panclude from
  the directory of the file holding it. A relative path is rewritten to
  start at the document's directory, which changes it only when the
  document is not in the working directory. An included file has its
  own blocks: port it too, from its own directory (include-files reads
  the names in it from there), with -M include-auto if the main document
  had it.

Usage, with -s to keep the metadata block, and the reader extensions
and writer options you format the document with:

    pandoc old.md -s -f markdown -t markdown -L port-include-files.lua -o new.md

Each block ported is listed on stderr, with the divs to write, so that
documents pandoc's markdown writer would damage can be ported by hand
from the list (-o /dev/null).

License: BSD-3-Clause
]]

PANDOC_VERSION:must_be_at_least '3.2'

local path = pandoc.path

local function note(message)
  io.stderr:write('[port-include-files] ', message, '\n')
end

-- The directory of the document, from the working directory.
local function document_dir()
  local first = PANDOC_STATE.input_files[1]
  if not first or first == '-' then return '.' end
  return path.directory(first)
end

-- Whether the document's extensions are pandoc's default ones for
-- markdown.
local function default_markdown_extensions()
  local defaults = {}
  local n = 0
  for _, ext in ipairs(pandoc.format.default_extensions('markdown')) do
    defaults[ext] = true
    n = n + 1
  end
  local m = 0
  for _, ext in ipairs(PANDOC_READER_OPTIONS.extensions) do
    if not defaults[ext] then return false end
    m = m + 1
  end
  return m == n
end

-- The path, rewritten to start at the document's directory.
local function rebase(file, dir)
  if dir == '.' or dir == '' or path.is_absolute(file) then return file end
  return path.make_relative(file, dir, true)
end

local function attr_text(attrs)
  local parts = {}
  for _, kv in ipairs(attrs) do
    parts[#parts + 1] = ('%s="%s"'):format(kv[1], kv[2])
  end
  return '{' .. table.concat(parts, ' ') .. '}'
end

local function port(doc)
  local auto = doc.meta['include-auto']
  auto = auto ~= nil and auto ~= false
  doc.meta['include-auto'] = nil

  local dir = document_dir()
  local markdown_as_defaults = default_markdown_extensions()
  local last_level = 0

  local function block(cb)
    if not cb.classes:includes('include') then return nil end
    local attrs = cb.attributes

    local shift = auto and last_level or 0
    local shift_text = attrs['shift-heading-level-by']
    if shift_text then
      shift = math.tointeger(tonumber(shift_text))
      if not shift then
        note(('shift-heading-level-by="%s" is no whole number: no shift written')
          :format(shift_text))
        shift = 0
      end
    end

    local divs, written = {}, {}
    for line in cb.text:gmatch('[^\n]+') do
      if line:sub(1, 2) ~= '//' then
        local div_attrs = { { 'include', rebase(line, dir) } }
        if shift ~= 0 then
          div_attrs[#div_attrs + 1] = { 'shift-heading-level-by', tostring(shift) }
        end
        local format = attrs.format
        if not format then
          local by_extension = pandoc.format.from_path(line)
          if (by_extension and by_extension ~= 'markdown') or not markdown_as_defaults then
            format = 'markdown'
          end
        end
        if format then div_attrs[#div_attrs + 1] = { 'format', format } end
        divs[#divs + 1] = pandoc.Div({}, pandoc.Attr('', {}, div_attrs))
        written[#written + 1] = '::: ' .. attr_text(div_attrs) .. ' :::'
      end
    end
    note(('ported a block of %d file(s)%s'):format(#divs,
      #written > 0 and ': ' .. table.concat(written, ' ') or ''))
    return divs
  end

  -- In document order, as include-files sees headings and blocks.
  doc.blocks = doc.blocks:walk({
    traverse = 'topdown',
    Header = function(h) last_level = h.level end,
    CodeBlock = block,
  })
  return doc
end

return { { Pandoc = port } }
