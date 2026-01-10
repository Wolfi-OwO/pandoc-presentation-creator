#!/usr/bin/env bash
# ==============================================================================
# Docker-First Setup-Script für Pandoc Presentation Creator
# ==============================================================================
# Dieses Script prüft Docker, pullt Images und richtet das Projekt ein.
# KEINE lokale Pandoc-Installation erforderlich!
#
# Verwendung: curl -sSL <url-to-script> | bash
# oder:       ./setup-docker.sh

set -e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# GitLab Container Registry Konfiguration
GITLAB_REGISTRY="registry.gitlab.com"
GITLAB_PROJECT="woofi4/public/pandoc-presentation-creator"
IMAGE_PREFIX="${GITLAB_REGISTRY}/${GITLAB_PROJECT}"

# Projekt-Konfiguration
REPO_URL="https://gitlab.com/woofi4/public/pandoc-presentation-creator.git"
PROJECT_NAME="pandoc-presentation-creator"
INSTALL_DIR="$HOME/$PROJECT_NAME"

# ------------------------------------------------------------------------------
# Funktionen
# ------------------------------------------------------------------------------

print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
================================================================
                                                               
    Pandoc Presentation Creator - Docker Setup                
    Docker-First | Keine lokale Installation nötig           
                                                               
================================================================
EOF
    echo -e "${NC}"
}

print_info() { echo -e "${BLUE}[INFO]${NC}  $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC}  $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC}  $1"; }
print_error() { echo -e "${RED}[ERROR]${NC}  $1"; }
print_step() { echo -e "\n${BOLD}${CYAN}>> $1${NC}"; }

ask_question() {
    local question=$1
    local default=$2
    local answer
    
    if [ -n "$default" ]; then
        echo -n "${YELLOW}?${NC}  $question ${CYAN}[$default]${NC}: "
    else
        echo -n "${YELLOW}?${NC}  $question: "
    fi
    
    read answer
    answer="${answer:-$default}"
    printf "%s" "$answer"
}

ask_yes_no() {
    local question=$1
    local default=$2
    
    while true; do
        if [ "$default" = "y" ]; then
            echo -e -n "${YELLOW}?${NC}  $question ${CYAN}[Y/n]${NC}: "
        else
            echo -e -n "${YELLOW}?${NC}  $question ${CYAN}[y/N]${NC}: "
        fi
        
        read answer
        answer="${answer:-$default}"
        
        case "$answer" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo -e "Bitte mit y oder n antworten.";;
        esac
    done
}

