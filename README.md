# Pandoc Presentation Creator

[![pipeline](https://gitlab.com/WoofiOwO/pandoc-presentation-creator/badges/main/pipeline.svg)](https://gitlab.com/WoofiOwO/pandoc-presentation-creator/-/pipelines)
[![latest-release](https://gitlab.com/WoofiOwO/pandoc-documentation-creator/-/badges/release.svg)](https://gitlab.com/WoofiOwO/pandoc-documentation-creator/-/releases/permalink/latest)

**Maintainer:** Phillip Kofler (<koflerphillip@outlook.com>)

A 100% containerized Pandoc-based presentation system for generating professional PDF presentations using Beamer/LaTeX. All resources are baked into the Docker image for maximum reproducibility and zero external dependencies.

---

## Quick Start

### 1. Build the Container Locally

```bash
docker build -f docker/Dockerfile.beamer -t pandoc-beamer:local .
```

### 2. Pull from GitLab Registry (Alternative)

```bash
docker pull registry.gitlab.com/woofiowo/pandoc-presentation-creator:beamer-latest
```

### 3. Render a Presentation

```bash
# Using local image
docker run --rm \
  -v $(pwd):/data \
  --user root \
  pandoc-beamer:local \
  --defaults /opt/pandoc/defaults/beamer.yaml \
  /data/slides/Minimalist.md \
  -o /data/output/presentation.pdf

# Or using registry image
docker run --rm \
  -v $(pwd):/data \
  --user root \
  registry.gitlab.com/woofiowo/pandoc-presentation-creator:beamer-latest \
  --defaults /opt/pandoc/defaults/beamer.yaml \
  /data/slides/Minimalist.md \
  -o /data/output/presentation.pdf
```

### 4. VS Code Integration

Open project in VS Code and press **Ctrl+Shift+B** to build and render.

---

## Directory Structure

```text
.
├── core/               # Baked into container at /opt/pandoc/
│   ├── defaults/      # Pandoc YAML configurations
│   ├── metadata/      # Common metadata (author, date)
│   ├── templates/     # LaTeX templates
│   ├── includes/      # LaTeX preambles and headers
│   ├── filters/       # Lua/Python filters
│   └── assets/        # Images, logos, fonts
├── slides/             # Your markdown presentations
├── docker/             # Container definitions
├── .vscode/            # VS Code configuration (tasks, settings)
├── info/               # Documentation
├── scripts/            # Build helpers (baked into container)
└── output/             # Generated PDFs (gitignored)
```

---

## Example Initialization

```bash
cd <your-directory>
curl -sSL https://gitlab.com/WoofiOwO/pandoc-presentation-creator/raw/main/init.sh | bash # Initializes the presentation in the current directory
```

## Key Features

### 100% Containerization

- All resources baked into `/opt/pandoc/` at build time
- No external dependencies needed at runtime
- Single command to render any presentation

### Standardized IDE Configuration

- One-click build with `Ctrl+Shift+B` (VS Code)
- Auto-install recommended extensions
- Consistent editor settings across team

### Clean CI/CD Integration

- Automated testing of all templates
- Auto-generated documentation (HELP.pdf)
- Reproducible builds with SHA tagging

### Modern Beamer Presentation

- Metropolis theme with professional styling
- Custom footer: Date | Author | Page x of y
- International date format support
- 16:9 aspect ratio

---

## Documentation

### Comprehensive Help Guide

- **Web:** [info/help.md](info/help.md)
- **PDF:** Generate with:

  ```bash
  docker run --rm -v $(pwd):/data --user root pandoc-beamer:local \
    /data/info/help.md -o /data/HELP.pdf \
    --from markdown --to pdf --pdf-engine xelatex -V geometry:margin=2cm --toc
  ```

### Additional Resources

- **[info/filesystem-consolidation.md](info/filesystem-consolidation.md)**: Consolidation plan and verification steps
- **[info/REFACTOR-SUMMARY.md](info/REFACTOR-SUMMARY.md)**: Architectural refactoring summary
- **[docker/README-beamer.md](docker/README-beamer.md)**: Docker-specific documentation

---

## Configuration

### Default Settings

Edit `core/defaults/beamer.yaml` for global configuration:

```yaml
slide-level: 1              # H1 = new slide
section-titles: false       # Disable section separators
theme: metropolis           # Beamer theme
aspectratio: 169            # 16:9 widescreen
pdf-engine: xelatex         # LaTeX engine
```

### Per-Presentation Metadata

## Quick Start Guide

### Build Your Presentation

Run this command to build your slides:

```bash
docker run --rm \
  -v $(pwd):/data \
  registry.gitlab.com/woofiowo/pandoc-presentation-creator:beamer-latest \
  --defaults /opt/pandoc/defaults/beamer.yaml \
  --metadata-file=/data/config/config.yaml \
  /data/slides/Example.md \
  -o /data/output/presentation.pdf
```

### Output

Your presentation will be generated as: `output/presentation.pdf`

### Editing

1. **Edit content**: Modify `slides/Example.md` with your content
2. **Change settings**: Update `config/config.yaml` (theme, metadata, etc.)
3. **Rebuild**: Run the docker command above

### Available Docker Images

- `pandoc-beamer:latest` - For PDF (Beamer) output
- `pandoc-revealjs:latest` - For HTML (Reveal.js) output

## Advanced Usage

### Custom Output Name

```bash
docker run --rm \
  -v $(pwd):/data \
  registry.gitlab.com/woofiowo/pandoc-presentation-creator/pandoc-beamer:latest \
  --defaults /opt/pandoc/defaults/beamer.yaml \
  --metadata-file=/data/config/config.yaml \
  /data/slides/Example.md \
  -o /data/output/my-presentation.pdf
```

### Multiple Input Files

#### Adding them separately

```bash
docker run --rm \
  -v $(pwd):/data \
  registry.gitlab.com/woofiowo/pandoc-presentation-creator:beamer-latest \
  --defaults /opt/pandoc/defaults/beamer.yaml \
  --metadata-file=/data/config/config.yaml \
  --metadata-file=/data/config/config_2.yaml \
  /data/slides/intro.md /data/slides/main.md /data/slides/conclusion.md \
  -o /data/output/full-presentation.pdf
```

#### Using a wildcard

##### Linux

```bash
docker run --rm \
  -v "$(pwd):/data" \
  registry.gitlab.com/woofiowo/pandoc-presentation-creator:beamer-latest \
  $(find slides -name '*.md' -print | sed 's|^|/data/|') \
    --defaults /opt/pandoc/defaults/beamer.yaml \
    --metadata-file=/data/config/config.yaml \
    -o /data/output/presentation.pdf
```

##### Windows

```powershell
docker run --rm `
  -v "${PWD}:/data" `
  registry.gitlab.com/woofiowo/pandoc-presentation-creator:beamer-latest `
  $(Get-ChildItem slides -Filter *.md -Recurse | ForEach-Object { "/data/" + $_.FullName.Substring($PWD.Path.Length + 1).Replace('\','/') }) `
  --defaults /opt/pandoc/defaults/beamer.yaml `
  --metadata-file=/data/config/config.yaml `
  -o /data/output/presentation.pdf
```

### Override Metadata

```bash
docker run --rm \
  -v $(pwd):/data \
  registry.gitlab.com/woofiowo/pandoc-presentation-creator:beamer-latest \
  --defaults /opt/pandoc/defaults/beamer.yaml \
  --metadata title="My Custom Title" \
  /data/slides/Example.md \
  -o /data/output/presentation.pdf
```

### Python Build Helper

For complex builds with metadata overrides:

```bash
docker run --rm \
  -v $(pwd):/data \
  --user root \
  --entrypoint python3 \
  pandoc-beamer:local \
  /opt/pandoc/scripts/build_beamer.py \
  --input /data/slides/YourPresentation.md \
  --output /data/output/YourPresentation.pdf \
  --metadata footerbadge=CONFIDENTIAL
```

### Custom Defaults File

Create `config/custom.yaml`:

```yaml
metadata:
  title: "My Custom Presentation"
  institute: "University of Vienna"
```

Run with:

```bash
docker run --rm -v $(pwd):/data --user root pandoc-beamer:local \
  --defaults /opt/pandoc/defaults/beamer.yaml \
  --defaults /data/config/custom.yaml \
  /data/slides/YourPresentation.md \
  -o /data/output/YourPresentation.pdf
```

---

## [TST] Verification

Test the containerized workflow:

```bash
chmod +x scripts/verify-container-workflow.sh
./scripts/verify-container-workflow.sh
```

This script verifies:

- Docker image builds correctly
- All templates render successfully
- Python helper works with metadata overrides
- Baked resources are accessible in container

---

## [BUG] Troubleshooting

### Common Issues

1. **LaTeX Error: File not found**
   - Ensure `resource-path` in `beamer.yaml` includes all necessary directories

2. **Extra Empty Slides**
   - Set `slide-level: 1` and use `#` for slides (not `---` separators)

3. **Permission Denied in Container**
   - Use `--user root` for volume-mounted outputs

See [info/help.md](info/help.md) for comprehensive troubleshooting guide.

---

## [DEP] Dependencies

### Container Runtime

- Docker (tested with 20.10+)

### Baked into Container

- Pandoc 3.1.11
- XeLaTeX (TeXLive)
- Python 3 with YAML support
- Beamer theme (Madrid)
- UBC color scheme
- Custom LaTeX templates and filters

---

## [+] Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run verification tests
5. Submit a merge request

---

## [LIC] License

See LICENSE file for details.

---

## [@] Contact

- **Maintainer:** Philip Kofler
- **Email:** <koflerphillip@outlook.com>
- **Repository:** [GitLab - pandoc-presentation-creator](https://gitlab.com/WoofiOwO/pandoc-presentation-creator)
- **Issues:** Use GitLab Issues for bug reports and feature requests

---

***Last updated: January 2026***
