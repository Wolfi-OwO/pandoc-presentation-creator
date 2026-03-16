#!/bin/bash
set -e

# Pandoc Presentation Creator - Initialization Script
# Sets up a presentation project and asks for a few simple defaults.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_REGISTRY="registry.gitlab.com/woofi4/public/pandoc-presentation-creator/beamer-full"
DOCKER_IMAGE="${IMAGE_REGISTRY}:latest"
VERSION="unknown"
IMAGE_TAG=""

# Repository URL for templates (updated to pinned version after image detection)
REPO_RAW_URL="https://gitlab.com/woofi4/public/pandoc-presentation-creator/-/raw/main/templates"

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

pull_with_spinner() {
    local image="$1"
    local pid
    local spin='|/-\'
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

# Download a template file: first tries the local templates/ directory (repo checkout),
# then falls back to downloading from the versioned registry URL.
download_or_copy_template() {
    local template_name="$1"
    local destination="$2"

    if [ -f "${SCRIPT_DIR}/templates/${template_name}" ]; then
        cp "${SCRIPT_DIR}/templates/${template_name}" "${destination}"
        return 0
    fi

    if command_exists wget; then
        wget -q -O "${destination}" "${REPO_RAW_URL}/${template_name}" 2>/dev/null && return 0
    fi

    if command_exists curl; then
        curl -sSL -o "${destination}" "${REPO_RAW_URL}/${template_name}" 2>/dev/null && return 0
    fi

    return 1
}

check_docker_image() {
    print_header "Checking Docker Image"

    if ! command_exists docker; then
        print_error "Docker is not installed"
        exit 1
    fi

    # Try to pull the latest image
    print_info "Pulling latest Docker image..."
    if pull_with_spinner "${IMAGE_REGISTRY}:latest"; then
        print_success "Docker image pulled successfully"
    else
        print_error "Failed to pull Docker image"
        print_info "Checking for local image..."
        if ! docker image inspect "${IMAGE_REGISTRY}:latest" >/dev/null 2>&1; then
            print_error "No local image found either"
            exit 1
        fi
        print_info "Using local image"
    fi

    # Get version from Docker image label
    local IMAGE_VERSION
    IMAGE_VERSION=$(docker inspect --format='{{index .Config.Labels "org.opencontainers.image.version"}}' "${IMAGE_REGISTRY}:latest" 2>/dev/null || echo "unknown")

    if [ "${IMAGE_VERSION}" != "unknown" ] && [ -n "${IMAGE_VERSION}" ]; then
        VERSION="${IMAGE_VERSION}"
        print_info "Using image version: ${VERSION}"
    else
        print_info "Could not determine image version, using default: ${VERSION}"
    fi

    if [ -n "${VERSION}" ] && [ "${VERSION}" != "unknown" ]; then
        IMAGE_TAG="${VERSION#v}"
    else
        IMAGE_TAG=""
    fi

    # Pin REPO_RAW_URL to the resolved version so templates always match the image
    if [ -n "${VERSION}" ] && [ "${VERSION}" != "unknown" ]; then
        local repo_ref="${VERSION}"
        if [[ "${VERSION}" =~ ^[0-9a-fA-F]{7,40}$ ]]; then
            repo_ref="${VERSION}"
        elif [[ "${VERSION}" == v* ]]; then
            repo_ref="${VERSION}"
        else
            repo_ref="v${VERSION}"
        fi
        REPO_RAW_URL="https://gitlab.com/woofi4/public/pandoc-presentation-creator/-/raw/${repo_ref}/templates"
        print_info "Using templates from: ${REPO_RAW_URL}"
    fi

    # Set the full image name with version if available
    if [ -n "${IMAGE_TAG}" ]; then
        DOCKER_IMAGE="${IMAGE_REGISTRY}:${IMAGE_TAG}"
    else
        DOCKER_IMAGE="${IMAGE_REGISTRY}:latest"
    fi
    print_info "Selected image: ${DOCKER_IMAGE}"
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
    if download_or_copy_template "config.yaml.template" config/config.yaml; then
        sed -i.bak "s/FORMAT_PLACEHOLDER/beamer/g" config/config.yaml
        sed -i.bak "s/TITLE_PLACEHOLDER/${TITLE}/g" config/config.yaml
        sed -i.bak "s/AUTHOR_PLACEHOLDER/${AUTHOR}/g" config/config.yaml
        sed -i.bak "s/DATE_PLACEHOLDER/${date_value}/g" config/config.yaml
        rm -f config/config.yaml.bak
        print_success "Created config/config.yaml"
    else
        print_error "Failed to obtain config.yaml.template"
        exit 1
    fi

    if download_or_copy_template "build.env.template" config/build.env; then
        sed -i.bak "s/FORMAT_PLACEHOLDER/beamer/g" config/build.env
        sed -i.bak "s/IMAGE_TYPE_PLACEHOLDER/beamer-full/g" config/build.env
        sed -i.bak "s/OUTPUT_EXT_PLACEHOLDER/pdf/g" config/build.env
        rm -f config/build.env.bak
        print_success "Created config/build.env"
    else
        print_error "Failed to obtain build.env.template"
        exit 1
    fi

    print_info "Creating slide templates..."
    if download_or_copy_template "Example.md.template" "slides/${SLIDE_FILE}"; then
        sed -i.bak "s/TITLE_PLACEHOLDER/${TITLE}/g" "slides/${SLIDE_FILE}"
        sed -i.bak "s/AUTHOR_PLACEHOLDER/${AUTHOR}/g" "slides/${SLIDE_FILE}"
        sed -i.bak "s/THEME_PLACEHOLDER/${THEME}/g" "slides/${SLIDE_FILE}"
        rm -f "slides/${SLIDE_FILE}.bak"
        print_success "Created slides/${SLIDE_FILE}"
    else
        print_error "Failed to obtain Example.md.template"
        exit 1
    fi

    if download_or_copy_template "Themed-Feature.md.template" "slides/Themed-Feature.md"; then
        print_success "Created slides/Themed-Feature.md"
    fi

    print_info "Creating build helper and docs..."
    if download_or_copy_template "buildPDF.template" buildPDF; then
        sed -i.bak "s#/data/slides/Minimalist.md#/data/slides/${SLIDE_FILE}#g" buildPDF
        sed -i.bak "s#/data/output/presentation.pdf#/data/output/${OUTPUT_FILE}#g" buildPDF
        rm -f buildPDF.bak
        chmod +x buildPDF
        print_success "Created buildPDF"
    else
        print_error "Failed to obtain buildPDF.template"
        exit 1
    fi

    if download_or_copy_template "HELP.md.template" HELP.md; then
        sed -i.bak "s#pandoc-beamer:local#${DOCKER_IMAGE}#g" HELP.md
        sed -i.bak "s#registry.gitlab.com/woofi4/public/pandoc-presentation-creator/beamer-full:latest#${DOCKER_IMAGE}#g" HELP.md
        rm -f HELP.md.bak
        print_success "Created HELP.md"
    else
        print_error "Failed to obtain HELP.md.template"
        exit 1
    fi

    if download_or_copy_template "gitignore.template" .gitignore; then
        print_success "Created .gitignore"
    fi
}

# ─── Main ───────────────────────────────────────────────────────────────────

print_header "Pandoc Presentation Creator"

check_docker_image

echo ""
print_info "Version: ${VERSION}"
echo ""

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

# Remove this script after successful setup (mirrors documentation-creator pattern)
rm -f "${BASH_SOURCE[0]}"
