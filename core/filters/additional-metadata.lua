--[[
  additional-metadata.lua

  This filter allows external metadata files to override document frontmatter.

  Usage:
    Set 'override_meta_file' in your metadata to point to a YAML file.
    The metadata from that file will override any existing metadata.

  Example in defaults or metadata file:
    override_meta_file: /data/config/custom.yaml

  Or use command line:
    --metadata override_meta_file=/data/config/custom.yaml
]]

-- Fallback metadata filter: only fill missing keys from external YAML
function read_file_as_markdown_yaml(filename)
  local metafile = io.open(filename, 'r')
  if not metafile then
    io.stderr:write("Warning: Could not open metadata file: " .. filename .. "\n")
    return {}
  end
  local content = metafile:read('*a')
  metafile:close()
  return pandoc.read(content, 'markdown').meta
end

function Meta(meta)
  if meta.default_meta_file then
    local filename = pandoc.utils.stringify(meta.default_meta_file)
    local yaml_meta = read_file_as_markdown_yaml(filename)
    for k, v in pairs(yaml_meta) do
      meta[k] = meta[k] or v
    end
    meta.default_meta_file = nil
  end
  return meta
end
