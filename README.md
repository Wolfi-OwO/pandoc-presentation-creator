# Pandoc Presentation Creator

> **Docker-First** | Modulares, skalierbares System zur Erstellung professioneller Präsentationen mit Pandoc

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![Pandoc](https://img.shields.io/badge/Pandoc-3.1.11-green.svg)](https://pandoc.org/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitLab%20CI-brightgreen.svg)](https://docs.gitlab.com/ee/ci/)

## Inhaltsverzeichnis

- [Überblick](#überblick)
- [Docker-First Philosophie](#docker-first-philosophie)
- [Features](#features)
- [Schnellstart](#schnellstart)
- [Docker Images](#docker-images)
- [Installation](#installation)
- [Verwendung](#verwendung)
  - [Docker CLI](#docker-cli)
  - [Docker Compose](#docker-compose)
  - [Build-Skripte](#build-skripte)
- [CI/CD Pipeline](#cicd-pipeline)
- [Projektstruktur](#projektstruktur)
- [Konfiguration](#konfiguration)
- [Erweiterte Features](#erweiterte-features)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Beitragen](#beitragen)
- [Lizenz](#lizenz)

---

## Überblick

Dieses Projekt bietet ein **Docker-first** Setup zur Erstellung von Präsentationen in verschiedenen Formaten (Reveal.js, Beamer, PowerPoint) mit Pandoc. Der Fokus liegt auf:

- **Docker-First**: Keine lokale Pandoc-Installation erforderlich!
- **Modularität**: Kleine, spezialisierte Docker Images (~40-250 MB)
- **CI/CD**: Automatische Builds und Veröffentlichung auf GitLab Container Registry
- **Performance**: Parallele Downloads, optimiertes Caching
- **Wartbarkeit**: Klare Struktur, ausführliche Dokumentation
- **Plattformunabhängigkeit**: Läuft überall wo Docker läuft

### Warum dieses Projekt?

- **Markdown statt WYSIWYG**: Fokus auf Inhalt, nicht auf Formatierung
- **Versionskontrolle**: Git-freundliche Textdateien
- **Docker-First**: Keine Dependency-Hell, konsistente Umgebung
- **Wiederverwendbar**: Einmal konfiguriert, immer wieder nutzbar
- **Professionell**: Hochwertige Ausgabe in verschiedenen Formaten
- **CI/CD-Ready**: Automatische Builds und Tests

---

## Docker-First Philosophie

**Docker ist die EINZIGE Abhängigkeit für dieses Projekt.**

### Warum Docker-First?

1. **Keine lokale Installation**: Kein Pandoc, LaTeX oder Node.js lokal installieren
2. **Konsistente Umgebung**: Gleiche Ergebnisse auf allen Systemen
3. **Versionskontrolle**: Docker Images sind versioniert und reproduzierbar
4. **Isolation**: Keine Konflikte mit anderen Installationen
5. **Updates**: Neue Versionen einfach per `docker pull`
6. **CI/CD**: Perfekt für automatisierte Builds

### Image-Strategie: Klein & Modular

Statt eines großen Monolithen gibt es **drei spezialisierte Images**:

| Image | Größe | Verwendung | Enthält |
|-------|-------|------------|---------|
| **pandoc-base** | ~40 MB | Einfache Konvertierungen | Pandoc + Alpine |
| **pandoc-revealjs** | ~80 MB | HTML-Präsentationen | Base + Node.js + Reveal.js |
| **pandoc-beamer** | ~250 MB | PDF-Präsentationen | Pandoc + minimal LaTeX |

**Vorteile:**
- Paralleles Downloaden mehrerer Images
- Nur herunterladen was benötigt wird
- Schnellere Updates (nur betroffene Layers)
- Effizientes Caching

### Architektur

```
┌──────────────────────────────────────────────────────────┐
│          GitLab Container Registry (Public)              │
│ registry.gitlab.com/woofi4/public/pandoc-presentation-* │
└──────────────────────────────────────────────────────────┘
                           ▲
                           │
                 Automatischer Push bei
                    Git Push/Tag
                           │
┌──────────────────────────────────────────────────────────┐
│                   GitLab CI/CD                           │
│  • Parallel Builds (base, revealjs, beamer)             │
│  • Multi-Platform (amd64, arm64)                        │
│  • Layer Caching                                         │
│  • Automatische Tests                                    │
└──────────────────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────┐
│                  Lokale Entwicklung                      │
│  docker run --rm -v $(pwd):/data \                      │
│    pandoc-revealjs slides.md -o output.html             │
└──────────────────────────────────────────────────────────┘
```

---

## Features

### Unterstützte Ausgabeformate

| Format         | Typ  | Beschreibung                              | Anwendungsfall                                |
|----------------|------|-------------------------------------------|-----------------------------------------------|
| **Reveal.js**  | HTML | Interaktive Web-Präsentationen            | Konferenzen, Workshops, Online-Präsentationen |
| **Beamer**     | PDF  | LaTeX-basierte akademische Präsentationen | Wissenschaftliche Vorträge, Universitäten     |
| **PowerPoint** | PPTX | Microsoft PowerPoint                      | Business-Präsentationen, Corporate            |

### Kern-Features

- **Markdown-basiert**: Schreiben Sie Ihre Präsentationen in einfachem Markdown
- **Template-System**: Anpassbare Vorlagen für jeden Präsentationstyp
- **Defaults Files**: Pandoc-Konfiguration zentral verwaltet
- **Metadata-Management**: Wiederverwendbare Metadaten (Autor, Titel, etc.)
- **Custom Filters**: Lua-Filter für erweiterte Funktionalität
- **Styling**: CSS für Reveal.js, LaTeX-Pakete für Beamer
- **Cross-Platform**: Setup-Skripte für Linux, macOS und Windows
- **Schnellstart**: Interaktive Setup-Assistenten

---

## Schnellstart

### Docker-First Setup (Empfohlen)

**Voraussetzung: Nur Docker installiert!**

#### Schritt 1: Docker-Setup ausführen

```bash
# Repository klonen
git clone https://gitlab.com/woofi4/public/pandoc-presentation-creator.git
cd pandoc-presentation-creator

# Docker-Setup starten
chmod +x setup-docker.sh
./setup-docker.sh
```

Das Script:
- Prüft Docker-Installation
- Installiert Docker falls nötig (Linux)
- Pullt benötigte Images von GitLab Container Registry
- Erstellt Wrapper-Skripte
- Generiert Test-Präsentation

#### Schritt 2: Erste Präsentation erstellen

```bash
# Mit Docker direkt
docker run --rm -v $(pwd):/data \
  registry.gitlab.com/woofi4/public/pandoc-presentation-revealjs:latest \
  -d /pandoc/defaults/revealjs.yaml examples/minimal.md -o output/test.html

# Oder mit Build-Script
./scripts/build-docker.sh revealjs examples/example-presentation.md

# Oder mit Docker Compose
docker compose run --rm revealjs \
  -d /pandoc/defaults/revealjs.yaml examples/minimal.md -o output/test.html
```

### Alternative: Lokale Installation (Legacy)

Wenn Sie Docker nicht nutzen möchten:

```bash
# 1. Pandoc lokal installieren
# Linux: sudo apt install pandoc
# macOS: brew install pandoc

# 2. Repository klonen
git clone https://gitlab.com/woofi4/public/pandoc-presentation-creator.git
cd pandoc-presentation-creator

# 3. Lokales Setup
chmod +x setup.sh
./setup.sh

# 4. Präsentation erstellen
./scripts/build.sh revealjs examples/example-presentation.md
```

---

## Docker Images

### Image-Matrix

| Image | GitLab Registry | Größe | Platform | Verwendung |
|-------|-----------|-------|----------|------------|
| **pandoc-base** | `registry.gitlab.com/woofi4/public/pandoc-presentation-base:latest` | ~40 MB | amd64, arm64 | Basis-Konvertierungen |
| **pandoc-revealjs** | `registry.gitlab.com/woofi4/public/pandoc-presentation-revealjs:latest` | ~80 MB | amd64, arm64 | HTML-Präsentationen |
| **pandoc-beamer** | `registry.gitlab.com/woofi4/public/pandoc-presentation-beamer:latest` | ~250 MB | amd64 | PDF-Präsentationen |

### Image Tags

Jedes Image ist verfügbar mit:
- `latest` - Neueste Version vom main branch
- `vX.Y.Z` - Spezifische Version (z.B. `v1.0.0`)
- `{base,revealjs,beamer}` - Format-spezifischer Tag

### Images pullen

```bash
# Einzelnes Image
docker pull registry.gitlab.com/woofi4/public/pandoc-presentation-revealjs:latest

# Alle Images
docker pull registry.gitlab.com/woofi4/public/pandoc-presentation-base:latest
docker pull registry.gitlab.com/woofi4/public/pandoc-presentation-revealjs:latest
docker pull registry.gitlab.com/woofi4/public/pandoc-presentation-beamer:latest

# Spezifische Version
docker pull registry.gitlab.com/woofi4/public/pandoc-presentation-revealjs:v1.0.0
```

### Images lokal bauen

Falls Sie die Images selbst bauen möchten:

```bash
# Base Image
docker build -f docker/Dockerfile.base -t pandoc-base:latest .

# Reveal.js Image
docker build -f docker/Dockerfile.revealjs -t pandoc-revealjs:latest .

# Beamer Image
docker build -f docker/Dockerfile.beamer -t pandoc-beamer:latest .

# Alle parallel bauen
docker build -f docker/Dockerfile.base -t pandoc-base:latest . &
docker build -f docker/Dockerfile.revealjs -t pandoc-revealjs:latest . &
docker build -f docker/Dockerfile.beamer -t pandoc-beamer:latest . &
wait
```

---

## Installation

### Voraussetzungen

#### Docker-First Ansatz (Empfohlen)

**Einzige Voraussetzung: Docker**

- **Docker** (Version 20.10+)
  ```bash
  # Linux - Automatische Installation
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker $USER
  
  # macOS
  # Download Docker Desktop: https://docs.docker.com/desktop/install/mac-install/
  
  # Windows
  # Download Docker Desktop: https://docs.docker.com/desktop/install/windows-install/
  
  # Version prüfen
  docker --version
  docker compose version
  ```

**Das war's!** Mit Docker benötigen Sie:
- Kein Pandoc lokal
- Kein LaTeX lokal
- Kein Node.js lokal
- Nur Docker

#### Legacy: Lokale Installation (Optional)

Falls Sie ohne Docker arbeiten möchten:

  ```bash
  # Linux (Debian/Ubuntu)
  sudo apt install pandoc
  
  # macOS
  brew install pandoc
  
  # Windows
  # Download von https://pandoc.org/installing.html
  ```

- **Git**

  ```bash
  # Linux (Debian/Ubuntu)
  sudo apt install git
  
  # macOS
  brew install git
  
  # Windows
  # Download von https://git-scm.com/downloads
  ```

#### Optional (abhängig vom Format)

- **LaTeX** (für Beamer/PDF)

  ```bash
  # Linux (Debian/Ubuntu)
  sudo apt install texlive-xetex texlive-fonts-recommended
  
  # macOS
  brew install --cask mactex
  
  # Windows
  # Download von https://www.tug.org/texlive/
  ```

- **Node.js** (für erweiterte Reveal.js Features)

  ```bash
  # Linux (Debian/Ubuntu)
  sudo apt install nodejs npm
  
  # macOS
  brew install node
  
  # Windows
  # Download von https://nodejs.org/
  ```

### Versionen prüfen

```bash
pandoc --version
git --version
xelatex --version  # Optional für Beamer
node --version     # Optional
```

---

## Projektstruktur

```
pandoc-presentation-creator/
│
├── defaults/                     # Pandoc Defaults Files
│   ├── revealjs.yaml            # Konfiguration für Reveal.js
│   ├── beamer.yaml              # Konfiguration für Beamer
│   └── pptx.yaml                # Konfiguration für PowerPoint
│
├── templates/                    # Custom Templates
│   ├── revealjs/                # Reveal.js Templates
│   ├── beamer/                  # Beamer Templates
│   └── pptx/                    # PowerPoint Templates
│
├── metadata/                     # Zentrale Metadaten
│   ├── common.yaml              # Gemeinsame Metadaten (Autor, etc.)
│   └── presentation.yaml        # Projektspezifische Metadaten
│
├── filters/                      # Pandoc Lua-Filter
│   ├── boxes.lua                # Custom Box-Elemente
│   └── columns.lua              # Mehrspaltige Layouts
│
├── includes/                     # Include-Dateien
│   ├── header/                  # Header-Includes
│   │   ├── revealjs-custom.html # Custom HTML für Reveal.js
│   │   └── beamer-packages.tex  # LaTeX-Pakete für Beamer
│   └── footer/                  # Footer-Includes
│       └── revealjs-footer.html # Custom Footer für Reveal.js
│
├── assets/                       # Zusätzliche Ressourcen
│   ├── css/                     # Stylesheets
│   │   └── custom-revealjs.css  # Custom CSS für Reveal.js
│   └── images/                  # Bilder und Grafiken
│
├── examples/                     # Beispiel-Präsentationen
│   ├── example-presentation.md  # Umfangreiches Beispiel
│   └── minimal.md               # Minimales Beispiel
│
├── scripts/                      # Hilfs-Skripte
│   ├── build.sh                 # Legacy Build-Script (lokal)
│   ├── build-docker.sh          # Docker Build-Script
│   └── build.bat                # Windows Build-Script
│
├── output/                       # Generierte Präsentationen
│   └── .gitkeep
│
├── docker-compose.yml            # Docker Compose Konfiguration
├── .dockerignore                 # Docker Build Context Filter
├── setup.sh                      # Legacy Setup (lokal)
├── setup-docker.sh               # Docker-First Setup
├── setup.bat                     # Windows Setup
├── README.md                     # Diese Datei
├── .gitignore                    # Git Ignore-Regeln
└── Makefile                      # Make-Targets
```

### Verzeichnis-Erklärungen

#### `/defaults` - Pandoc Defaults Files

Enthält zentrale Konfigurationsdateien für jeden Output-Typ. Diese Dateien definieren:

- Output-Format und -Datei
- Markdown-Erweiterungen
- Template-Referenzen
- Filter-Ketten
- Include-Dateien
- Variablen und Optionen

**Vorteil**: Ein einziger Befehl `pandoc -d defaults/revealjs.yaml input.md` statt langer Kommandozeilen-Argumente.

#### `/templates` - Custom Templates

Optionale eigene Templates für erweiterte Anpassungen. Pandoc verwendet standardmäßig eingebaute Templates, aber hier können eigene Varianten hinterlegt werden.

#### `/metadata` - Zentrale Metadaten

- `common.yaml`: Daten, die in allen Präsentationen gleich sind (Autor, Organisation)
- `presentation.yaml`: Projektspezifische Überschreibungen

Diese werden automatisch in die Defaults-Files eingebunden.

#### `/filters` - Lua-Filter

Pandoc-Filter in Lua für erweiterte Transformationen:

- Custom Markdown-Syntax
- Spezielle Formatierungen
- Format-spezifische Anpassungen

#### `/includes` - Include-Dateien

Zusätzlicher Code, der in die generierten Dokumente eingefügt wird:

- HTML/CSS/JavaScript für Reveal.js
- LaTeX-Pakete und -Befehle für Beamer

#### `/assets` - Statische Ressourcen

Bilder, Stylesheets und andere Dateien, die in Präsentationen verwendet werden.

---

## Verwendung

### Docker CLI

Die grundlegendste Art, die Docker Images zu verwenden:

#### Reveal.js (HTML)

```bash
# Einfache Verwendung
docker run --rm \
  -v $(pwd):/data \
  registry.gitlab.com/woofi4/public/pandoc-presentation-revealjs:latest \
  -d /pandoc/defaults/revealjs.yaml \
  examples/minimal.md -o output/slides.html

# Mit spezifischen Optionen
docker run --rm \
  -v $(pwd):/data \
  -u $(id -u):$(id -g) \
  registry.gitlab.com/woofi4/public/pandoc-presentation-revealjs:latest \
  examples/example-presentation.md \
  --to revealjs \
  --standalone \
  --output output/presentation.html
```

#### Beamer (PDF)

```bash
# Standard Beamer-Präsentation
docker run --rm \
  -v $(pwd):/data \
  registry.gitlab.com/woofi4/public/pandoc-presentation-beamer:latest \
  -d /pandoc/defaults/beamer.yaml \
  examples/minimal.md -o output/slides.pdf

# Mit XeLaTeX und custom Fonts
docker run --rm \
  -v $(pwd):/data \
  registry.gitlab.com/woofi4/public/pandoc-presentation-beamer:latest \
  examples/example-presentation.md \
  --to beamer \
  --pdf-engine=xelatex \
  --output output/presentation.pdf
```

#### Base Image (Allgemein)

```bash
# Markdown zu HTML
docker run --rm \
  -v $(pwd):/data \
  registry.gitlab.com/woofi4/public/pandoc-presentation-base:latest \
  examples/minimal.md -o output/simple.html

# Mit vielen Optionen
docker run --rm \
  -v $(pwd):/data \
  registry.gitlab.com/woofi4/public/pandoc-presentation-base:latest \
  --from markdown \
  --to html5 \
  --standalone \
  --toc \
  examples/example-presentation.md -o output/doc.html
```

### Docker Compose

Einfachere Verwendung mit vorkonfigurierten Services:

#### Setup

```bash
# Einmalig: Environment setzen
export UID=$(id -u)
export GID=$(id -g)

# Optional: In .env Datei speichern
cat > .env << EOF
UID=$(id -u)
GID=$(id -g)
EOF
```

#### Verwendung

```bash
# Reveal.js
docker compose run --rm revealjs \
  -d /pandoc/defaults/revealjs.yaml \
  examples/minimal.md -o output/slides.html

# Beamer
docker compose run --rm beamer \
  -d /pandoc/defaults/beamer.yaml \
  examples/minimal.md -o output/slides.pdf

# Base
docker compose run --rm base \
  examples/minimal.md -o output/simple.html

# Watch-Mode (automatische Rebuilds bei Änderungen)
docker compose --profile watch up
```

### Build-Skripte

Wrapper-Skripte für einfachere Verwendung:

#### Linux / macOS

```bash
# Build-Script ausführbar machen
chmod +x scripts/build-docker.sh

# Verwendung
./scripts/build-docker.sh revealjs examples/example-presentation.md
./scripts/build-docker.sh beamer examples/minimal.md
./scripts/build-docker.sh base input.md -o output/custom.html

# Mit spezifischem Output
./scripts/build-docker.sh revealjs slides.md --output my-presentation.html
```

Das Script:
- Prüft Docker-Installation
- Pullt Images automatisch (oder baut sie lokal)
- Führt Pandoc im Container aus
- Setzt korrekte Dateirechte

#### Windows

```cmd
REM Build-Script aufrufen
scripts\build-docker.bat revealjs examples\example-presentation.md
scripts\build-docker.bat beamer examples\minimal.md
```

### Wrapper-Script erstellen

Für noch einfachere Verwendung ein Wrapper-Script erstellen:

```bash
# pandoc-docker Script
cat > pandoc-docker << 'EOF'
#!/usr/bin/env bash
IMAGE=${1:-base}
shift
docker run --rm -v $(pwd):/data -u $(id -u):$(id -g) \
  registry.gitlab.com/woofi4/public/pandoc-presentation-${IMAGE}:latest "$@"
EOF

chmod +x pandoc-docker

# Verwendung
./pandoc-docker revealjs -d /pandoc/defaults/revealjs.yaml slides.md -o output.html
./pandoc-docker beamer -d /pandoc/defaults/beamer.yaml slides.md -o output.pdf
```

### Shell-Aliase

Für maximale Bequemlichkeit:

```bash
# In ~/.bashrc oder ~/.zshrc
alias pandoc-base='docker run --rm -v $(pwd):/data registry.gitlab.com/woofi4/public/pandoc-presentation-base:latest'
alias pandoc-revealjs='docker run --rm -v $(pwd):/data registry.gitlab.com/woofi4/public/pandoc-presentation-revealjs:latest'
alias pandoc-beamer='docker run --rm -v $(pwd):/data registry.gitlab.com/woofi4/public/pandoc-presentation-beamer:latest'

# Dann einfach:
pandoc-revealjs -d /pandoc/defaults/revealjs.yaml slides.md -o output.html
pandoc-beamer -d /pandoc/defaults/beamer.yaml slides.md -o output.pdf
```

### Makefile-Integration

Mit Make für noch einfachere Verwendung:

```bash
# Vorhandenes Makefile nutzen
make revealjs INPUT=examples/minimal.md
make beamer INPUT=examples/example-presentation.md

# Alle Formate
make all INPUT=meine-praesentation.md

# Aufräumen
make clean
```

---

## CI/CD Pipeline

### GitLab CI/CD Workflow

Das Projekt enthält eine vollständige CI/CD-Pipeline in `.gitlab-ci.yml`.

#### Features

- **Parallel Builds**: base, revealjs und beamer gleichzeitig
- **Multi-Platform**: amd64 und arm64 (außer beamer)
- **Layer Caching**: Schnellere Builds durch GitLab CI Cache
- **Automatische Tests**: Images werden nach dem Build getestet
- **GitLab Container Registry Push**: Automatische Veröffentlichung bei Push/Tags
- **Version Tags**: Automatische Versionierung bei Git Tags

#### Trigger

Die Pipeline wird ausgelöst bei:

```yaml
# Push auf main Branch
git push origin main

# Git Tags (Versionierung)
git tag v1.0.0
git push origin v1.0.0

# Merge Requests (nur Build, kein Push)
# Automatisch bei MR-Erstellung
```

#### Setup (einmalig)

1. **GitLab CI/CD aktivieren**
   ```
   Repository → Settings → CI/CD
   Stellen Sie sicher, dass "CI/CD Pipelines" aktiviert ist
   ```

2. **GitLab Container Registry aktivieren**
   ```
   Repository → Settings → Integrations
   GitLab Container Registry ist standardmäßig aktiviert
   ```

3. **Workflow starten**
   ```bash
   # Einfach pushen - Workflow startet automatisch
   git add .gitlab-ci.yml
   git commit -m "Add GitLab CI/CD pipeline"
   git push origin main
   ```

#### Workflow-Struktur

```yaml
Stages:
1. build-base      → Baut base Image (40 MB)
2. build-revealjs  → Baut revealjs Image (80 MB)
3. build-beamer    → Baut beamer Image (250 MB)
4. test-images     → Testet alle Images
5. update-docs     → Updated GitLab Container Registry Beschreibungen
```

#### Logs und Monitoring

```bash
# GitLab CI/CD Logs ansehen
# Repository → CI/CD → Pipelines → Pipeline auswählen

# Images überprüfen
docker pull registry.gitlab.com/woofi4/public/pandoc-presentation-base:latest
docker pull registry.gitlab.com/woofi4/public/pandoc-presentation-revealjs:latest
docker pull registry.gitlab.com/woofi4/public/pandoc-presentation-beamer:latest

# Image-Details
docker inspect registry.gitlab.com/woofi4/public/pandoc-presentation-revealjs:latest
```

#### Versionierung

```bash
# Release erstellen
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Images werden automatisch getagged mit:
# - latest
# - v1.0.0
# - 1.0
# - revealjs, beamer, base
```

---

```bash
# Reveal.js Präsentation erstellen
./scripts/build.sh revealjs examples/example-presentation.md

# Beamer PDF erstellen
./scripts/build.sh beamer examples/example-presentation.md

# PowerPoint erstellen
./scripts/build.sh pptx examples/example-presentation.md

# Custom Output-Datei
./scripts/build.sh revealjs input.md -o custom-output.html
```

#### Mit Pandoc direkt

```bash
# Reveal.js
pandoc -d defaults/revealjs.yaml examples/example-presentation.md

# Beamer
pandoc -d defaults/beamer.yaml examples/example-presentation.md

# PowerPoint
pandoc -d defaults/pptx.yaml examples/example-presentation.md
```

#### Mit Makefile

```bash
# Reveal.js
make revealjs

# Beamer
make beamer

# PowerPoint
make pptx

# Output-Verzeichnis leeren
make clean
```

### Eigene Präsentation erstellen

1. **Neue Markdown-Datei erstellen**

```bash
# Neue Datei anlegen
touch meine-praesentation.md
```

1. **Inhalt schreiben**

```markdown
---
title: "Meine Präsentation"
author: "Ihr Name"
date: 2026-01-10
---

# Erste Folie

Inhalt der ersten Folie.

---

# Zweite Folie

- Punkt 1
- Punkt 2
- Punkt 3

---

# Code-Beispiel

\`\`\`python
def hello():
    print("Hello, World!")
\`\`\`
```

1. **Präsentation erstellen**

```bash
./scripts/build.sh revealjs meine-praesentation.md
```

---

## Konfiguration

### Defaults Files anpassen

Jedes Format hat eine eigene Defaults-Datei in `/defaults`. Diese können Sie nach Ihren Wünschen anpassen.

#### Beispiel: Reveal.js Theme ändern

Öffnen Sie `defaults/revealjs.yaml`:

```yaml
variables:
  # Theme ändern
  theme: sky  # Optionen: black, white, league, beige, sky, night, serif, simple, solarized
  
  # Transition ändern
  transition: zoom  # Optionen: none, fade, slide, convex, concave, zoom
```

#### Beispiel: Beamer Theme ändern

Öffnen Sie `defaults/beamer.yaml`:

```yaml
variables:
  # Theme ändern
  theme: Madrid  # Optionen: siehe Beamer-Dokumentation
  
  # Color Theme ändern
  colortheme: dolphin
```

### Metadaten anpassen

Bearbeiten Sie `metadata/common.yaml`:

```yaml
author:
  - Ihr Name
  - Weiterer Autor

institute: "Ihre Organisation"

lang: de-DE  # Sprache

keywords:
  - Schlagwort 1
  - Schlagwort 2
```

### Custom CSS hinzufügen

Für Reveal.js können Sie `assets/css/custom-revealjs.css` bearbeiten:

```css
/* Eigene Schriftart */
.reveal {
  font-family: 'Your Font', sans-serif;
}

/* Eigene Farben */
.reveal h1 {
  color: #2196F3;
}
```

### Filter aktivieren

In den Defaults-Files (z.B. `defaults/revealjs.yaml`):

```yaml
filters:
  - filters/boxes.lua
  - filters/columns.lua
```

---

## Erweiterte Features

### Custom Boxen

Verwenden Sie spezielle Markdown-Syntax für formatierte Boxen:

```markdown
::: info
Dies ist eine Info-Box!
:::

::: warning
Dies ist eine Warnung!
:::

::: success
Dies ist eine Erfolgs-Meldung!
:::
```

Funktioniert mit dem `filters/boxes.lua` Filter (muss in Defaults aktiviert sein).

### Mehrspaltige Layouts

```markdown
::: columns
:::: column
Linke Spalte

- Punkt 1
- Punkt 2
::::

:::: column
Rechte Spalte

- Punkt A
- Punkt B
::::
:::
```

Funktioniert mit dem `filters/columns.lua` Filter.

### Speaker Notes

Fügen Sie Notizen für den Sprecher hinzu:

```markdown
# Folie mit Notizen

Hier der sichtbare Inhalt.

::: notes
Diese Notizen sieht nur der Sprecher:
- Wichtigen Punkt betonen
- Beispiel nennen
:::
```

### Inkrementelle Anzeige

Listen werden Punkt für Punkt eingeblendet:

```markdown
::: incremental
- Erscheint zuerst
- Dann dieser Punkt
- Und zuletzt dieser
:::
```

### Mathematische Formeln

Inline: `$E = mc^2$`

Block:

```markdown
$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$
```

### Bilder einfügen

```markdown
![Bildbeschreibung](assets/images/bild.png)

# Oder mit Größenangabe
![Bildbeschreibung](assets/images/bild.png){width=80%}
```

---

## Best Practices

### Markdown-Struktur

1. **Eine Überschrift H1 pro Datei** (wird zum Titel)
2. **H2 (`##`) für Folien** in Reveal.js und Beamer
3. **Trennung mit `---`** für neue Folien
4. **Konsistente Einrückung** für Listen

### Metadaten-Management

- Gemeinsame Daten in `metadata/common.yaml`
- Projektspezifisches in eigenen YAML-Dateien
- Metadaten können pro Präsentation überschrieben werden (YAML-Header)

### Versionskontrolle

```bash
# Empfohlene .gitignore-Einträge
output/
*.pdf
*.html
*.pptx
```

Aber: Behalten Sie Templates und Konfigurationen im Repository.

### Wiederverwendbarkeit

- **Templates**: Einmal erstellen, oft nutzen
- **Metadata**: Zentral verwalten
- **Filters**: Projektübergreifend einsetzbar
- **Assets**: Logos, Styles gemeinsam nutzen

### Performance

- Große Bilder komprimieren
- Unnötige Includes entfernen
- Filter nur aktivieren wenn benötigt

---

## Troubleshooting

### Pandoc-Fehler: "Could not find..."

**Problem**: Pandoc findet Dateien nicht.

**Lösung**:

- Verwenden Sie relative Pfade vom Projekt-Root
- Prüfen Sie Pfade in den Defaults-Files
- Stellen Sie sicher, dass Sie im Projekt-Verzeichnis sind

### LaTeX-Fehler bei Beamer

**Problem**: `! LaTeX Error: File 'xyz.sty' not found`

**Lösung**:

```bash
# Fehlende LaTeX-Pakete installieren
sudo apt install texlive-latex-extra texlive-fonts-extra  # Linux
```

### Reveal.js CSS wird nicht angewendet

**Problem**: Custom CSS wird nicht geladen.

**Lösung**:

- Prüfen Sie Pfad in `defaults/revealjs.yaml`
- CSS-Datei muss relativ zur Output-Datei erreichbar sein
- Oder verwenden Sie absolute URLs

### Windows: Script kann nicht ausgeführt werden

**Problem**: `setup.bat` startet nicht.

**Lösung**:

- Rechtsklick → "Als Administrator ausführen"
- Oder öffnen Sie CMD als Administrator

### Encoding-Probleme

**Problem**: Umlaute werden falsch dargestellt.

**Lösung**:

- Speichern Sie Markdown-Dateien als UTF-8
- Fügen Sie in Defaults hinzu:

  ```yaml
  from: markdown+utf8
  ```

---

## Beispiele & Tutorials

### Beispiel 1: Schnelle Business-Präsentation

```markdown
---
title: "Q4 Geschäftsbericht"
author: "Max Mustermann"
date: 2026-01-10
institute: "Firma GmbH"
---

## Übersicht

- Umsatz +15%
- Neue Kunden: 234
- Erfolgreiche Projekte: 42

---

## Detailanalyse

![Umsatzentwicklung](assets/images/chart.png)
```

Erstellen:

```bash
./scripts/build.sh pptx business-presentation.md
```

### Beispiel 2: Akademischer Vortrag

```markdown
---
title: "Forschungsergebnisse 2026"
author:
  - Dr. Anna Schmidt
  - Prof. Dr. Thomas Müller
institute: "Universität Beispielstadt"
---

## Forschungsfrage

Wie beeinflusst Faktor X das Ergebnis Y?

::: notes
Hier betonen: Vorherige Studien haben dies nicht betrachtet
:::

---

## Methodik

1. Datenerhebung
2. Statistische Analyse  
3. Validierung

$$
\bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i
$$
```

Erstellen:

```bash
./scripts/build.sh beamer academic-presentation.md
```

---

## Beitragen

Beiträge sind willkommen! So können Sie helfen:

1. **Forken** Sie das Repository
2. **Erstellen** Sie einen Feature-Branch (`git checkout -b feature/amazing-feature`)
3. **Committen** Sie Ihre Änderungen (`git commit -m 'Add amazing feature'`)
4. **Pushen** Sie den Branch (`git push origin feature/amazing-feature`)
5. **Öffnen** Sie einen Merge Request

### Bereiche für Beiträge

- Neue Templates
- Zusätzliche Lua-Filter
- Verbesserungen der Dokumentation
- Bug-Fixes
- Neue Output-Formate (z.B. S5, Slidy)

---

## Ressourcen & Links

### Offizielle Dokumentation

- [Pandoc Manual](https://pandoc.org/MANUAL.html)
- [Pandoc Defaults Files](https://pandoc.org/MANUAL.html#defaults-files)
- [Reveal.js Documentation](https://revealjs.com/)
- [Beamer User Guide](https://ctan.org/pkg/beamer)
- [Markdown Guide](https://www.markdownguide.org/)

### Lua-Filter

- [Pandoc Lua Filters](https://pandoc.org/lua-filters.html)
- [Filter Examples](https://github.com/pandoc/lua-filters)

### LaTeX

- [LaTeX Wikibook](https://en.wikibooks.org/wiki/LaTeX)
- [CTAN](https://ctan.org/) - Comprehensive TeX Archive Network

### Inspiration

- [Pandoc-Goodies](https://github.com/tajmone/pandoc-goodies)
- [Awesome Pandoc](https://github.com/jgm/pandoc/wiki/User-contributed-templates)

---

## Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe [LICENSE](LICENSE) Datei für Details.

---

## Autoren

- **Phillip Kofler** - Initial work - [GitLab](https://gitlab.com/woofi4)

Siehe auch die Liste der [Contributors](https://gitlab.com/woofi4/public/pandoc-presentation-creator/-/graphs/main).

---

## Danksagungen

- [John MacFarlane](https://johnmacfarlane.net/) für Pandoc
- [Hakim El Hattab](https://hakim.se/) für Reveal.js
- Till Tantau für Beamer
- Allen Contributors und der Open-Source-Community

---

## Support

Bei Fragen oder Problemen:

- Fehler-Bericht: [Issues](https://gitlab.com/woofi4/public/pandoc-presentation-creator/-/issues)
- Diskussionen: [Discussions](https://gitlab.com/woofi4/public/pandoc-presentation-creator/-/discussions)
- E-Mail: koflerphillip@outlook.com

---

<div align="center">

**Wenn Ihnen dieses Projekt gefällt, geben Sie ihm einen Star auf GitLab!**

Made with Love and Pandoc

</div>
