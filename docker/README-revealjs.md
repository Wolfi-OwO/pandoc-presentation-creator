# Pandoc Reveal.js Image

Docker Image mit Pandoc + Node.js für interaktive HTML-Präsentationen mit Reveal.js.

## Verwendungszweck

- Interaktive Web-Präsentationen
- HTML5-Slides mit Reveal.js
- Responsive Design
- Speaker Notes Support

## Image Details

- **Base**: Alpine Linux 3.19 + Node.js 20
- **Pandoc**: v3.1.11
- **Size**: ~80 MB
- **Platforms**: linux/amd64, linux/arm64
- **User**: non-root (pandoc:1000)
- **Includes**: Templates, Filters, CSS

## Schnellstart

```bash
# Einfache Präsentation
docker run --rm -v $(pwd):/data \
  yourusername/pandoc-presentation-revealjs:latest \
  -d /pandoc/defaults/revealjs.yaml \
  slides.md -o output.html

# Mit Custom Theme
docker run --rm -v $(pwd):/data \
  yourusername/pandoc-presentation-revealjs:latest \
  slides.md \
  --to revealjs \
  --standalone \
  -V theme=sky \
  -V transition=zoom \
  -o presentation.html
```

## Features

- [OK] Vorinstallierte Reveal.js defaults
- [OK] Custom CSS Templates
- [OK] Lua-Filter (Boxen, Spalten)
- [OK] Mathematische Formeln (MathJax)
- [OK] Code-Highlighting
- [OK] Speaker Notes

## Dokumentation

Vollständige Dokumentation: [GitLab Repository](https://gitlab.com/woofi4/public/pandoc-presentation-creator)

## Tags

- `latest` - Neueste Version
- `vX.Y.Z` - Spezifische Versionen
- `revealjs` - Format-Tag

## Related Images

- [pandoc-presentation-base](https://hub.docker.com/r/yourusername/pandoc-presentation-base) - Basis-Image
- [pandoc-presentation-beamer](https://hub.docker.com/r/yourusername/pandoc-presentation-beamer) - PDF-Präsentationen
