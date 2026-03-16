# Pandoc Base Image

Minimal base image with Pandoc for document conversion and as parent image.

## Use Cases

- Markdown conversion
- Base for other Pandoc images
- Lean runtime for non-LaTeX workflows

## Image Details

- **Base**: Debian Bookworm Slim
- **Pandoc**: v3.1.11
- **Size**: varies with package updates
- **Platforms**: linux/amd64

## Quick Start

```bash
# Build base image
docker build -f docker/Dockerfile.base -t pandoc-base:test .

# Show pandoc version
docker run --rm pandoc-base:test pandoc --version

# Markdown to HTML
docker run --rm -v $(pwd):/data \
  pandoc-base:test \
  input.md -o output.html

# With additional options
docker run --rm -v $(pwd):/data \
  pandoc-base:test \
  --from markdown \
  --to html5 \
  --standalone \
  --toc \
  document.md -o output.html
```

## Documentation

Full documentation: <https://gitlab.com/woofi4/public/pandoc-presentation-creator>

## Tags

- `latest` - latest published version
- `vX.Y.Z` - specific versions
- `base` - base flavor tag

## Related Images

- Beamer image: `docker/Dockerfile.beamer`
