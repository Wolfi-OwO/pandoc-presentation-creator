#!/bin/bash
set -e

# ==============================================================================
# Build Script for Pandoc Presentations
# ==============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$PROJECT_ROOT/config/settings.yaml"

# Helper to load config
get_conf() {
    grep "^$1:" "$CONFIG" | cut -d: -f2- | tr -d ' "'
}

# Load Settings
THEME=$(get_conf theme)
INPUT=$(get_conf input)
OUTPUT_DIR=$(get_conf output_dir)
IMAGE=$(get_conf docker_image)

mkdir -p "$PROJECT_ROOT/$OUTPUT_DIR"

if [ -f "/.dockerenv" ]; then
    # INTERNAL BUILD (Inside Docker)
    echo "Building $INPUT inside container..."
    
    FILENAME=$(basename "$INPUT" .md)
    OUTPUT_FILE="$OUTPUT_DIR/$FILENAME.pdf"

    pandoc "$INPUT"         -t beamer         --theme="$THEME"         -o "$OUTPUT_FILE"         --standalone         --slide-level=2

    echo "Success: $OUTPUT_FILE"
else
    # EXTERNAL BUILD (Host -> Docker)
    echo "Running build via Docker Image: $IMAGE"
    
    # Check if image exists locally, if not try to pull
    if ! docker image inspect "$IMAGE" > /dev/null 2>&1; then
        echo "Image not found locally. Attempting to pull or suggest build..."
        # Optional: docker pull "$IMAGE" || echo "Pull failed. Building..." 
        # For this setup, we rely on init.sh having built it or user building it.
        echo "Warning: Image $IMAGE not found locally."
        echo "Please run ./init.sh or docker build -t $IMAGE -f docker/Dockerfile.beamer ."
    fi

    docker run --rm         -v "$PROJECT_ROOT:/data"         -w /data         "$IMAGE"         ./scripts/build.sh
fi
