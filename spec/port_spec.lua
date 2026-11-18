-- The porting filter, tools/port-include-files.lua, on the documents in
-- tests/port/: each case's doc.md (in pandoc-ext/include-files' syntax),
-- the ported.md it should become, and include-files.native, what
-- include-files made of doc.md (recorded with include-files at commit
-- 0d22805). Documents are compared as this pandoc writes them, so that
-- the writer's layout, which changes between pandoc versions, does not
-- matter.

local PORT = "tools/port-include-files.lua"
local ROOT = "tests/port"
local cwd = pandoc.system.get_working_directory()
local FILTER = pandoc.path.join({ cwd, "panclude.lua" })
local UNWRAP = pandoc.path.join({ cwd, "spec/unwrap.lua" })
local PORT_PATH = pandoc.path.join({ cwd, PORT })

local function read(file)
  local f = io.open(file, "rb")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

-- Run pandoc in a case's directory; return stdout and stderr.
local function run(case, args)
  local err_path = os.tmpname()
  local p = assert(io.popen("cd " .. ROOT .. "/" .. case .. " && pandoc " .. args ..
    " 2>" .. err_path, "r"))
  local out = p:read("a")
  p:close()
  local err = read(err_path) or ""
  os.remove(err_path)
  return out, err
end

local function has(s, sub)
  if not s:find(sub, 1, true) then
    error(("expected to find %q in:\n%s"):format(sub, s), 2)
  end
end

-- A case's arguments, the original document last; and the same with the
-- ported document in its place.
local function arguments(case)
  local args = {}
  for line in (read(ROOT .. "/" .. case .. "/args") or "doc.md\n"):gmatch("[^\n]+") do
    args[#args + 1] = line
  end
  local doc = args[#args]
  local ported = {}
  for i, a in ipairs(args) do ported[i] = a end
  local dir = pandoc.path.directory(doc)
  ported[#ported] = dir == "." and "ported.md" or dir .. "/ported.md"
  return table.concat(args, " "), table.concat(ported, " ")
end

describe("the porting filter", function()
  for _, case in ipairs({ "basic", "auto", "smart-off", "subdir" }) do
    local original, ported = arguments(case)

    it("writes each block of " .. case .. " as divs, one a file", function()
      local got = run(case, original .. " -s -L " .. PORT_PATH .. " -t native")
      local want = run(case, ported .. " -s -t native")
      assert.are.equal(want, got)
    end)

    it("gives, through panclude, what include-files gave for " .. case, function()
      local got = run(case, ported .. " -s -L " .. FILTER .. " -L " .. UNWRAP .. " -t native")
      local want = run(case, "include-files.native -f native -s -L " .. UNWRAP .. " -t native")
      assert.are.equal(want, got)
    end)
  end

  it("lists each block ported on stderr, and what it could not write", function()
    local _, err = run("basic", "doc.md -L " .. PORT_PATH .. " -o /dev/null")
    has(err, '[port-include-files] ported a block of 2 file(s): ' ..
      '::: {include="chapters/a.md"} ::: ::: {include="chapters/b.md"} :::')
    has(err, '[port-include-files] ported a block of 0 file(s)')
    _, err = run("auto", "doc.md -L " .. PORT_PATH .. " -o /dev/null")
    has(err, 'shift-heading-level-by="abc" is no whole number: no shift written')
  end)
end)
