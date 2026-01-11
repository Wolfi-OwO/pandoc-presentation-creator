# Pandoc Beamer Image

Docker Image mit Pandoc + minimal LaTeX für professionelle PDF-Präsentationen.

## Verwendungszweck

- Akademische Präsentationen
- PDF-Slides mit Beamer
- LaTeX-basierte Typografie
- Wissenschaftliche Vorträge

## Image Details

- **Base**: Debian Bookworm Slim
- **Pandoc**: v3.1.11
- **LaTeX**: Minimal TeXLive + Beamer
- **Size**: ~250 MB
- **Platforms**: linux/amd64
- **User**: non-root (pandoc:1000)
- **Includes**: Templates, Filters, LaTeX-Pakete

## Schnellstart

```bash
# Standard Beamer-Präsentation
docker run --rm -v $(pwd):/data \
  yourusername/pandoc-presentation-beamer:latest \
  -d /pandoc/defaults/beamer.yaml \
  slides.md -o presentation.pdf

# Mit XeLaTeX
docker run --rm -v $(pwd):/data \
  yourusername/pandoc-presentation-beamer:latest \
  slides.md \
  --to beamer \
  --pdf-engine=xelatex \
  -V theme=metropolis \
  -o presentation.pdf

# Mit UBC-Preamble (Farbschema + Footer)
docker run --rm -v $(pwd):/data \
  yourusername/pandoc-presentation-beamer:latest \
  --defaults /data/core/defaults/beamer-preamble.yaml \
  /data/slides/Example.md \
  -o /data/output/presentation_preamble.pdf

# Shortcut-Skript (nutzt registries Image)
./scripts/build-docker-preamble.sh slides/Example.md
```

## Features

- [OK] Vorinstallierte Beamer defaults
- [OK] Minimal LaTeX Setup (optimierte Größe)
- [OK] XeLaTeX + PDFLaTeX Support
- [OK] Beamer Themes & Color Themes
- [OK] LaTeX-Pakete-Integration
- [OK] Mathematische Formeln
- [OK] TikZ-Grafiken

## Dokumentation

Vollständige Dokumentation: [GitLab Repository](https://gitlab.com/woofi4/public/pandoc-presentation-creator)

## Tags

- `latest` - Neueste Version
- `vX.Y.Z` - Spezifische Versionen
- `beamer` - Format-Tag

## Related Images

- [pandoc-presentation-base](https://hub.docker.com/r/yourusername/pandoc-presentation-base) - Basis-Image
- [pandoc-presentation-revealjs](https://hub.docker.com/r/yourusername/pandoc-presentation-revealjs) - HTML-Präsentationen

## [!] Hinweis

Dieses Image ist größer (~250 MB) aufgrund der LaTeX-Dependencies. Für minimale Image-Größe verwenden Sie base oder revealjs Images.
