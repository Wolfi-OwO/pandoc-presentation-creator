# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

## [Unreleased]

### Geplant

- Weitere Output-Formate (S5, Slidy)
- Web-Interface für Konfiguration
- Erweiterte Lua-Filter

## [2.0.0] - 2024-01-XX

### Geändert

- **BREAKING**: Vollständige Migration von GitHub zu GitLab
- **BREAKING**: Docker Hub durch GitLab Container Registry ersetzt
- **BREAKING**: GitHub Actions durch GitLab CI/CD ersetzt
- Docker-First Ansatz als Hauptfokus
- Alle Emojis aus Dokumentation entfernt
- Repository URL: https://gitlab.com/woofi4/public/pandoc-presentation-creator.git
- Container Registry: registry.gitlab.com/woofi4/public/pandoc-presentation-creator
- Maintainer: koflerphillip@outlook.com

### Hinzugefügt

- GitLab CI/CD Pipeline (.gitlab-ci.yml)
- Parallele Docker Image Builds (base, revealjs, beamer)
- Automatische GitLab Releases
- Multi-Platform Support (amd64, arm64)
- setup-gitlab.sh für GitLab-first Setup
- Docker Compose Konfiguration für GitLab Container Registry
- Automatisches Tagging und Veröffentlichung

### Entfernt

- GitHub Actions Workflows
- GitHub-spezifische Konflab.com/woofi4/public/pandoc-presentation-creator/-/compare/v2.0.0...main
[2.0.0]: https://gitlab.com/woofi4/public/pandoc-presentation-creator/-/releases/v2.0.0
[1.0.0]: https://gitlab.com/woofi4/public/pandoc-presentation-creator/-/releases
- Alle Emoji aus Dokumentation

## [1.0.0] - 2026-01-10

### Hinzugefügt

- Initiales Release des Pandoc Presentation Creator
- Unterstützung für Reveal.js, Beamer (PDF) und PowerPoint (PPTX)
- Modulare Projekt-Struktur mit Defaults, Templates, Metadata
- Setup-Skripte für Linux, macOS und Windows
- Build-Skripte für einfache Präsentationserstellung
- Beispiel-Präsentationen (umfassend und minimal)
- Lua-Filter für Custom Boxen und Spalten-Layouts
- Custom CSS für Reveal.js
- LaTeX-Pakete-Integration für Beamer
- Umfassende Dokumentation in README.md
- Makefile für schnelle Befehle
- .gitignore für sauberes Repository

### Dokumentation

- Vollständige README mit allen Features
- Inline-Kommentare in allen Konfigurationsdateien
- Beispiele für alle unterstützten Formate
- Troubleshooting-Sektion
- Best Practices Guide

[Unreleased]: https://gitlab.com/woofi4/public/pandoc-presentation-creator/-/compare/v2.0.0...main
[2.0.0]: https://gitlab.com/woofi4/public/pandoc-presentation-creator/-/releases/v2.0.0
[1.0.0]: https://gitlab.com/woofi4/public/pandoc-presentation-creator/-/releases/v1.0.0
