## Pandoc Presentation Creator - Release ${CI_COMMIT_TAG}

### Docker Images

- **Beamer:** `${CI_REGISTRY_IMAGE}/beamer-full:${CI_COMMIT_TAG}`
- **Beamer (latest):** `${CI_REGISTRY_IMAGE}/beamer-full:latest`
- **Base:** `${CI_REGISTRY_IMAGE}/beamer-base:${CI_COMMIT_TAG}`
- **Base (latest):** `${CI_REGISTRY_IMAGE}/beamer-base:latest`

### Usage

Pull and run the Beamer image:

```bash
docker pull ${CI_REGISTRY_IMAGE}/beamer-full:${CI_COMMIT_TAG}

docker run --rm -v $(pwd):/data --user root \
  ${CI_REGISTRY_IMAGE}/beamer-full:${CI_COMMIT_TAG} \
  --defaults /opt/pandoc/defaults/beamer.yaml \
  /data/slides/your-presentation.md \
  -o /data/output/presentation.pdf
```

### Test Artifacts

See the attached PDF files generated during CI testing.
