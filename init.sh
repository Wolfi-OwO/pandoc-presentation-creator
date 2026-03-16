#!/bin/bash
set -e

# Pandoc Presentation Creator - Initialization Script
# Sets up a presentation project and asks for a few simple defaults.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/templates"
IMAGE_REGISTRY="registry.gitlab.com/woofi4/public/pandoc-presentation-creator/beamer-full"
DOCKER_IMAGE="${IMAGE_REGISTRY}:latest"
VERSION="unknown"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

is_interactive() {
    [ -t 0 ] && [ -t 1 ]
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

prompt_with_default() {
    local prompt="$1"
    local default_value="$2"
    local __resultvar="$3"
    local input=""

    if is_interactive; then
        read -r -p "${prompt} [${default_value}]: " input
        input="${input:-${default_value}}"
    else
        input="${default_value}"
    fi

    printf -v "${__resultvar}" '%s' "${input}"
}

require_template() {
    local file_name="$1"
    if [ ! -f "${TEMPLATE_DIR}/${file_name}" ]; then
        print_error "Missing template: templates/${file_name}"
        exit 1
    fi
}

pull_with_spinner() {
    local image="$1"
    local pid
    local spin='|/-\\'
    local i=0

    docker pull "$image" >/dev/null 2>&1 &
    pid=$!

    printf "Pulling Docker image "
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % 4 ))
        printf "\rPulling Docker image %s" "${spin:$i:1}"
        sleep 0.1
    done

    if wait "$pid"; then
        printf "\rPulling Docker image done\n"
        return 0
    fi

    printf "\rPulling Docker image failed\n"
    return 1
}

resolve_image_version() {
    if ! command_exists docker; then
        print_info "Docker not found. Using default image: ${DOCKER_IMAGE}"
        return
    fi

    if is_interactive; then
        local pull_answer
        prompt_with_default "Pull latest registry image now? (y/n)" "y" pull_answer
        if [ "${pull_answer}" = "y" ] || [ "${pull_answer}" = "Y" ]; then
            print_info "Pulling docker image: ${IMAGE_REGISTRY}:latest"
            pull_with_spinner "${IMAGE_REGISTRY}:latest" || print_info "Could not pull latest image; using local cache if available."
        else
            print_info "Skipping docker pull."
        fi
    else
        print_info "Pulling docker image: ${IMAGE_REGISTRY}:latest"
        pull_with_spinner "${IMAGE_REGISTRY}:latest" || print_info "Could not pull latest image; using local cache if available."
    fi

    local image_version
    image_version="$(docker inspect --format='{{index .Config.Labels "org.opencontainers.image.version"}}' "${IMAGE_REGISTRY}:latest" 2>/dev/null || echo unknown)"

    if [ -n "${image_version}" ] && [ "${image_version}" != "unknown" ]; then
        VERSION="${image_version}"
        DOCKER_IMAGE="${IMAGE_REGISTRY}:${VERSION}"
        print_success "Resolved image version: ${VERSION}"
    else
        DOCKER_IMAGE="${IMAGE_REGISTRY}:latest"
        print_info "Could not resolve version label, using: ${DOCKER_IMAGE}"
    fi
}

prompt_project_configuration() {
    print_header "Presentation Configuration"

    prompt_with_default "Presentation title" "My Presentation" TITLE
    prompt_with_default "Author" "Author Name" AUTHOR
    prompt_with_default "Theme label shown in example slide" "Madrid" THEME
    prompt_with_default "Main slide file name" "Example.md" SLIDE_FILE
    prompt_with_default "Output PDF file name" "presentation.pdf" OUTPUT_FILE
}

create_project_files() {
    local date_value
    date_value="$(date +%d.%m.%Y)"

    print_info "Creating directory structure..."
    mkdir -p output config slides
    print_success "Directories created"

    print_info "Creating configuration files..."
    cp "${TEMPLATE_DIR}/config.yaml.template" config/config.yaml
    sed -i.bak "s/FORMAT_PLACEHOLDER/beamer/g" config/config.yaml
    sed -i.bak "s/TITLE_PLACEHOLDER/${TITLE}/g" config/config.yaml
    sed -i.bak "s/AUTHOR_PLACEHOLDER/${AUTHOR}/g" config/config.yaml
    sed -i.bak "s/DATE_PLACEHOLDER/${date_value}/g" config/config.yaml
    rm -f config/config.yaml.bak

    cp "${TEMPLATE_DIR}/build.env.template" config/build.env
    sed -i.bak "s/FORMAT_PLACEHOLDER/beamer/g" config/build.env
    sed -i.bak "s/IMAGE_TYPE_PLACEHOLDER/beamer-full/g" config/build.env
    sed -i.bak "s/OUTPUT_EXT_PLACEHOLDER/pdf/g" config/build.env
    rm -f config/build.env.bak
    print_success "Created config/config.yaml and config/build.env"

    print_info "Creating slide templates..."
    cp "${TEMPLATE_DIR}/Example.md.template" "slides/${SLIDE_FILE}"
    sed -i.bak "s/TITLE_PLACEHOLDER/${TITLE}/g" "slides/${SLIDE_FILE}"
    sed -i.bak "s/AUTHOR_PLACEHOLDER/${AUTHOR}/g" "slides/${SLIDE_FILE}"
    sed -i.bak "s/THEME_PLACEHOLDER/${THEME}/g" "slides/${SLIDE_FILE}"
    rm -f "slides/${SLIDE_FILE}.bak"

    if [ -f "${TEMPLATE_DIR}/Themed-Feature.md.template" ]; then
        cp "${TEMPLATE_DIR}/Themed-Feature.md.template" "slides/Themed-Feature.md"
    fi
    print_success "Created slides/${SLIDE_FILE}"

    print_info "Creating build helper and docs..."
    cp "${TEMPLATE_DIR}/buildPDF.template" buildPDF
    sed -i.bak "s#/data/slides/Minimalist.md#/data/slides/${SLIDE_FILE}#g" buildPDF
    sed -i.bak "s#/data/output/presentation.pdf#/data/output/${OUTPUT_FILE}#g" buildPDF
    rm -f buildPDF.bak
    chmod +x buildPDF

    cp "${TEMPLATE_DIR}/HELP.md.template" HELP.md
    sed -i.bak "s#pandoc-beamer:local#${DOCKER_IMAGE}#g" HELP.md
    sed -i.bak "s#registry.gitlab.com/woofi4/public/pandoc-presentation-creator/beamer-full:latest#${DOCKER_IMAGE}#g" HELP.md
    rm -f HELP.md.bak
    if [ -f "${TEMPLATE_DIR}/gitignore.template" ]; then
        cp "${TEMPLATE_DIR}/gitignore.template" .gitignore
    fi
    print_success "Created buildPDF, HELP.md and .gitignore"
}

print_header "Pandoc Presentation Creator"

require_template "config.yaml.template"
require_template "build.env.template"
require_template "Example.md.template"
require_template "HELP.md.template"
require_template "buildPDF.template"

resolve_image_version
prompt_project_configuration
create_project_files

echo ""
print_header "Setup Complete"
echo "Project files created in: $(pwd)"
echo "Selected image: ${DOCKER_IMAGE}"
echo ""
echo "Next steps:"
echo "1. Edit slides/${SLIDE_FILE}"
echo "2. Adjust config/config.yaml"
echo "3. Build with:"
echo "   docker run --rm -v \"\$(pwd):/data\" --entrypoint=/bin/sh ${DOCKER_IMAGE} -c \"/data/buildPDF\""
echo ""
