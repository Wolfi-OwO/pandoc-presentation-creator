#!/usr/bin/env bash
set -euo pipefail

# Build a Beamer PDF with the UBC-styled preamble using the Docker beamer image.
# Usage: ./scripts/build-docker-preamble.sh slides/Example.md output/presentation_preamble.pdf

IMAGE="${PANDOC_IMAGE:-registry.gitlab.com/woofi4/public/pandoc-presentation-creator/pandoc-beamer:latest}"
DEFAULTS="/data/core/defaults/beamer-preamble.yaml"

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "Usage: $0 <input-md> [output-pdf]" >&2
  exit 1
fi

INPUT="$1"
OUTPUT="${2:-output/presentation_preamble.pdf}"

if [ ! -f "$INPUT" ]; then
  echo "Input file '$INPUT' not found" >&2
  exit 1
fi

# Ensure output directory exists on host
OUTDIR="$(dirname "$OUTPUT")"
mkdir -p "$OUTDIR"

docker run --rm \
  -v "$(pwd)":/data \
  "$IMAGE" \
  --defaults "$DEFAULTS" \
  "/data/$INPUT" \
  -o "/data/$OUTPUT"

echo "Generated $OUTPUT using image $IMAGE"