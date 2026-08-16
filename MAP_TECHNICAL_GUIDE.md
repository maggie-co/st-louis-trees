# St. Louis Flood & Canopy Map — Technical Guide

## Project Overview
An interactive web map analyzing tree canopy distribution overlaid with flood risk, hydrology, and stormwater infrastructure. Thesis-focused on identifying where green infrastructure investment matters most.

---

## Workflow & Techniques

### 1. **Data Acquisition & Preparation**
- **Sources**: City of St. Louis public datasets (trees, flood risk, MSD infrastructure), USGS historical maps, NWS damage assessments
- **Formats**: Shapefiles → GeoJSON (vector data format for web maps)
- **Projection**: Reprojected from NAD83 StatePlane MO East to **WGS84** (Web Mercator, standard for web mapping)
- **Optimization**: Reduced file sizes via field extraction (133,881 trees trimmed to essential attributes like DBH, species, condition)

### 2. **Color Palette Design**
- **Inferno colormap** (matplotlib): Dark purple → red → orange → yellow
- **Band-based assignment**: Each layer group gets a slice of the palette for visual hierarchy
  - Water: deep indigo (low contrast, recessive)
  - Hydrology: violet (historical reference)
  - Flood risk: magenta-red (danger signal)
  - MSD infrastructure: orange (emphasis)
  - Canopy: pale yellow (lone bright highlight)
- **Why**: Creates intuitive visual hierarchy on dark basemap; colors convey risk/abundance without legend

### 3. **Zoom-Dependent Rendering**
- **Technique**: MapLibre GL interpolation expressions control visibility/styling based on zoom level
- **Tree points**: Radius scales 0.08px (zoom 0) → 10px (zoom 20); opacity fades 40% → 90%
  - Prevents "clunky" noise when zoomed out (looks clean)
  - Reveals detail on zoom in (smooth transition)
- **Why**: Manages visual complexity; focuses user attention at appropriate scales

### 4. **Interactive Popups & Info Panels**
- **Click-based**: Users click features to reveal detailed attributes
- **Info icons**: Describe data sources, dates, methodology
- **Sidebar layer panel**: Checkboxes toggle layer visibility; colored swatches preview colors
- **Why**: Keeps UI clean; users self-direct exploration rather than overwhelming with all data at once

### 5. **Basemap & Styling**
- **CARTO Dark Matter** (raster tiles, 85% opacity): Professional dark background
- **Times New Roman typography**: Editorial/thesis aesthetic
- **CSS custom properties** (variables): Centralized color/spacing control
- **Why**: Cohesive visual identity; dark mode reduces eye strain, emphasizes data

### 6. **Frontend Architecture**
- **Single-file HTML**: All CSS, JavaScript, configuration inline (no build step)
- **MapLibre GL JS**: Open-source vector map rendering
- **Config-driven LAYERS array**: Add/remove layers by editing one data structure
- **Client-side rendering**: No backend; all data pre-loaded as GeoJSON
- **Why**: Fast iteration; low complexity; deploys anywhere static content is served

### 7. **Interactivity & UX**
- **Feature identification**: `map.on('click')` captures user interactions
- **Dynamic popups**: Template functions generate HTML based on feature properties
- **Cursor feedback**: Hover states indicate clickable features
- **Why**: Guides users; makes data exploration intuitive

---

## Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| **Frontend** | MapLibre GL JS 4.7.1 | Vector tile rendering, interactivity |
| **Data format** | GeoJSON (13 files, 55MB) | Portable, human-readable spatial data |
| **Styling** | CSS3 + MapLibre paint expressions | Layout, colors, zoom-dependent effects |
| **Scripting** | Vanilla JavaScript | Map logic, popups, event handling |
| **Basemap** | CARTO Dark Matter | Professional cartographic background |
| **Projection** | WGS84 (EPSG:4326) | Web standard; lat/lon coordinates |
| **Dev server** | PowerShell HttpListener | Local testing (localhost:8420) |
| **Version control** | Git + GitHub | Collaboration, deployment pipeline |
| **Deployment** | Vercel (static hosting) | Fast, global CDN for web maps |

---

## Key Geospatial Terms & Concepts

### **Spatial Data Formats**
- **GeoJSON**: JSON structure encoding geometry + properties; human-readable; ~10% overhead vs. shapefile but web-native
- **Shapefile** (legacy): Binary format; includes .shp (geometry), .dbf (attributes), .shx (index); requires conversion to GeoJSON
- **Vector data**: Points, lines, polygons (discrete features) vs. raster (continuous grids like satellite imagery)
- **Feature**: Single spatial object with geometry + properties (e.g., one tree = point + {species, DBH, condition})

### **Projections & Coordinate Systems**
- **WGS84 (EPSG:4326)**: Global standard; lat/lon; unprojected geographic coordinates
- **Web Mercator (EPSG:3857)**: Projection used by web maps; distorts area/distance at poles but preserves direction
- **NAD83 StatePlane MO East**: Local projection for Missouri; ftUS units; minimizes distortion for state-level surveying
- **Reprojection**: Converting coordinates between systems; necessary when combining data from different sources

