-- spec/gen_cases.lua — write what a case expects from what the filter
-- now does: expected.native, warnings and status. Review the result with
-- `git diff` before committing it: the cases are the specification's,
-- not the filter's.
-- Usage, from the repository's root:
--   pandoc lua spec/gen_cases.lua NAME...   (no NAME: every case)

local script_dir = (arg[0] or "spec/gen_cases.lua"):match("(.*/)") or "./"
package.path = script_dir .. "?.lua;" .. package.path
local cases = require("cases")

local names = {}
for _, a in ipairs(arg) do names[#names + 1] = a end
if #names == 0 then names = cases.list() end

for _, name in ipairs(names) do
  local case = cases.load(name)
  local got = cases.run(case)
  local dir = case.dir .. "/"
  os.remove(dir .. "expected.native")
  os.remove(dir .. "warnings")
  os.remove(dir .. "status")
  if got.status == 0 then
    cases.write(dir .. "expected.native", got.native)
  else
    cases.write(dir .. "status", got.status .. "\n")
  end
  if #got.warnings > 0 then
    cases.write(dir .. "warnings", table.concat(got.warnings, "\n") .. "\n")
  end
  io.write(name, ": status ", got.status, ", ", #got.warnings, " warning(s)\n")
end
