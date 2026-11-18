-- spec/unwrap.lua — a filter for spec/port_spec.lua: a document as
-- include-files would have made it, from panclude's. include-files puts a
-- file's blocks in place of its block, where panclude fills a div, one a
-- file; and include-files keeps include-auto in the metadata.

function Div(div)
  if div.identifier == "" and #div.classes == 0 and #div.attributes == 0 then
    return div.content
  end
end

function Meta(meta)
  meta["include-auto"] = nil
  return meta
end
