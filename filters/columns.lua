--[[
==============================================================================
Beispiel-Filter: Zwei-Spalten Layout
==============================================================================
Dieser Lua-Filter erstellt ein zweispaltiges Layout.

Verwendung in Markdown:
::: columns
:::: column
Linke Spalte
::::

:::: column
Rechte Spalte
::::
:::
--]]

function Div(el)
  if el.classes:includes('columns') then
    if FORMAT:match 'html' then
      el.classes:insert('two-columns')
    elseif FORMAT:match 'latex' then
      local columns = {}
      table.insert(columns, pandoc.RawBlock('latex', '\\begin{columns}'))
      
      for _, item in ipairs(el.content) do
        if item.t == 'Div' and item.classes:includes('column') then
          table.insert(columns, pandoc.RawBlock('latex', '\\begin{column}{0.48\\textwidth}'))
          table.insert(columns, item)
          table.insert(columns, pandoc.RawBlock('latex', '\\end{column}'))
        end
      end
      
      table.insert(columns, pandoc.RawBlock('latex', '\\end{columns}'))
      return columns
    end
  end
  
  return el
end

return {
  { Div = Div }
}
