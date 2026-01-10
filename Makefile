# Makefile für Pandoc Presentation Creator
# ==============================================================================
# Verwendung: make <target>
# Beispiel:   make revealjs

.PHONY: help all revealjs beamer pptx clean install test

# Standard-Verzeichnisse
SCRIPTS_DIR := scripts
EXAMPLES_DIR := examples
OUTPUT_DIR := output
DEFAULTS_DIR := defaults

# Standard-Eingabedatei
INPUT ?= $(EXAMPLES_DIR)/example-presentation.md

# ------------------------------------------------------------------------------
# Hilfe
# ------------------------------------------------------------------------------
help:
	@echo "Verfügbare Make-Targets:"
	@echo ""
	@echo "  make help       - Diese Hilfe anzeigen"
	@echo "  make all        - Alle Formate erstellen"
	@echo "  make revealjs   - Reveal.js HTML-Präsentation erstellen"
	@echo "  make beamer     - Beamer PDF-Präsentation erstellen"
	@echo "  make pptx       - PowerPoint-Präsentation erstellen"
	@echo "  make clean      - Output-Verzeichnis leeren"
	@echo "  make install    - Abhängigkeiten prüfen"
	@echo "  make test       - Alle Beispiele testen"
	@echo ""
	@echo "Variablen:"
	@echo "  INPUT=$(INPUT)"
	@echo ""
	@echo "Beispiele:"
	@echo "  make revealjs"
	@echo "  make revealjs INPUT=meine-praesentation.md"
	@echo "  make all INPUT=examples/minimal.md"

# ------------------------------------------------------------------------------
# Alle Formate erstellen
# ------------------------------------------------------------------------------
all: revealjs beamer pptx
	@echo "✓ Alle Formate erfolgreich erstellt"

# ------------------------------------------------------------------------------
# Einzelne Formate
# ------------------------------------------------------------------------------
revealjs:
	@echo "→ Erstelle Reveal.js Präsentation..."
	@$(SCRIPTS_DIR)/build.sh revealjs $(INPUT)
	@echo "✓ Reveal.js Präsentation erstellt: $(OUTPUT_DIR)/presentation.html"

beamer:
	@echo "→ Erstelle Beamer PDF..."
	@$(SCRIPTS_DIR)/build.sh beamer $(INPUT)
	@echo "✓ Beamer PDF erstellt: $(OUTPUT_DIR)/presentation.pdf"

pptx:
	@echo "→ Erstelle PowerPoint Präsentation..."
	@$(SCRIPTS_DIR)/build.sh pptx $(INPUT)
	@echo "✓ PowerPoint erstellt: $(OUTPUT_DIR)/presentation.pptx"

# ------------------------------------------------------------------------------
# Aufräumen
# ------------------------------------------------------------------------------
clean:
	@echo "→ Leere Output-Verzeichnis..."
	@rm -rf $(OUTPUT_DIR)/*
	@touch $(OUTPUT_DIR)/.gitkeep
	@echo "✓ Output-Verzeichnis geleert"

# ------------------------------------------------------------------------------
# Installation prüfen
# ------------------------------------------------------------------------------
install:
	@echo "→ Prüfe Abhängigkeiten..."
	@command -v pandoc >/dev/null 2>&1 || { echo "✗ Pandoc ist nicht installiert"; exit 1; }
	@echo "✓ Pandoc ist installiert: $$(pandoc --version | head -n 1)"
	@command -v git >/dev/null 2>&1 || { echo "✗ Git ist nicht installiert"; exit 1; }
	@echo "✓ Git ist installiert: $$(git --version)"
	@command -v xelatex >/dev/null 2>&1 && echo "✓ XeLaTeX ist installiert" || echo "⚠ XeLaTeX ist nicht installiert (optional für Beamer)"
	@command -v node >/dev/null 2>&1 && echo "✓ Node.js ist installiert: $$(node --version)" || echo "⚠ Node.js ist nicht installiert (optional)"
	@echo ""
	@echo "✓ Alle kritischen Abhängigkeiten sind vorhanden"

# ------------------------------------------------------------------------------
# Tests
# ------------------------------------------------------------------------------
test:
	@echo "→ Teste alle Beispiel-Präsentationen..."
	@echo ""
	@echo "Test 1: Minimal-Beispiel (Reveal.js)"
	@$(SCRIPTS_DIR)/build.sh revealjs $(EXAMPLES_DIR)/minimal.md -o $(OUTPUT_DIR)/test-minimal.html
	@echo ""
	@echo "Test 2: Umfassendes Beispiel (Reveal.js)"
	@$(SCRIPTS_DIR)/build.sh revealjs $(EXAMPLES_DIR)/example-presentation.md -o $(OUTPUT_DIR)/test-example.html
	@echo ""
	@echo "Test 3: Beamer-Test"
	@$(SCRIPTS_DIR)/build.sh beamer $(EXAMPLES_DIR)/minimal.md -o $(OUTPUT_DIR)/test-minimal.pdf || echo "⚠ Beamer-Test fehlgeschlagen (LaTeX möglicherweise nicht installiert)"
	@echo ""
	@echo "✓ Tests abgeschlossen"

# ------------------------------------------------------------------------------
# Entwickler-Targets
# ------------------------------------------------------------------------------
dev-revealjs: revealjs
	@echo "→ Öffne Präsentation im Browser..."
	@command -v xdg-open >/dev/null 2>&1 && xdg-open $(OUTPUT_DIR)/presentation.html || open $(OUTPUT_DIR)/presentation.html

dev-beamer: beamer
	@echo "→ Öffne PDF..."
	@command -v xdg-open >/dev/null 2>&1 && xdg-open $(OUTPUT_DIR)/presentation.pdf || open $(OUTPUT_DIR)/presentation.pdf

dev-pptx: pptx
	@echo "→ Öffne PowerPoint..."
	@command -v xdg-open >/dev/null 2>&1 && xdg-open $(OUTPUT_DIR)/presentation.pptx || open $(OUTPUT_DIR)/presentation.pptx

# ------------------------------------------------------------------------------
# Watch-Mode (benötigt entr oder inotifywait)
# ------------------------------------------------------------------------------
watch:
	@echo "→ Starte Watch-Mode für $(INPUT)..."
	@echo "  (Änderungen werden automatisch neu gebaut)"
	@echo "  Drücke Ctrl+C zum Beenden"
	@command -v entr >/dev/null 2>&1 || { echo "✗ 'entr' ist nicht installiert"; exit 1; }
	@echo $(INPUT) | entr make revealjs INPUT=$(INPUT)
