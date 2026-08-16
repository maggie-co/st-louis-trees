# St. Louis Flood & Canopy Infrastructure Map

## Quick Start
- **Working Directory**: `C:\Users\Maggie Coleman\portfolio\`
- **Dev Server**: Run `portfolio/scripts/serve_map.ps1`, then visit http://localhost:8420
- **GitHub**: https://github.com/maggie-co/tree-time (main branch)

## Key Files
- `portfolio/map_site/index.html` — The entire app (all CSS/JS inline)
- `portfolio/map_site/data/` — 13 GeoJSON layers (no external APIs)

## File Sync (IMPORTANT: NOT auto-synced)

When you're ready to push changes to GitHub:

```powershell
# Copy local edits to OneDrive git-tracked version
Copy-Item "C:\Users\Maggie Coleman\portfolio\map_site\*" `
  "C:\Users\Maggie Coleman\OneDrive - Washington University in St. Louis\FL2026\LEC\PreliminaryMap\site\" -Recurse -Force

# Navigate and commit
cd "C:\Users\Maggie Coleman\OneDrive - Washington University in St. Louis\FL2026\LEC\PreliminaryMap\site"
git add .
git commit -m "Your message here"
git push origin main
```

## Current Status

✅ **Complete**
- 11 data layers (trees, water bodies, hydrology, flood risk, MSD infrastructure, tornado)
- Dark CARTO basemap (85% opacity, no labels)
- Inferno color palette (dark purple → red → orange → yellow)
- Click-based feature popups
- Info icons with descriptions + cited sources
- Date metadata on all layer descriptions (YYYY format)
- May 2025 tornado overlay (path + tree damage points)

⏳ **Requested (not yet implemented)**
- Zoom-dependent layer visibility/detail
- Color palette refinement
- Footer attribution (data sources, creator credit)

## Data Layers (11 total)

| Group | Layers | Source | Date |
|-------|--------|--------|------|
| **Canopy** | Trees (133,881 points) | City of St. Louis Tree Inventory | 2020 |
| **Water bodies** | Rivers & Lakes (27 features) | City Flood Risk Map | 2020 |
| **Hydrology history** | Historic streams (275), Modern flow routes (136) | USGS (1904) & City modeled | 1904/2020 |
| **Flood risk** | FEMA floodplain (329), July 2022 parcels (752) | City Flood Risk Map | 2020/2022 |
| **MSD infrastructure** | Problem areas (77), Stormwater (262), Ownership (292) | Metropolitan St. Louis Sewer District | 2020 |
| **May 2025 Tornado** | EF-3 path, Tree damage points (441) | NWS Damage Toolkit | 2025 |

**Total: ~55MB GeoJSON (trees: 25MB, floodplain: 18MB)**

## User Preferences

✅ Keep changes local; don't auto-push to GitHub  
✅ Prefer dark mode & elegant simplicity  
✅ Terse, direct responses  
✅ No external APIs (all GeoJSON files, no API calls)

## Design Goals

- **Thesis focus**: Identify where green infrastructure investment matters most (canopy gaps + flood zones)
- **Style**: Times New Roman typography, dark theme, minimal UI
- **Interactivity**: Click popups, layer toggles, info modals
- **Portfolio presentation**: Consider adding stats dashboard, heatmap overlay, or focus-zone highlighting

## Architecture Notes

- Single-file HTML app (no build step, no external dependencies)
- MapLibre GL for rendering (WGS84 projection)
- Config-driven LAYERS array makes adding/removing layers simple
- No database; all data pre-loaded as GeoJSON
- Mobile-responsive but large initial load (50MB+)

---

**Next session**: Start here, run the dev server, and ask what visual enhancements you'd like to make.
