# Quickstart Guide

This guide will help you set up and build your first presentation using the Pandoc Presentation Creator.

## Prerequisites

- **Docker**: Recommended for a consistent build environment.
- **Git**: To clone and manage the repository.

*Alternatively, if you do not use Docker, you must have Pandoc and TeXLive installed on your local machine.*

## Initialization

1. Open your terminal and navigate to the project root.
2. Run the initialization script:

    ```bash
    ./init.sh
    ```

3. Follow the interactive prompts to set your Project Title, Author, and Theme.
4. The script will automatically build the required Docker image.

## Building Slides

To generate your PDF slides, run the build script:

```bash
./scripts/build.sh
```

The output PDF will be located in the `output/` directory.

## Customization

- **Project Settings**: Edit `config/settings.yaml` to change the title, author, or theme later.
- **Content**: Modify the Markdown files in the `presentations/` directory.
- **Themes**: You can switch themes in the settings file (e.g., "Madrid", "Metropolis").

## Directory Structure

- `docker/`: Contains the Dockerfile for the build environment.
- `presentations/`: Store your Markdown source files here.
- `scripts/`: Contains automation scripts for building.
- `config/`: Configuration files for your project.
- `info/`: Additional documentation.
