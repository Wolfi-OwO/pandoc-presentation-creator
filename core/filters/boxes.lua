--[[
==============================================================================
Example filter: warning boxes
==============================================================================
This Lua filter transforms special Div elements into formatted boxes.

Usage in Markdown:
::: warning
This is a warning!
:::

::: info
This is info!
:::

::: success
This is a success message!
:::
--]]

function Div(el)
  -- Warning box
  if el.classes:includes('warning') then
    if FORMAT:match 'html' then
      el.classes:insert('warning-box')
    elseif FORMAT:match 'latex' then
      return {
        pandoc.RawBlock('latex', '\\begin{alertblock}{Warning}'),
        el,
        pandoc.RawBlock('latex', '\\end{alertblock}')
      }
    end
  end

  -- Info box
  if el.classes:includes('info') then
    if FORMAT:match 'html' then
      el.classes:insert('info-box')
    elseif FORMAT:match 'latex' then
      return {
        pandoc.RawBlock('latex', '\\begin{block}{Info}'),
        el,
        pandoc.RawBlock('latex', '\\end{block}')
      }
    end
  end

  -- Success box
  if el.classes:includes('success') then
    if FORMAT:match 'html' then
      el.classes:insert('success-box')
    elseif FORMAT:match 'latex' then
      return {
        pandoc.RawBlock('latex', '\\begin{exampleblock}{Success}'),
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
