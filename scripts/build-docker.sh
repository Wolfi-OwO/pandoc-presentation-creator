#!/usr/bin/env bash
# ==============================================================================
# Docker-basiertes Build-Script
# ==============================================================================
# Verwendet Docker Images statt lokaler Pandoc-Installation
# Verwendung: ./scripts/build-docker.sh <format> <input-datei> [optionen]

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# GitLab Container Registry Konfiguration
GITLAB_REGISTRY="${GITLAB_REGISTRY:-registry.gitlab.com}"
GITLAB_PROJECT="${GITLAB_PROJECT:-woofi4/public/pandoc-presentation-creator}"
IMAGE_PREFIX="${GITLAB_REGISTRY}/${GITLAB_PROJECT}"

# ------------------------------------------------------------------------------
# Funktionen
# ------------------------------------------------------------------------------

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_usage() {
    cat << EOF
Verwendung: $0 <format> <input-datei> [optionen]

Formate:
  base        - Minimales Pandoc (Standard-Konvertierungen)
  revealjs    - Reveal.js HTML-Präsentationen
  beamer      - Beamer PDF-Präsentationen

Beispiele:
  $0 revealjs examples/example-presentation.md
  $0 beamer examples/example-presentation.md
  $0 base input.md -o output.html

Optionen:
  -o, --output    Ausgabedatei
  -h, --help      Diese Hilfe anzeigen
  
Docker:
  Dieses Script verwendet Docker Images. Keine lokale Pandoc-Installation nötig!
  Images werden automatisch von Docker Hub gepullt oder lokal gebaut.
EOF
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker ist nicht installiert!"
        echo "Installation: https://docs.docker.com/get-docker/"
        echo "Oder führen Sie ./setup-docker.sh aus"
        exit 1
    fi
    
    if ! docker ps &> /dev/null; then
        print_error "Docker-Daemon läuft nicht!"
        echo "Bitte starten Sie Docker und versuchen Sie es erneut."
        exit 1
    fi
}

pull_or_build_image() {
    local format=$1
    local full_image="${IMAGE_PREFIX}-${format}:latest"
    
    # Prüfe ob Image lokal existiert
    if docker image inspect "$full_image" &> /dev/null; then
        print_info "Verwende vorhandenes Image: $full_image"
        return 0
    fi
    
    print_info "Image nicht gefunden, versuche zu pullen..."
    
    # Versuche von Docker Hub zu pullen
    if docker pull "$full_image" 2>/dev/null; then
        print_success "Image erfolgreich gepullt: $full_image"
        return 0
    fi
    
    # Wenn Pull fehlschlägt, versuche lokal zu bauen
    print_warning "Pull fehlgeschlagen, baue Image lokal..."
    
    if [ ! -f "docker/Dockerfile.${format}" ]; then
        print_error "Dockerfile nicht gefunden: docker/Dockerfile.${format}"
        exit 1
    fi
    
    print_info "Baue Docker Image: $full_image"
    if docker build -f "docker/Dockerfile.${format}" -t "$full_image" . ; then
        print_success "Image erfolgreich gebaut: $full_image"
    else
        print_error "Build fehlgeschlagen"
        exit 1
    fi
}

run_pandoc_docker() {
    local format=$1
    local input=$2
    local output=$3
    shift 3
    local extra_args="$@"
    
    local full_image="${IMAGE_PREFIX}-${format}:latest"
    local defaults_file="/pandoc/defaults/${format}.yaml"
    
    # Erstelle Output-Verzeichnis
    mkdir -p output
    
    # Bestimme User ID für korrekten Datei-Besitzer
    local user_id=$(id -u):$(id -g)
    
    print_info "Starte Docker Container..."
    print_info "Image: $full_image"
    print_info "Input: $input"
    print_info "Output: $output"
    
    # Spezielle Behandlung je nach Format
    if [ "$format" = "base" ]; then
        # Base Image ohne Defaults
        docker run --rm \
            -v "$(pwd):/data" \
            -u "$user_id" \
            "$full_image" \
            "$input" -o "$output" $extra_args
    else
        # Spezialisierte Images mit Defaults
        docker run --rm \
            -v "$(pwd):/data" \
            -u "$user_id" \
            "$full_image" \
            -d "$defaults_file" "$input" -o "$output" $extra_args
    fi
    
    if [ $? -eq 0 ] && [ -f "$output" ]; then
        print_success "Präsentation erfolgreich erstellt: $output"
        
        # Dateigröße anzeigen
        local size=$(du -h "$output" | cut -f1)
        print_info "Dateigröße: $size"
        
        return 0
    else
        print_error "Fehler beim Erstellen der Präsentation"
        return 1
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
EXTRA_ARGS=""

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
            EXTRA_ARGS="$EXTRA_ARGS $1"
            shift
            ;;
    esac
done

# Format validieren
case $FORMAT in
    base|revealjs|beamer)
        ;;
    *)
        print_error "Unbekanntes Format: $FORMAT"
        echo "Verfügbare Formate: base, revealjs, beamer"
        show_usage
        exit 1
        ;;
esac

# Input-Datei prüfen
if [ ! -f "$INPUT" ]; then
    print_error "Datei nicht gefunden: $INPUT"
    exit 1
fi

# Output-Datei bestimmen
if [ -z "$OUTPUT" ]; then
    case $FORMAT in
        revealjs)
            OUTPUT="output/presentation.html"
            ;;
        beamer)
            OUTPUT="output/presentation.pdf"
            ;;
        base)
            OUTPUT="output/presentation.html"
            ;;
    esac
fi

# Docker prüfen
check_docker

# Image verfügbar machen
pull_or_build_image "$FORMAT"

# Pandoc mit Docker ausführen
run_pandoc_docker "$FORMAT" "$INPUT" "$OUTPUT" $EXTRA_ARGS

# Erfolgreich
print_success "Fertig! 🎉"
