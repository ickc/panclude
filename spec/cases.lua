-- spec/cases.lua — run a conformance case of tests/cases/ (SPEC.md,
-- section 7) with `pandoc` and the Lua filter, and read what it expects.
-- Used by spec/cases_spec.lua and spec/gen_cases.lua.

local M = {}

M.ROOT = "tests/cases"
M.FILTER = pandoc.path.join({ pandoc.system.get_working_directory(), "panclude.lua" })

local function read(file)
  local f = io.open(file, "rb")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end
M.read = read

local function write(file, s)
  local f = assert(io.open(file, "wb"))
  f:write(s)
  f:close()
end
M.write = write

local function lines(s)
  local t = {}
  if not s then return t end
  for line in s:gmatch("([^\n]*)\n?") do
    if line ~= "" then t[#t + 1] = line end
  end
  return t
end

local function quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- The names of the cases, sorted.
function M.list(root)
  root = root or M.ROOT
  local names = {}
  local p = assert(io.popen("ls " .. quote(root)))
  for name in p:lines() do
    if read(root .. "/" .. name .. "/args") or read(root .. "/" .. name .. "/doc.md")
        or read(root .. "/" .. name .. "/stdin") then
      names[#names + 1] = name
    end
  end
  p:close()
  table.sort(names)
  return names
end

-- A case's files: what to run and what to expect.
function M.load(name, root)
  local dir = (root or M.ROOT) .. "/" .. name
  local case = { name = name, dir = dir }
  local stdin = read(dir .. "/stdin")
  case.stdin = stdin and "stdin" or nil
  case.args = lines(read(dir .. "/args"))
  if not read(dir .. "/args") and not stdin then case.args = { "doc.md" } end
  case.env = lines(read(dir .. "/env"))
  case.only = (read(dir .. "/only") or ""):match("%S+")
  case.expected = read(dir .. "/expected.native")
  case.warnings = lines(read(dir .. "/warnings"))
  case.status = tonumber((read(dir .. "/status") or "0"):match("%d+"))
  return case
end

-- Run a shell command in the case's directory; return its stdout, its
-- stderr and its exit status.
local function sh(case, command)
  local err_path = os.tmpname()
  local p = assert(io.popen("cd " .. quote(case.dir) .. " && " .. command ..
    " 2>" .. quote(err_path), "r"))
  local out = p:read("a")
  local _, _, status = p:close()
  local err = read(err_path) or ""
  os.remove(err_path)
  return out, err, status
end

-- The messages of a pandoc log (--log): a filter's warning's message,
-- any other warning's text as pandoc prints it.
local function warnings(log)
  local found = {}
  if not log or log == "" then return found end
  for _, entry in ipairs(pandoc.json.decode(log, false)) do
    if entry.verbosity == "WARNING" then
      found[#found + 1] = entry.type == "ScriptingWarning" and entry.message
        or entry.pretty
    end
  end
  return found
end

-- Run the case with the filter: the document pandoc writes (native, with
-- -s), the warnings in its log, its exit status and its stderr.
function M.run(case, filter)
  filter = filter or M.FILTER
  local args, has_filter = {}, false
  for _, a in ipairs(case.args) do
    if a:find("{panclude}", 1, true) then has_filter = true end
    args[#args + 1] = quote((a:gsub("{panclude}", function() return filter end)))
  end
  if not has_filter then table.insert(args, 1, quote("--lua-filter=" .. filter)) end
  local log_path = os.tmpname()
  -- A libpandoc host names the reader in PANDOC_INPUT_FORMAT; stock
  -- pandoc does not, unless the case says so.
  local env = { "PANDOC_INPUT_FORMAT=" }
  for _, e in ipairs(case.env) do
    local k, v = e:match("^([%w_]+)=(.*)$")
    env[#env + 1] = k .. "=" .. quote(v)
  end
  local command = table.concat(env, " ") .. " pandoc " .. table.concat(args, " ") ..
    " -s -t native --log=" .. quote(log_path)
  if case.stdin then command = command .. " <" .. quote(case.stdin) end
  local out, err, status = sh(case, command)
  local log = read(log_path)
  os.remove(log_path)
  return { native = out, warnings = warnings(log), status = status, stderr = err }
end

-- The expected document, as this pandoc writes it.
function M.expected(case)
  if not case.expected then return nil end
  local out, err, status = sh(case, "pandoc expected.native -f native -s -t native")
  assert(status == 0, case.name .. "/expected.native: " .. err)
  return out
end

return M
