-- Dynamic Footer Lua Filter
-- Injects version info and page numbers

function Meta(m)
    m.date = os.date("%Y-%m-%d")
    return m
end
