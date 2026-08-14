# Maggie Coleman Portfolio

This repo holds multiple layout explorations for the portfolio site. Each
version lives in its own folder with its own `index.html` and `styles.css`,
so they can be developed independently. The root `index.html` is a landing
page that links out to each version.

## Structure

```text
index.html      # landing page — links to each layout version
hub.css         # styles for the landing page only
v1/             # Swiss editorial grid layout
  index.html
  styles.css
v2/             # Bookshelf layout
  index.html
  styles.css
```

## Versions

- **v1 — Swiss Editorial**: bold Helvetica, black-on-paper, 3-column
  category grid (Architecture / Maps / Miscellaneous) with rule-line
  dividers.
- **v2 — Bookshelf**: dark mode, projects rendered as book spines grouped
  onto shelves by category. Hovering (or focusing) a book reveals its
  title, meta, and year in a panel that slides up from the bottom.

## Preview

```bash
python3 -m http.server 8000
```

Open `http://localhost:8000` for the landing page, or go straight to a
version, e.g. `http://localhost:8000/v1/`.
