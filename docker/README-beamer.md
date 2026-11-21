# Pandoc Beamer Image

Docker image with Pandoc + LaTeX for professional Beamer PDF presentations.

## Use Cases

- Academic presentations
- Beamer-based PDF slides
- LaTeX typography workflow
- Reproducible container builds

## Image Details

- **Base**: Debian Bookworm Slim
- **Pandoc**: v3.1.11
- **LaTeX**: Minimal TeXLive + Beamer
- **Size**: depends on TeX packages
- **Platforms**: linux/amd64
- **User**: non-root (pandoc:1000)
- **Includes**: defaults, templates, filters, includes, metadata

## Quick Start

```bash
# Build local image
docker build -f docker/Dockerfile.beamer -t pandoc-beamer:local .

# Run build helper mounted from project root
docker run --rm \
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  pandoc-beamer:local \
  -c "/data/buildPDF"

# Override input/output
docker run --rm \
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  -e INPUT_FILE=/data/slides/Example.md \
  -e OUTPUT_FILE=/data/output/presentation.pdf \
  pandoc-beamer:local \
  -c "/data/buildPDF"
```

## Features

- [OK] Preinstalled Beamer defaults
- [OK] XeLaTeX + LuaLaTeX support
- [OK] Beamer theme support
- [OK] Filter and template integration
- [OK] Math and graphics packages

## Documentation

Full documentation: <https://gitlab.com/WoofiOwO/pandoc-presentation-creator>

## Tags

- `latest` - latest published version
- `vX.Y.Z` - specific versions

## Related Images

- `pandoc-base:test` / base image workflow

## Note

This image is larger than the base image because LaTeX dependencies are included.
