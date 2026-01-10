--[[
==============================================================================
Beispiel-Filter: Warnungs-Boxen
==============================================================================
Dieser Lua-Filter wandelt spezielle Div-Elemente in formatierte Boxen um.

Verwendung in Markdown:
::: warning
Dies ist eine Warnung!
:::

::: info
Dies ist eine Information!
:::

::: success
Dies ist eine Erfolgs-Meldung!
:::
--]]

function Div(el)
  -- Warnung-Box
  if el.classes:includes('warning') then
    if FORMAT:match 'html' then
      el.classes:insert('warning-box')
    elseif FORMAT:match 'latex' then
      return {
        pandoc.RawBlock('latex', '\\begin{alertblock}{Warnung}'),
        el,
        pandoc.RawBlock('latex', '\\end{alertblock}')
      }
    end
  end
  
  -- Info-Box
  if el.classes:includes('info') then
    if FORMAT:match 'html' then
      el.classes:insert('info-box')
    elseif FORMAT:match 'latex' then
      return {
        pandoc.RawBlock('latex', '\\begin{block}{Information}'),
        el,
        pandoc.RawBlock('latex', '\\end{block}')
      }
    end
  end
  
  -- Erfolgs-Box
  if el.classes:includes('success') then
    if FORMAT:match 'html' then
      el.classes:insert('success-box')
    elseif FORMAT:match 'latex' then
      return {
        pandoc.RawBlock('latex', '\\begin{exampleblock}{Erfolg}'),
        el,
        pandoc.RawBlock('latex', '\\end{exampleblock}')
      }
    end
  end
  
  return el
end

return {
  { Div = Div }
}
