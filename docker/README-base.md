# Pandoc Base Image

Minimales Alpine-basiertes Docker Image mit Pandoc für Dokument-Konvertierungen.

## Verwendungszweck

- Einfache Markdown-Konvertierungen
- Basis für andere Pandoc-Images
- Minimale Image-Größe (~40 MB)

## Image Details

- **Base**: Alpine Linux 3.19
- **Pandoc**: v3.1.11
- **Size**: ~40 MB
- **Platforms**: linux/amd64, linux/arm64
- **User**: non-root (pandoc:1000)

## Schnellstart

```bash
# Version anzeigen
docker run --rm yourusername/pandoc-presentation-base:latest --version

# Markdown zu HTML
docker run --rm -v $(pwd):/data \
  yourusername/pandoc-presentation-base:latest \
  input.md -o output.html

# Mit erweiterten Optionen
docker run --rm -v $(pwd):/data \
  yourusername/pandoc-presentation-base:latest \
  --from markdown \
  --to html5 \
  --standalone \
  --toc \
  document.md -o output.html
```

## Dokumentation

Vollständige Dokumentation: [GitLab Repository](https://gitlab.com/WoofiOwO/pandoc-presentation-creator)

## Tags

- `latest` - Neueste Version
- `vX.Y.Z` - Spezifische Versionen
- `base` - Format-Tag

## Related Images

- [pandoc-presentation-revealjs](https://hub.docker.com/r/yourusername/pandoc-presentation-revealjs) - HTML-Präsentationen
- [pandoc-presentation-beamer](https://hub.docker.com/r/yourusername/pandoc-presentation-beamer) - PDF-Präsentationen
