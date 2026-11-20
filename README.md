# Pandoc Presentation Creator

[![pipeline](https://gitlab.com/WoofiOwO/pandoc-presentation-creator/badges/main/pipeline.svg)](https://gitlab.com/WoofiOwO/pandoc-presentation-creator/-/pipelines)
[![latest-release](https://gitlab.com/WoofiOwO/pandoc-presentation-creator/-/badges/release.svg)](https://gitlab.com/WoofiOwO/pandoc-presentation-creator/-/releases/permalink/latest)

**Maintainer:** Phillip Kofler (<koflerphillip@outlook.com>)

A 100% containerized Pandoc-based presentation system for generating professional PDF presentations using Beamer/LaTeX. All resources are baked into the Docker image for maximum reproducibility and zero external dependencies.

---

## Quick Start

### 1. Initialize a Project (Recommended)

```bash
# Download and run init.sh
wget https://gitlab.com/WoofiOwO/pandoc-presentation-creator/-/raw/main/init.sh
chmod +x init.sh
./init.sh build
```

Or with curl:

```bash
# Download and run init.sh
curl -O https://gitlab.com/WoofiOwO/pandoc-presentation-creator/-/raw/main/init.sh
chmod +x init.sh
./init.sh build
```

The initializer asks simple questions (title, author, slide filename, output filename) and creates:

- `config/config.yaml`
- `config/metadata.yaml`
- `slides/Example.md` (or your chosen slide filename)
- `buildPDF`
- `HELP.md`

### 2. Build a Presentation

```bash
# Pull registry image (or let init.sh pin a specific version)
docker pull registry.gitlab.com/woofiowo/pandoc-presentation-creator/beamer-full:latest

# Render PDF
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

### 4. Environment Variable Overrides

The `buildPDF` script is driven by environment variables passed with `-e`:

| Variable             | Default                         | Description                          |
|----------------------|---------------------------------|--------------------------------------|
| `INPUT_FILE`         | `/data/slides/Minimalist.md`    | Markdown input path inside container |
| `OUTPUT_FILE`        | `/data/output/presentation.pdf` | Output PDF path inside container     |
| `METADATA_FILE`      | `/data/config/config.yaml`      | Pandoc defaults YAML path            |
| `DEFAULTS_FILE`      | *(none)*                        | Additional defaults YAML path        |
| `METADATA_OVERRIDES` | *(none)*                        | Space-separated `key=value` pairs    |
| `PDF_ENGINE`         | *(none)*                        | Override PDF engine                  |

```bash
docker run --rm \
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  -e INPUT_FILE=/data/slides/Example.md \
  -e OUTPUT_FILE=/data/output/my-talk.pdf \
  -e METADATA_OVERRIDES="footerbadge=CONFIDENTIAL" \
  registry.gitlab.com/woofiowo/pandoc-presentation-creator/beamer-full:latest \
  -c "/data/buildPDF"
```

### 5. VS Code Integration

Open the project in VS Code and press **Ctrl+Shift+B** to build and render.

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
├── templates/          # Project init templates (used by init.sh)
├── .vscode/            # VS Code configuration (tasks, settings)
└── output/             # Generated PDFs (gitignored)
```

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

Edit `config/metadata.yaml` for title, author, date, and other document metadata.

Add a YAML front matter block to your slide file:

```yaml
---
title: My Presentation
author: Jane Doe
date: March 2026
---
```

### Custom Defaults File

Create `config/custom.yaml` with any extra pandoc/beamer settings, then pass it via `DEFAULTS_FILE`:

```bash
docker run --rm \
  -v "$(pwd):/data" \
  --entrypoint=/bin/sh \
  -e INPUT_FILE=/data/slides/YourPresentation.md \
  -e OUTPUT_FILE=/data/output/YourPresentation.pdf \
  -e DEFAULTS_FILE=/data/config/custom.yaml \
  registry.gitlab.com/woofiowo/pandoc-presentation-creator/beamer-full:latest \
  -c "/data/buildPDF"
```

---

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

- Automated Docker builds with security scanning (gitleaks, Semgrep, Trivy)
- Reproducible builds with version tagging
- Registry image auto-published on tagged releases

### Modern Beamer Presentation

- Metropolis theme with professional styling
- Custom footer: Date | Author | Page x of y
- International date format support
- 16:9 aspect ratio

---

## Troubleshooting

### LaTeX Error: File not found

Ensure `resource-path` in `beamer.yaml` includes all necessary directories.

### Extra Empty Slides

Set `slide-level: 1` and use `#` for slides (not `---` separators).

### Permission Denied in Container

Use `--user root` for volume-mounted outputs.

### Windows: `file not found` when running scripts

Ensure line endings are LF for shell scripts:

```bash
git add --renormalize .
```

Then commit. `.gitattributes` already enforces LF for shell scripts.

### `/data/buildPDF: not found` in container

Ensure `buildPDF` exists in project root and is executable:

```bash
chmod +x buildPDF
```

---

## Dependencies

### Container Runtime

- Docker (tested with 20.10+)

### Baked into Container

- Pandoc 3.x
- XeLaTeX (TeX Live)
- Python 3 with YAML support
- Beamer theme support
- Custom LaTeX templates and filters

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for full instructions.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Contact

- **Maintainer:** Philip Kofler
- **Email:** <koflerphillip@outlook.com>
- **Repository:** [GitLab - pandoc-presentation-creator](https://gitlab.com/WoofiOwO/pandoc-presentation-creator)
- **Issues:** Use GitLab Issues for bug reports and feature requests

---

***Last updated: March 2026***