### **Spatial Analysis Terms**
- **Buffer**: Create polygon around feature at distance X (e.g., "flood risk within 500m of river")
- **Spatial join**: Match features from two layers by location (e.g., "which trees are in floodplain?")
- **Density/heatmap**: Aggregate point data to show concentration; smooths noisy distributions
- **Overlay**: Combine multiple layers visually; MapLibre layer ordering determines stacking
- **Rasterize**: Convert vector to grid cells; used for heatmaps, efficient analysis at scale

### **Thematic Mapping**
- **Choropleth**: Color polygons by attribute value (e.g., "darker red = higher flood risk")
- **Symbol map**: Use point size/color to represent data (trees: size by DBH, color by species)
- **Heat map**: Interpolate point density into smooth gradient
- **Isoline**: Connect points of equal value (e.g., elevation contours)
- **Color ramp**: Sequential (light→dark), diverging (blue→red), categorical (distinct hues)

### **Map Interactivity**
- **Pan/zoom**: Navigate map; MapLibre handles smoothly
- **Click/hover**: Trigger information, visual feedback
- **Layer toggle**: Show/hide features dynamically
- **Query**: Retrieve feature attributes on interaction
- **Popup**: Display rich HTML content at feature location

### **Web Map Architecture**
- **Basemap**: Underlying reference layer (street map, satellite, etc.); provides context
- **Overlay**: Thematic data on top of basemap
- **Tile-based rendering**: Map divided into 256×256px tiles; only visible tiles download (fast loading)
- **Vector tiles**: Compact format for web; MapLibre renders them client-side
- **Client-side vs. server-side**: This map is fully client-side (no backend processing); all computation in browser

### **Performance & Scale**
- **File size**: 55MB GeoJSON is large; trees.json alone is 25MB (133k points); load time ~2-5s on broadband
- **Point clustering**: Group nearby points into single cluster; expands on click; reduces render overhead
- **Zoom-dependent detail**: Show only relevant data at each zoom level; reduces visual noise
- **Opacity/filtering**: Lower opacity, smaller points at low zoom to prevent visual clutter
- **Caching**: CDN (Vercel) + browser cache; repeat loads instant

### **Geospatial Analysis Concepts**
- **Canopy/tree inventory**: Point shapefile of all trees in jurisdiction; used for urban forestry planning
- **Floodplain**: Area subject to flooding; FEMA defines zones (A, AE, X = different risk levels)
- **Stormwater infrastructure**: Storm drains, detention ponds, MSD projects; critical for flood mitigation
- **Hydrology**: Study of water movement; historic streams show buried waterways; modern flow routes model rainfall paths
- **Green infrastructure**: Trees, rain gardens, permeable pavement; reduces flood risk + improves air quality
- **Canopy gap**: Area with <40% tree cover; target for reforestation; often overlaps flood zones (thesis focus)

### **Data Quality & Metadata**
- **Metadata**: "Data about data" (source, date, projection, attribute definitions); critical for reproducibility
- **Validation**: Check coordinate bounds, null values, duplicate features
- **Date awareness**: This map layers data from 1904 (historic streams) to 2025 (tornado damage); note temporal context
- **Uncertainty**: FEMA floodplain is probabilistic (100-year flood zone); NWS damage assessment is surveyed, not modeled

---

## Workflow Summary: Data → Map → Deploy

```
Raw data (shapefiles, CSVs)
    ↓ [Reproject NAD83 → WGS84]
    ↓ [Extract relevant fields]
GeoJSON files (13 layers, 55MB)
    ↓ [Version control]
GitHub repository
    ↓ [Single-file HTML app]
index.html (MapLibre GL + data + styling)
    ↓ [Git commit + push]
    ↓ [Vercel auto-deploys]
Live URL (maggie-co/tree-time on Vercel)
```

---

## How to Explain Your Work

**Elevator pitch (30 sec):**
> I built an interactive web map analyzing St. Louis's tree canopy and flood risk. The map layers 13 datasets—trees, FEMA floodplain, MSD stormwater infrastructure—to identify where green infrastructure investment would have the most impact. I used MapLibre GL for rendering, designed a custom color palette to convey risk hierarchy, and implemented zoom-dependent scaling to keep the interface clean while preserving detail.

**Technical deep-dive (3 min):**
> The project combines 55MB of GeoJSON data (133k tree points, 1k+ polygons) with zoom-dependent visualization techniques. I reprojected all data from NAD83 StatePlane to WGS84 for web compatibility, then assigned each layer group a band of the Inferno colormap for intuitive visual hierarchy—water in deep indigo, flood risk in red, canopy in yellow. The frontend is a single HTML file with MapLibre GL, allowing for fast iteration without a build step. Interactivity includes click-based feature popups, layer toggles, and info panels with data sources and dates. The site is deployed on Vercel, using CDN caching for fast global load times.

**For portfolio:**
> Emphasize: geospatial data integration, thematic cartography, frontend optimization (zoom-dependent rendering), UX design (info hierarchy, interactivity), and full-stack deployment (GitHub → Vercel).

---

## Next Steps for Enhancement

- **Advanced analysis**: Spatial join (trees ∩ floodplain) to quantify overlap; calculate canopy % by neighborhood
- **Heatmap overlay**: KDE density for tree concentration; identify "canopy deserts"
- **Time-series**: Before/after tornado damage; tree mortality tracking
- **Data export**: Allow users to download filtered results as CSV
- **Mobile optimization**: Responsive layout; touch-friendly popups; reduce initial load (tile smaller GeoJSON files)