# ------------------------------------------------------------------------------
# Docker prüfen und installieren
# ------------------------------------------------------------------------------
check_and_install_docker() {
    print_step "Docker Installation prüfen"
    
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version)
        print_success "Docker ist installiert: $docker_version"
        
        # Docker-Daemon prüfen
        if ! docker ps &> /dev/null; then
            print_warning "Docker-Daemon läuft nicht!"
            
            if ask_yes_no "Möchten Sie Docker starten?" "y"; then
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    open -a Docker
                    print_info "Warte auf Docker Desktop..."
                    sleep 5
                elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                    sudo systemctl start docker
                fi
                
                # Warten bis Docker bereit ist
                local attempts=0
                while ! docker ps &> /dev/null && [ $attempts -lt 30 ]; do
                    echo -n "."
                    sleep 1
                    ((attempts++))
                done
                echo -e ""
                
                if docker ps &> /dev/null; then
                    print_success "Docker ist jetzt aktiv"
                else
                    print_error "Docker konnte nicht gestartet werden"
                    exit 1
                fi
            else
                print_error "Docker muss laufen, um fortzufahren"
                exit 1
            fi
        fi
        return 0
    fi
    
    # Docker ist nicht installiert
    print_warning "Docker ist nicht installiert!"
    echo -e ""
    print_info "Docker ist die EINZIGE Abhängigkeit für dieses Projekt."
    print_info "Keine lokale Pandoc-Installation erforderlich!"
    echo -e ""
    
    if ! ask_yes_no "Möchten Sie Docker jetzt installieren?" "y"; then
        print_info "Bitte installieren Sie Docker manuell:"
        echo -e "  - Linux: https://docs.docker.com/engine/install/"
        echo -e "  - macOS: https://docs.docker.com/desktop/install/mac-install/"
        echo -e "  - Windows: https://docs.docker.com/desktop/install/windows-install/"
        exit 1
    fi
    
    # Automatische Docker-Installation
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        print_info "Installiere Docker auf Linux..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        print_success "Docker installiert!"
        print_warning "Bitte melden Sie sich ab und wieder an, damit Gruppen-Änderungen wirksam werden."
        print_info "Danach führen Sie dieses Script erneut aus."
        exit 0
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        print_info "Für macOS installieren Sie bitte Docker Desktop manuell:"
        echo -e "  https://docs.docker.com/desktop/install/mac-install/"
        exit 1
    else
        print_error "Automatische Installation auf diesem OS nicht unterstützt"
        print_info "Bitte installieren Sie Docker manuell:"
        echo -e "  https://docs.docker.com/get-docker/"
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Docker Images auswählen und pullen
# ------------------------------------------------------------------------------
select_and_pull_images() {
    print_step "Docker Images auswählen"
    
    echo -e ""
    echo -e "Welche Docker Images möchten Sie verwenden?"
    echo -e "  ${CYAN}1)${NC} Base (minimal, ~40 MB) - Für einfache Konvertierungen"
    echo -e "  ${CYAN}2)${NC} Reveal.js (~80 MB) - Für HTML-Präsentationen"
    echo -e "  ${CYAN}3)${NC} Beamer (~250 MB) - Für PDF-Präsentationen"
    echo -e "  ${CYAN}4)${NC} Alle Images"
    
    local choice=$(ask_question "Wähle eine Option [1-4]" "4")
    
    local images_to_pull=()
    
    case $choice in
        1) images_to_pull=("pandoc-base") ;;
        2) images_to_pull=("pandoc-revealjs") ;;
        3) images_to_pull=("pandoc-beamer") ;;
        4) images_to_pull=("pandoc-base" "pandoc-revealjs" "pandoc-beamer") ;;
        *) images_to_pull=("pandoc-base") ;;
    esac
    
    echo -e ""
    print_step "Docker Images herunterladen"
    
    for image in "${images_to_pull[@]}"; do
        local full_image="${IMAGE_PREFIX}/${image}:latest"
        print_info "Pulling $full_image..."
        
        if docker pull "$full_image" 2>/dev/null; then
            print_success "${full_image} heruntergeladen"
        else
            print_warning "Konnte ${full_image} nicht laden (möglicherweise noch nicht veröffentlicht)"
            print_info "Baue Image lokal..."
            
            if [ -f "docker/Dockerfile.${image/pandoc-/}" ]; then
                docker build -f "docker/Dockerfile.${image/pandoc-/}" -t "$full_image" .
                print_success "${full_image} lokal gebaut"
            else
                print_error "Dockerfile für ${image} nicht gefunden"
            fi
        fi
    done
    
    # Default-Image festlegen
    DEFAULT_IMAGE="${images_to_pull[0]}"
}

# ------------------------------------------------------------------------------
# Repository Setup
# ------------------------------------------------------------------------------
setup_repository() {
    print_step "Repository Setup"
    
    if [ -d ".git" ] && [ -f "setup-docker.sh" ]; then
        print_info "Setup wird im vorhandenen Repository ausgeführt"
        INSTALL_DIR="$(pwd)"
        return 0
    fi
    
    INSTALL_DIR=$(ask_question "Wo soll das Projekt installiert werden?" "$INSTALL_DIR")
    
    if [ -d "$INSTALL_DIR" ]; then
        if ask_yes_no "Verzeichnis existiert bereits. Überschreiben?" "n"; then
            rm -rf "$INSTALL_DIR"
        else
            print_error "Setup abgebrochen"
            exit 1
        fi
    fi
    
    print_info "Klone Repository..."
    if git clone "$REPO_URL" "$INSTALL_DIR" 2>/dev/null; then
        print_success "Repository erfolgreich geklont"
    else
        print_warning "Konnte Repository nicht klonen"
        mkdir -p "$INSTALL_DIR"
    fi
    
    cd "$INSTALL_DIR"
}

