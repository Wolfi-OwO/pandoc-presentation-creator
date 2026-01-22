#!/bin/bash
set -e

# ==============================================================================
# Universal Presentation Engine - Bootstrap Initialization
# ==============================================================================
# This script downloads all necessary files and sets up a complete project

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

REPO_URL="https://gitlab.com/woofi4/public/pandoc-presentation-creator/-/raw/main"
PROJECT_DIR="$(pwd)"

echo -e "${BLUE}--- Pandoc Presentation Project Bootstrap ---${NC}"
echo ""
echo "Setting up project with default configuration..."
echo "You can customize settings in config/config.yaml after setup."
echo ""

# Step 1: Use Default Configuration
TITLE="My Presentation"
AUTHOR="Author Name"
FORMAT="beamer"
IMAGE_TYPE="beamer"
OUTPUT_EXT="pdf"
THEME="Madrid"

# Step 2: Create Only User-Facing Directory Structure
echo ""
echo "Creating project directories..."
mkdir -p output
mkdir -p config
mkdir -p slides

echo -e "${GREEN}Directory structure created${NC}"

# Step 3: No need to download - using Docker image from registry
echo ""
echo "Using Docker image from registry: ${REPO_URL%%-/raw/*}/container_registry"

# Step 4: Create Project Settings
echo ""
echo "Creating project configuration..."

# Get the script directory to locate templates
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TEMPLATE_DIR="${SCRIPT_DIR}/out/documentary"

# If templates don't exist locally, download them from repository
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Downloading templates from repository..."
    mkdir -p "$TEMPLATE_DIR"

    TEMPLATES=(
        "config.yaml.template"
        "build.env.template"
        "Example.md.template"
        "Themed-Feature.md.template"
        "HELP.md.template"
        "README.md.template"
        "gitignore.template"
    )

    for template in "${TEMPLATES[@]}"; do
        curl -sSL "${REPO_URL}/out/documentary/${template}" -o "${TEMPLATE_DIR}/${template}" || {
            echo -e "${RED}Failed to download ${template}${NC}"
            exit 1
        }
    done

    echo -e "${GREEN}Templates downloaded${NC}"
fi

# Copy and substitute config.yaml
cp "${TEMPLATE_DIR}/config.yaml.template" config/config.yaml
sed -i.bak "s/FORMAT_PLACEHOLDER/$FORMAT/g" config/config.yaml
sed -i.bak "s/TITLE_PLACEHOLDER/$TITLE/g" config/config.yaml
sed -i.bak "s/AUTHOR_PLACEHOLDER/$AUTHOR/g" config/config.yaml
sed -i.bak "s/DATE_PLACEHOLDER/$(date +%d.%m.%Y)/g" config/config.yaml
sed -i.bak "s/THEME_PLACEHOLDER/$THEME/g" config/config.yaml
rm -f config/config.yaml.bak

# Copy and substitute build.env
cp "${TEMPLATE_DIR}/build.env.template" config/build.env
sed -i.bak "s/FORMAT_PLACEHOLDER/$FORMAT/g" config/build.env
sed -i.bak "s/IMAGE_TYPE_PLACEHOLDER/$IMAGE_TYPE/g" config/build.env
sed -i.bak "s/OUTPUT_EXT_PLACEHOLDER/$OUTPUT_EXT/g" config/build.env
rm -f config/build.env.bak

echo -e "${GREEN}Configuration saved to config/config.yaml${NC}"

# Step 5: Create Example Presentation
echo ""
echo "Creating example presentation..."

# Copy and substitute Example.md
cp "${TEMPLATE_DIR}/Example.md.template" slides/Example.md
sed -i.bak "s/TITLE_PLACEHOLDER/$TITLE/g" slides/Example.md
sed -i.bak "s/AUTHOR_PLACEHOLDER/$AUTHOR/g" slides/Example.md
sed -i.bak "s/THEME_PLACEHOLDER/$THEME/g" slides/Example.md
rm -f slides/Example.md.bak

echo -e "${GREEN}Example presentation created at slides/Example.md${NC}"

# Step 6: Create Minimal Documentation
echo ""
echo "Creating documentation..."

# Copy and substitute HELP.md
cp "${TEMPLATE_DIR}/HELP.md.template" HELP.md
sed -i.bak "s/IMAGE_TYPE_PLACEHOLDER/$IMAGE_TYPE/g" HELP.md
sed -i.bak "s/OUTPUT_EXT_PLACEHOLDER/$OUTPUT_EXT/g" HELP.md
rm -f HELP.md.bak

# Copy README.md
cp "${TEMPLATE_DIR}/README.md.template" README.md

echo -e "${GREEN}Documentation created${NC}"

# Step 7: Create .gitignore
cp "${TEMPLATE_DIR}/gitignore.template" .gitignore

# Step 8: Pull Docker Image from Registry
echo ""
echo "Configuring Docker image from registry..."
DOCKER_IMAGE="registry.gitlab.com/woofi4/public/pandoc-presentation-creator:${IMAGE_TYPE}-latest"

if command -v docker &> /dev/null; then
    echo -e "${BLUE}Pulling Docker image from registry...${NC}"
    docker pull "$DOCKER_IMAGE" || echo "Note: Could not pull image. Ensure you have internet access."
    echo -e "${GREEN}Docker image ready${NC}"
    echo ""
    echo "To build your presentation, run:"
    echo "docker run --rm -v \$(pwd):/data $DOCKER_IMAGE --defaults /data/config/config.yaml /data/slides/Example.md -o /data/output/presentation.$OUTPUT_EXT"
else
    echo "Docker not found. Please install Docker to use this project."
fi

rm -rf out/*

echo ""
echo -e "${GREEN}Setup Complete!${NC}"
echo ""
echo "Your project structure:"
echo "  config/config.yaml  - Edit this to set title, author, theme"
echo "  slides/Example.md   - Edit this to create your presentation"
echo "  output/             - Generated PDFs will appear here"
echo ""
echo "Customize your presentation:"
echo "1. Edit config/config.yaml to set your title and author"
echo "2. Edit slides/Example.md to write your content"
echo "3. See HELP.md for build commands"
echo ""
echo "Docker image includes: templates, filters, build scripts, themes"
