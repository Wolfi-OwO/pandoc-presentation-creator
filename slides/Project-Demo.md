---
# This document uses metadata from metadata/common.yaml
---

# Welcome to the Example Presentation

This is the first slide of an example presentation created with Pandoc.

---

## About This Project

- Modular Pandoc setup
- Support for multiple output formats
- Easy to extend
- Best practices for documentation

---

## Supported Formats

::: columns
:::: column

### Web

- **Reveal.js**
- Interactive HTML presentations
- Responsive design
::::

:::: column

### Documents

- **Beamer** (PDF)
- **PowerPoint** (PPTX)
- Professional look
::::
:::

---

## Code Examples

```python
def hello_world():
    """A simple function."""
    print("Hello, World!")

if __name__ == "__main__":
    hello_world()
```

---

## Important Features

::: info
**Info:** This project uses Pandoc defaults files for maximum flexibility.
:::

::: warning
**Warning:** Make sure all dependencies are installed.
:::

::: success
**Success:** With this setup, you can quickly create professional presentations.
:::

---

## Lists and Bullets

### Benefits

1. Markdown-based
2. Reusable components
3. Version control with Git
4. Cross-platform

### Features

- Templates
- Filters
- Metadata management
- Custom styling

---

## Tables

| Format    | Output | Complexity |
|-----------|--------|------------|
| Reveal.js | HTML   | Medium     |
| Beamer    | PDF    | High       |
| PPTX      | PPTX   | Low        |

---

## Math Formulas

Inline formula: $E = mc^2$

Block formula:

$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$

---

## Images

![Example image](https://via.placeholder.com/800x400.png?text=Your+Image+Here)

*Note: Replace this placeholder with your own image.*

---

## Quotes

> "The best way to predict the future is to create it."
> - Peter Drucker

---

## Incremental Display

Points are shown one by one:

::: incremental

- First point
- Second point
- Third point
:::

---

## Speaker Notes

This is a slide with speaker notes.

::: notes
These are speaker notes:

- Emphasize key point
- Give a real-world example
- Allow audience questions
:::

---

## Customization

The project can be easily customized:

- **Templates**: Add custom templates
- **Styles**: Adjust CSS/LaTeX
- **Filters**: Use Lua filters for custom behavior
- **Metadata**: Centralized information management

---

## Next Steps

1. Clone the repository or run the setup script
2. Write your own presentation in Markdown
3. Run Pandoc with the appropriate defaults file
4. Review and refine the output

---

## Thank You

### Questions?

**Contact:**
<max.mustermann@example.com>

**Repository:**
<https://gitlab.com/woofi4/public/pandoc-presentation-creator\>

---

## Additional Resources

- [Pandoc Documentation](https://pandoc.org/MANUAL.html)
- [Reveal.js Documentation](https://revealjs.com/)
- [Beamer Documentation](https://ctan.org/pkg/beamer)
- [Markdown Guide](https://www.markdownguide.org/)
