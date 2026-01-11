#!/usr/bin/env python3
"""
Build a Beamer PDF using baked-in defaults.
- Base defaults: /opt/pandoc/defaults/beamer.yaml
- Supports additional --defaults files that override the baked defaults
- Supports --metadata key=value to pass values like footerbadge: Confidential

Usage:
  python3 /opt/pandoc/scripts/build_beamer.py -i slides.md -o output/presentation.pdf \
    --defaults /data/config/custom.yaml --metadata footerbadge=Confidential
"""

import argparse
import shlex
import subprocess
import sys
from pathlib import Path

BASE_DEFAULTS = "/opt/pandoc/defaults/beamer.yaml"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build Beamer PDF with baked defaults")
    parser.add_argument("-i", "--input", required=True, help="Input markdown file")
    parser.add_argument("-o", "--output", required=True, help="Output PDF path")
    parser.add_argument(
        "--defaults",
        action="append",
        default=[],
        help="Additional pandoc defaults files (merge order after baked defaults)",
    )
    parser.add_argument(
        "--metadata",
        action="append",
        default=[],
        help="Metadata key=value pairs (e.g. footerbadge=Confidential)",
    )
    parser.add_argument(
        "--pdf-engine",
        default=None,
        help="Override pdf-engine (defaults to value in baked defaults)",
    )
    return parser.parse_args()


def build_command(args: argparse.Namespace) -> list[str]:
    cmd = [
        "pandoc",
        "--defaults",
        BASE_DEFAULTS,
    ]

    for extra in args.defaults:
        cmd.extend(["--defaults", extra])

    for meta in args.metadata:
        cmd.append(f"--metadata={meta}")

    if args.pdf_engine:
        cmd.extend(["--pdf-engine", args.pdf_engine])

    cmd.extend([args.input, "-o", args.output])
    return cmd


def main() -> int:
    args = parse_args()

    cmd = build_command(args)
    print("Running:", " ".join(shlex.quote(part) for part in cmd))

    result = subprocess.run(cmd)
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
