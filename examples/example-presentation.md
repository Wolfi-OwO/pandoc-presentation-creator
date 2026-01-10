---
# Dieses Dokument verwendet die Metadaten aus metadata/common.yaml
---

# Willkommen zur Beispiel-Präsentation

Dies ist die erste Folie einer Beispiel-Präsentation, erstellt mit Pandoc.

---

## Über dieses Projekt

- Modulares Pandoc-Setup
- Unterstützung für mehrere Output-Formate
- Einfach erweiterbar
- Best Practices für Dokumentation

---

## Unterstützte Formate

::: columns
:::: column
### Web
- **Reveal.js**
- Interaktive HTML-Präsentationen
- Responsive Design
::::

:::: column
### Dokumente
- **Beamer** (PDF)
- **PowerPoint** (PPTX)
- Professional Look
::::
:::

---

## Code-Beispiele

```python
def hello_world():
    """Eine einfache Funktion."""
    print("Hello, World!")
    
if __name__ == "__main__":
    hello_world()
```

---

## Wichtige Features

::: info
**Information:** Dieses Projekt nutzt Pandoc defaults files für maximale Flexibilität.
:::

::: warning
**Warnung:** Stellen Sie sicher, dass alle Abhängigkeiten installiert sind!
:::

::: success
**Erfolg:** Mit diesem Setup können Sie schnell professionelle Präsentationen erstellen!
:::

---

## Listen und Aufzählungen

### Vorteile

1. Markdown-basiert
2. Wiederverwendbare Komponenten
3. Versionskontrolle mit Git
4. Cross-Platform

### Features

- Templates
- Filters
- Metadata-Management
- Custom Styling

---

## Tabellen

| Format    | Output | Komplexität |
|-----------|--------|-------------|
| Reveal.js | HTML   | Mittel      |
| Beamer    | PDF    | Hoch        |
| PPTX      | PPTX   | Niedrig     |

---

## Mathematische Formeln

Inline-Formel: $E = mc^2$

Block-Formel:

$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$

---

## Bilder

![Beispiel-Bild](https://via.placeholder.com/800x400.png?text=Ihr+Bild+hier)

*Hinweis: Ersetzen Sie diesen Platzhalter durch Ihr eigenes Bild.*

---

## Zitate

> "Die beste Art, die Zukunft vorherzusagen, ist, sie zu gestalten."  
> — Peter Drucker

---

## Inkrementelle Anzeige

Punkte werden nacheinander angezeigt:

::: incremental
- Erster Punkt
- Zweiter Punkt
- Dritter Punkt
:::

---

## Speaker Notes

Dies ist eine Folie mit Speaker Notes.

::: notes
Dies sind Notizen für den Sprecher:
- Wichtigen Punkt betonen
- Beispiel aus der Praxis nennen
- Fragen des Publikums zulassen
:::

---

## Anpassung

Das Projekt kann leicht angepasst werden:

- **Templates**: Eigene Vorlagen hinzufügen
- **Styles**: CSS/LaTeX anpassen
- **Filters**: Lua-Filter für Custom-Funktionalität
- **Metadata**: Zentrale Verwaltung von Informationen

---

## Nächste Schritte

1. Repository klonen oder Setup-Script ausführen
2. Eigene Präsentation in Markdown schreiben
3. Pandoc mit entsprechendem defaults file ausführen
4. Ergebnis überprüfen und anpassen

---

## Danke!

### Fragen?

**Kontakt:**  
max.mustermann@example.com

**Repository:**  
https://gitlab.com/woofi4/public/pandoc-presentation-creator

---

## Zusätzliche Ressourcen

- [Pandoc Dokumentation](https://pandoc.org/MANUAL.html)
- [Reveal.js Dokumentation](https://revealjs.com/)
- [Beamer Dokumentation](https://ctan.org/pkg/beamer)
- [Markdown Guide](https://www.markdownguide.org/)
