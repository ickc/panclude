-- Under Quarto, which runs pandoc on a temporary copy of the page it
-- renders, and names the page itself in quarto.doc.input_file. A shim
-- filter sets that global, as Quarto does, and runs panclude in the same
-- Lua state; the document pandoc reads is a copy, in another directory.

local cwd = pandoc.system.get_working_directory()
local FILTER = pandoc.path.join({ cwd, "panclude.lua" })

local function read(file)
  local f = io.open(file, "rb")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

local function write(file, s)
  local f = assert(io.open(file, "wb"))
  f:write(s)
  f:close()
end

-- Run pandoc; return stdout and stderr.
local function run(args)
  local err_path = os.tmpname()
  local p = assert(io.popen("pandoc " .. args .. " 2>" .. err_path, "r"))
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

local function lacks(s, sub)
  if s:find(sub, 1, true) then
    error(("expected not to find %q in:\n%s"):format(sub, s), 2)
  end
end

-- site/part/page.md includes ../examples/hello.sh; its copy is in
-- quarto-session/, where no ../examples/ exists.
local function with_site(fn)
  pandoc.system.with_temporary_directory("panclude-quarto", function(dir)
    local site = pandoc.path.join({ dir, "site" })
    local page = pandoc.path.join({ site, "part", "page.md" })
    local copy = pandoc.path.join({ dir, "quarto-session", "quarto-input.md" })
    pandoc.system.make_directory(pandoc.path.join({ site, "part" }), true)
    pandoc.system.make_directory(pandoc.path.join({ site, "examples" }), true)
    pandoc.system.make_directory(pandoc.path.join({ dir, "quarto-session" }), true)
    local doc = '``` {.bash include="../examples/hello.sh"}\n```\n'
    write(page, doc)
    write(copy, doc)
    write(pandoc.path.join({ site, "examples", "hello.sh" }), 'echo "hello from the example"\n')
    local shim = pandoc.path.join({ dir, "quarto-shim.lua" })
    write(shim, ("quarto = { doc = { input_file = %q } }\nreturn dofile(%q)\n"):format(page, FILTER))
    fn({ page = page, copy = copy, shim = shim })
  end)
end

describe("under Quarto", function()
  it("starts a relative path at the page's directory, not at its temporary copy's", function()
    with_site(function(s)
      local out, err = run(s.copy .. " -L " .. s.shim .. " -t native")
      has(out, "hello from the example")
      lacks(err, "panclude")
    end)
  end)

  it("leaves stock pandoc as it was: the path starts at the input file's directory", function()
    with_site(function(s)
      local out, err = run(s.copy .. " -L " .. FILTER .. " -t native")
      lacks(out, "hello from the example")
      has(err, "not found")
      local out_page, err_page = run(s.page .. " -L " .. FILTER .. " -t native")
      has(out_page, "hello from the example")
      lacks(err_page, "panclude")
    end)
  end)
end)