# ------------------------------------------------------------------------------
# Wrapper-Skripte erstellen
# ------------------------------------------------------------------------------
create_wrapper_scripts() {
    print_step "Docker-Wrapper-Skripte erstellen"
    
    # Generiere pandoc-docker Wrapper
    cat > "$INSTALL_DIR/pandoc-docker" << EOF
#!/usr/bin/env bash
# Docker-Wrapper für Pandoc
# Verwendung: ./pandoc-docker [image] [pandoc-args...]

IMAGE="\${1:-pandoc-base}"
shift

FULL_IMAGE="${IMAGE_PREFIX}/\${IMAGE}:latest"

docker run --rm \\
    -v "\$(pwd):/data" \\
    -u \$(id -u):\$(id -g) \\
    "\$FULL_IMAGE" \\
    "\$@"
EOF
    
    chmod +x "$INSTALL_DIR/pandoc-docker"
    print_success "Wrapper-Script erstellt: pandoc-docker"
    
    echo -e ""
    echo -e "Optional: Fügen Sie diese Aliase zu Ihrer ~/.bashrc oder ~/.zshrc hinzu:"
    echo -e ""
    echo -e "  alias pandoc-base='docker run --rm -v \$(pwd):/data ${IMAGE_PREFIX}/pandoc-base:latest'"
    echo -e "  alias pandoc-revealjs='docker run --rm -v \$(pwd):/data ${IMAGE_PREFIX}/pandoc-revealjs:latest'"
    echo -e "  alias pandoc-beamer='docker run --rm -v \$(pwd):/data ${IMAGE_PREFIX}/pandoc-beamer:latest'"
}

# ------------------------------------------------------------------------------
# Beispiel erstellen
# ------------------------------------------------------------------------------
create_example() {
    if ask_yes_no "Möchten Sie eine Test-Präsentation erstellen?" "y"; then
        print_step "Erstelle Test-Präsentation"
        
        local image="${DEFAULT_IMAGE}"
        local full_image="${IMAGE_PREFIX}/${image}:latest"
        
        print_info "Verwende Image: $full_image"
        
        if [[ "$image" == *"revealjs"* ]]; then
            docker run --rm -v "$(pwd):/data" -u $(id -u):$(id -g) "$full_image" \
                -d /pandoc/defaults/revealjs.yaml examples/minimal.md -o output/test.html
            
            if [ -f "output/test.html" ]; then
                print_success "Test-Präsentation erstellt: output/test.html"
                
                if ask_yes_no "Möchten Sie die Präsentation öffnen?" "n"; then
                    if command -v xdg-open &> /dev/null; then
                        xdg-open output/test.html
                    elif command -v open &> /dev/null; then
                        open output/test.html
                    fi
                fi
            fi
        elif [[ "$image" == *"beamer"* ]]; then
            docker run --rm -v "$(pwd):/data" -u $(id -u):$(id -g) "$full_image" \
                -d /pandoc/defaults/beamer.yaml examples/minimal.md -o output/test.pdf
            
            if [ -f "output/test.pdf" ]; then
                print_success "Test-Präsentation erstellt: output/test.pdf"
            fi
        else
            docker run --rm -v "$(pwd):/data" -u $(id -u):$(id -g) "$full_image" \
                examples/minimal.md -o output/test.html
            
            if [ -f "output/test.html" ]; then
                print_success "Test-Präsentation erstellt: output/test.html"
            fi
        fi
    fi
}

# ------------------------------------------------------------------------------
# Finale Instruktionen
# ------------------------------------------------------------------------------
print_final_instructions() {
    echo -e ""
    echo -e "================================================================"
    echo -e "           Setup erfolgreich abgeschlossen!                      "
    echo -e "================================================================"
    echo -e ""
    
    print_info "Verwendungsbeispiele:"
    echo ""
    echo "  # Reveal.js Präsentation"
    echo "  docker run --rm -v \$(pwd):/data ${IMAGE_PREFIX}/pandoc-revealjs:latest \\"
    echo "    -d /pandoc/defaults/revealjs.yaml slides.md -o output.html"
    echo ""
    echo "  # Beamer PDF"
    echo "  docker run --rm -v \$(pwd):/data ${IMAGE_PREFIX}/pandoc-beamer:latest \\"
    echo "    -d /pandoc/defaults/beamer.yaml slides.md -o output.pdf"
    echo ""
    echo "  # Oder mit Wrapper-Skript:"
    echo "  ./pandoc-docker pandoc-revealjs -d /pandoc/defaults/revealjs.yaml slides.md -o output.html"
    echo ""
    
    print_success "Viel Erfolg mit Ihren Docker-basierten Präsentationen!"
}

# ------------------------------------------------------------------------------
# Hauptprogramm
# ------------------------------------------------------------------------------
main() {
    print_banner
    check_and_install_docker
    setup_repository
    select_and_pull_images
    create_wrapper_scripts
    create_example
    print_final_instructions
}

main
