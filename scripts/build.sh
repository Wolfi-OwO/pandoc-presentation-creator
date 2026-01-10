#!/usr/bin/env bash
# ==============================================================================
# build.sh - Hilfs-Script zum Erstellen von Präsentationen
# ==============================================================================
# Verwendung: ./scripts/build.sh <format> <input-datei>
# Beispiel:   ./scripts/build.sh revealjs examples/example-presentation.md

set -e  # Bei Fehler abbrechen

# Farben für Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# Funktionen
# ------------------------------------------------------------------------------

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_usage() {
    cat << EOF
Verwendung: $0 <format> <input-datei> [optionen]

Formate:
  revealjs    - Erstellt eine Reveal.js HTML-Präsentation
  beamer      - Erstellt eine Beamer PDF-Präsentation
  pptx        - Erstellt eine PowerPoint-Präsentation

Beispiele:
  $0 revealjs examples/example-presentation.md
  $0 beamer examples/example-presentation.md
  $0 pptx examples/example-presentation.md

Optionen:
  -o, --output    Ausgabedatei (Standard: output/presentation.<format>)
  -h, --help      Diese Hilfe anzeigen
EOF
}

check_dependencies() {
    print_info "Überprüfe Abhängigkeiten..."
    
    if ! command -v pandoc &> /dev/null; then
        print_error "Pandoc ist nicht installiert!"
        echo "Installation: https://pandoc.org/installing.html"
        exit 1
    fi
    
    PANDOC_VERSION=$(pandoc --version | head -n 1)
    print_success "Gefunden: $PANDOC_VERSION"
    
    # Zusätzliche Checks für Beamer
    if [ "$FORMAT" = "beamer" ]; then
        if ! command -v xelatex &> /dev/null && ! command -v pdflatex &> /dev/null; then
            print_warning "Kein LaTeX-Engine gefunden (xelatex oder pdflatex)"
            print_warning "Für Beamer-Präsentationen wird LaTeX benötigt!"
        fi
    fi
}

# ------------------------------------------------------------------------------
# Hauptprogramm
# ------------------------------------------------------------------------------

# Parameter prüfen
if [ $# -lt 2 ]; then
    show_usage
    exit 1
fi

FORMAT=$1
INPUT=$2
OUTPUT=""

# Optionen parsen
shift 2
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unbekannte Option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Format validieren
case $FORMAT in
    revealjs|beamer|pptx)
        ;;
    *)
        print_error "Unbekanntes Format: $FORMAT"
        show_usage
        exit 1
        ;;
esac

# Input-Datei prüfen
if [ ! -f "$INPUT" ]; then
    print_error "Datei nicht gefunden: $INPUT"
    exit 1
fi

# Abhängigkeiten prüfen
check_dependencies

# Output-Verzeichnis erstellen
mkdir -p output

# Defaults-Datei prüfen
DEFAULTS_FILE="defaults/${FORMAT}.yaml"
if [ ! -f "$DEFAULTS_FILE" ]; then
    print_error "Defaults-Datei nicht gefunden: $DEFAULTS_FILE"
    exit 1
fi

# Pandoc ausführen
print_info "Erstelle Präsentation im Format: $FORMAT"
print_info "Input: $INPUT"

if [ -n "$OUTPUT" ]; then
    print_info "Output: $OUTPUT"
    pandoc -d "$DEFAULTS_FILE" "$INPUT" -o "$OUTPUT"
    OUTPUT_FILE="$OUTPUT"
else
    pandoc -d "$DEFAULTS_FILE" "$INPUT"
    case $FORMAT in
        revealjs)
            OUTPUT_FILE="output/presentation.html"
            ;;
        beamer)
            OUTPUT_FILE="output/presentation.pdf"
            ;;
        pptx)
            OUTPUT_FILE="output/presentation.pptx"
            ;;
    esac
fi

if [ -f "$OUTPUT_FILE" ]; then
    print_success "Präsentation erfolgreich erstellt: $OUTPUT_FILE"
    
    # Dateigröße anzeigen
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    print_info "Dateigröße: $FILE_SIZE"
else
    print_error "Fehler beim Erstellen der Präsentation"
    exit 1
fi
