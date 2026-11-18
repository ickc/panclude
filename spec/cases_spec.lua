-- The conformance cases, tests/cases/ (SPEC.md, section 7): run each with
-- `pandoc -L panclude.lua` and compare the document, the warnings and the
-- exit status with what it expects. The document is compared as this
-- pandoc writes both, so that the layout of pandoc's native writer,
-- which changes between versions, does not matter.

local cases = require("cases")

local function show(list)
  if #list == 0 then return "  (none)" end
  return "  " .. table.concat(list, "\n  ")
end

describe("the conformance case", function()
  for _, name in ipairs(cases.list()) do
    local case = cases.load(name)
    if case.only ~= "builtin" then
      it(name, function()
        local got = cases.run(case)
        if got.status ~= case.status then
          error(("exit status %s, expected %s; stderr:\n%s")
            :format(got.status, case.status, got.stderr), 0)
        end
        local want = cases.expected(case)
        if want and got.native ~= want then
          error("the document differs; expected:\n" .. want .. "got:\n" .. got.native, 0)
        end
        if table.concat(got.warnings, "\n") ~= table.concat(case.warnings, "\n") then
          error("the warnings differ; expected:\n" .. show(case.warnings) ..
            "\ngot:\n" .. show(got.warnings), 0)
        end
      end)
    end
  end
end)
