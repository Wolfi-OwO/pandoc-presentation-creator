# Build Information

## Overview

This project uses **Pandoc** to convert Markdown files into **LaTeX Beamer** presentations (PDF). To ensure that all users have the same dependencies (fonts, packages, versions), we use **Docker**.

## The Docker Workflow

1. **Image Construction**: The `docker/Dockerfile.beamer` defines an image based on Debian. It installs:
    - Pandoc (Metadata conversion)
    - TeXLive (LaTeX distribution)
    - Ghostscript and standard fonts

2. **Execution**: When you run `scripts/build.sh`, it checks if it is inside a container.
    - If **No**: It invokes `docker run` to start the container and mounts your project folder.
    - If **Yes**: It runs the `pandoc` command to generate the PDF.

## Manual Build Command

If you prefer to run Pandoc manually without the helper script, use:

```bash
pandoc presentations/Project-Demo.md \
    -t beamer \
    --theme=Madrid \
    -o output/presentation.pdf \
    --standalone
```

## CI/CD Pipeline

The included `.gitlab-ci.yml` configuration automates this process:

1. It builds the Docker image.
2. It runs the build script inside the image.
3. It saves the resulting PDFs as GitLab Artifacts.
