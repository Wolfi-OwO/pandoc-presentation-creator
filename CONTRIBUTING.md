# Contributing to Pandoc Presentation Creator

Thanks for contributing.

## Ways To Contribute

### Report Bugs

Before creating a new issue, check existing issues first:

- <https://gitlab.com/woofi4/public/pandoc-presentation-creator/-/issues>

When reporting a bug, include:

1. What you expected to happen
2. What actually happened
3. Exact commands you ran
4. OS and Docker version
5. Relevant logs or error output

### Propose Features

Open an issue with:

1. Problem statement
2. Proposed solution
3. Alternatives considered

### Improve Documentation

Docs updates are welcome, especially for:

1. Build workflow examples
2. Troubleshooting steps
3. Onboarding/initialization flow

## Local Development Workflow

### 1. Fork and Branch

```bash
git checkout -b feature/my-change
```

### 2. Make Changes

Keep changes focused and avoid unrelated refactors.

### 3. Verify Build Workflow

Use the same workflow documented for users:

```bash
docker pull registry.gitlab.com/woofi4/public/pandoc-presentation-creator/beamer-full:latest
docker run --rm \
   -v "$(pwd):/data" \
   --entrypoint=/bin/sh \
   registry.gitlab.com/woofi4/public/pandoc-presentation-creator/beamer-full:latest \
   -c "/data/buildPDF"
```

Confirm a PDF is generated under `output/`.

### 4. Verify VS Code Task (Optional)

Run the default build task in VS Code (`Ctrl+Shift+B`) and ensure it produces a PDF.

### 5. Update Documentation

If behavior changed, update affected docs in the same PR:

1. `README.md`
2. `templates/HELP.md.template`
3. Docker readmes when image behavior changed

## Contribution Rules

1. Keep scripts shell-compatible on Linux
2. Keep shell scripts LF-terminated (`.gitattributes` handles this)
3. Preserve existing project structure unless change requires otherwise
4. Document user-facing changes

## Merge Request Checklist

1. Build succeeds locally
2. Output PDF generation verified
3. Docs updated for changed behavior
4. Clear MR description with scope and testing notes

## Code of Conduct

1. Be respectful and constructive
2. Focus on technical quality and collaboration

## Questions

Open an issue in the repository or contact the maintainer.
