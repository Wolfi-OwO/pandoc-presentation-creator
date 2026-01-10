# Universal Presentation Engine (UPE)

An industrial-grade documentation factory for generating Beamer, Reveal.js, and PPTX from Markdown.

## 🏗 Directory Structure

- **core/**: Central configuration, templates, and filters.
- **themes/**: Asset libraries (logos, specific configs).
- **slides/**: User content (.md).
- **docker/**: The Omni-Container definition.
- **scripts/**: The Python logic engine.

## 🚀 How to Build

### Using Docker (Recommended)

Run the container mounting your current directory:

```bash
docker run --rm -v $(pwd):/data my-registry/upe:latest \
    --input slides/Project-Demo.md \
    --format all \
    --theme default
```

### Local Development

1. Ensure Pandoc and Python 3 are installed.
2. Run the wrapper:
   ```bash
   python3 scripts/build.py --input slides/Project-Demo.md
   ```

## ⚙️ Configuration

- **Global Defaults**: Edit `core/metadata/defaults.yaml`.
- **Per-Slide Config**: Add YAML metadata header to your .md files.
- **Themes**: Create a folder in `themes/` with a `config.yaml`.

## 🔄 CI/CD

The `.gitlab-ci.yml` automatically:
1. Builds the Docker image if changed.
2. Lints Markdown.
3. Compiles all slides in `slides/`.
4. Deploys HTML/PDFs to GitLab Pages.
