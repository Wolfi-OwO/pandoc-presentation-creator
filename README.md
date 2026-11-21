# Pandoc Presentation Creator

[![pipeline](https://gitlab.com/WoofiOwO/pandoc-presentation-creator/badges/main/pipeline.svg)](https://gitlab.com/WoofiOwO/pandoc-presentation-creator/-/pipelines)
[![latest-release](https://gitlab.com/WoofiOwO/pandoc-documentation-creator/-/badges/release.svg)](https://gitlab.com/WoofiOwO/pandoc-documentation-creator/-/releases/permalink/latest)

**Maintainer:** Phillip Kofler (<koflerphillip@outlook.com>)

A 100% containerized Pandoc-based presentation system for generating professional PDF presentations using Beamer/LaTeX. All resources are baked into the Docker image for maximum reproducibility and zero external dependencies.

---

## Quick Start

### 1. Initialize a Project (Recommended)

```bash
bash init.sh
```

The initializer asks simple questions (title, author, slide filename, output filename) and creates:

- `config/config.yaml`
- `slides/Example.md` (or your chosen slide filename)
- `buildPDF`
- `HELP.md`

### 2. Build a Presentation

```bash
# Pull registry image (or let init.sh pin a specific version)
docker pull registry.gitlab.com/woofiowo/pandoc-presentation-creator/beamer-full:latest

# Render PDF via /data/buildPDF (documentation-creator style)
docker run --rm \
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  registry.gitlab.com/woofiowo/pandoc-presentation-creator/beamer-full:latest \
  -c "/data/buildPDF"
```

### 3. Optional: Build Local Dev Image

```bash
docker build -f docker/Dockerfile.beamer -t pandoc-beamer:local .
```

### 4. Common Script Flags

```bash
# Set custom input/output via environment variables
docker run --rm \
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  -e INPUT_FILE=/data/slides/Example.md \
  -e OUTPUT_FILE=/data/output/presentation.pdf \
  registry.gitlab.com/woofiowo/pandoc-presentation-creator/beamer-full:latest \
  -c "/data/buildPDF"

# Merge an additional defaults file and metadata overrides
docker run --rm \
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  -e INPUT_FILE=/data/slides/Example.md \
  -e OUTPUT_FILE=/data/output/presentation.pdf \
  -e DEFAULTS_FILE=/data/config/custom.yaml \
  -e METADATA_OVERRIDES="footerbadge=CONFIDENTIAL" \
  registry.gitlab.com/woofiowo/pandoc-presentation-creator/beamer-full:latest \
  -c "/data/buildPDF"
```

### 5. VS Code Integration

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

The generated `buildPDF` script is the main build entrypoint and is designed to be called from inside the container with `-c "/data/buildPDF"`.
During initialization, `init.sh` resolves the current image version label and stamps that exact image tag into generated `HELP.md` commands.

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
  docker run --rm -v $(pwd):/data --user root registry.gitlab.com/woofiowo/pandoc-presentation-creator/beamer-full:latest \
    /data/info/help.md -o /data/HELP.pdf \
    --from markdown --to pdf --pdf-engine xelatex -V geometry:margin=2cm --toc
  ```

### Additional Resources

- **[info/filesystem-consolidation.md](info/filesystem-consolidation.md)**: Consolidation plan and verification steps
- **[info/REFACTOR-SUMMARY.md](info/REFACTOR-SUMMARY.md)**: Architectural refactoring summary
- **[docker/README-beamer.md](docker/README-beamer.md)**: Docker-specific documentation
- **[CONTRIBUTING.md](CONTRIBUTING.md)**: Contribution workflow and standards

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
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  -e INPUT_FILE=/data/slides/Example.md \
  -e OUTPUT_FILE=/data/output/presentation.pdf \
  pandoc-beamer:local \
  -c "/data/buildPDF"
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
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  -e INPUT_FILE=/data/slides/Example.md \
  -e OUTPUT_FILE=/data/output/my-presentation.pdf \
  pandoc-beamer:local \
  -c "/data/buildPDF"
```

### Multiple Input Files

#### Adding them separately

```bash
docker run --rm \
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  -e INPUT_FILE=/data/slides/intro.md \
  -e OUTPUT_FILE=/data/output/full-presentation.pdf \
  -e DEFAULTS_FILE=/data/config/config_2.yaml \
  pandoc-beamer:local \
  -c "/data/buildPDF"
```

Note: `buildPDF` supports one markdown input file per invocation. To merge multiple files, concatenate them first or run pandoc directly.

#### Using a wildcard

##### Linux

```bash
docker run --rm \
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  pandoc-beamer:local \
  -c "/data/buildPDF"
```

##### Windows

```powershell
docker run --rm `
  -v "${PWD}:/data" `
  --entrypoint=/bin/sh `
  pandoc-beamer:local `
  -c "/data/buildPDF"
```

### Override Metadata

```bash
docker run --rm \
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  -e INPUT_FILE=/data/slides/Example.md \
  -e OUTPUT_FILE=/data/output/presentation.pdf \
  -e METADATA_OVERRIDES="title=My Custom Title" \
  pandoc-beamer:local \
  -c "/data/buildPDF"
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
docker run --rm \
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  -e INPUT_FILE=/data/slides/YourPresentation.md \
  -e OUTPUT_FILE=/data/output/YourPresentation.pdf \
  -e DEFAULTS_FILE=/data/config/custom.yaml \
  pandoc-beamer:local \
  -c "/data/buildPDF"
```

---

## [TST] Verification

Test the containerized workflow:

```bash
docker build -f docker/Dockerfile.beamer -t pandoc-beamer:local .
docker run --rm \
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  pandoc-beamer:local \
  -c "/data/buildPDF"
```

This verifies:

- Docker image builds correctly
- `buildPDF` executes successfully
- A PDF is generated in `output/`

---

## [BUG] Troubleshooting

### Common Issues

1. **LaTeX Error: File not found**
   - Ensure `resource-path` in `beamer.yaml` includes all necessary directories

2. **Extra Empty Slides**
   - Set `slide-level: 1` and use `#` for slides (not `---` separators)

3. **Permission Denied in Container**
   - Use `--user root` for volume-mounted outputs

4. **Windows: `file not found` when running scripts**

- Ensure line endings are LF for shell scripts
- Run: `git add --renormalize .`
- Then commit the normalized files (`.gitattributes` is already configured)

1. **`/data/buildPDF: not found` in container**

- Ensure `buildPDF` exists in project root
- Ensure it is executable: `chmod +x buildPDF`

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

See [CONTRIBUTING.md](CONTRIBUTING.md) for full instructions.

---

## [LIC] License

This project is licensed under the MIT License. See LICENSE for details.

---

## [@] Contact

- **Maintainer:** Philip Kofler
- **Email:** <koflerphillip@outlook.com>
- **Repository:** [GitLab - pandoc-presentation-creator](https://gitlab.com/WoofiOwO/pandoc-presentation-creator)
- **Issues:** Use GitLab Issues for bug reports and feature requests

---

***Last updated: March 2026***
