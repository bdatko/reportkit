function Table(tbl)
  for i, spec in ipairs(tbl.colspecs) do
    local numeric, any = true, false
    for _, b in ipairs(tbl.bodies) do for _, row in ipairs(b.body) do
      local s = pandoc.utils.stringify(row.cells[i].contents)
      if s ~= "" then any = true; if not s:match("^%-?[%d,%.]+$") then numeric = false end end
    end end
    if any and numeric then tbl.colspecs[i] = {pandoc.AlignRight, spec[2]} end
  end
  return tbl
end
