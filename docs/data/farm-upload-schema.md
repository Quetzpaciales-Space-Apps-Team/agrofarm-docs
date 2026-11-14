# Farm Upload Schema (DEC-005)

- Status: accepted (provisional pilot polygon pending DEC-003)
- Date: 2026-11-14
- Owner: Person 6 (Backend, integration and demo)

## Purpose

Defines the canonical upload format for farm records (CSV and GeoJSON) shared by:
- `core-api` (`POST /v1/farms/{id}/uploads`, `BE-030`)
- `frontend` upload wizard (`FE-401`)
- `ml-service` calibration (`ML-060`)

## Global Rules

- **Coordinate Reference System:** `EPSG:4326` (WGS 84, `longitude` in `[-180, 180]`, `latitude` in `[-90, 90]`).
- **Dates:** ISO 8601 `YYYY-MM-DD`.
- **Missing values:** empty cell `""` in CSV, `null` in GeoJSON properties. Never `-99.9`, `-999`, or `0` as a sentinel.
- **Units:**
  - Rainfall: `mm/day` (or seasonal total `mm` where noted)
  - Temperature: `°C`
  - Humidity: `%`
  - Wind: `km/h`
  - Radiation: `MJ/m2/day`
  - Yield: `kg/ha`
  - Area: `ha`
  - Soil organic matter: `%`, soil nitrogen/phosphorus/potassium: `mg/kg`
- **CSV safety:** any exported CSV must escape cells starting with `=`, `+`, `-`, or `@`.

## CSV Schema

Each row represents one parcel-season observation.

| Column | Type | Unit | Required | Allowed values / Constraints |
|---|---|---|---|---|
| `parcel_id` | string | - | Yes | Non-empty identifier, max 64 chars (`^[a-zA-Z0-9_-]+$`) |
| `season_year` | integer | year | Yes | `1980 <= season_year <= 2030` |
| `crop` | string | - | Yes | Lowercase English crop name (e.g., `maize`, `beans`, `squash`, `sorghum`, `tomato`, `fallow`) |
| `sowing_date` | date | `YYYY-MM-DD` | Yes | Valid ISO date |
| `harvest_date` | date | `YYYY-MM-DD` | No | Valid ISO date; must be `>= sowing_date` when present |
| `area_ha` | float | `ha` | Yes | `> 0` and `<= 100000` |
| `latitude` | float | `deg` (EPSG:4326) | Yes | `-90.0 <= latitude <= 90.0` |
| `longitude` | float | `deg` (EPSG:4326) | Yes | `-180.0 <= longitude <= 180.0` |
| `yield_kg_ha` | float | `kg/ha` | No | `>= 0` (empty if not yet harvested or fallow) |
| `irrigation` | string | - | No | `rainfed`, `drip`, `sprinkler`, `furrow`, or empty |
| `soil_ph` | float | `pH` | No | `3.0 <= soil_ph <= 10.0` |
| `soil_om_pct` | float | `%` | No | `0.0 <= soil_om_pct <= 100.0` |
| `soil_n_mg_kg` | float | `mg/kg` | No | `>= 0` |
| `soil_p_mg_kg` | float | `mg/kg` | No | `>= 0` |
| `soil_k_mg_kg` | float | `mg/kg` | No | `>= 0` |
| `rainfall_season_mm` | float | `mm` | No | `>= 0` |
| `notes` | string | - | No | Plain text, max 500 chars |

## GeoJSON Schema

- Must be a valid GeoJSON `FeatureCollection` (RFC 7946, `EPSG:4326`).
- Each `Feature` must have:
  - `geometry`: `Polygon` or `MultiPolygon` with valid closed rings in `[longitude, latitude]` order.
  - `properties`: object following the same field names, types, units, and constraints as the CSV schema (`latitude` and `longitude` are optional in GeoJSON when derived from geometry centroid, but `parcel_id`, `season_year`, `crop`, `sowing_date`, `area_ha` remain required).
  - Optional metadata flag `provisional: true` when using a reference polygon before `DEC-003` is finalized.

## Examples

- Valid CSV template: [farm-upload-template.csv](examples/farm-upload-template.csv)
- Invalid CSV example (for validation tests): [farm-upload-invalid.csv](examples/farm-upload-invalid.csv)
- Valid GeoJSON example (provisional Guatemala City polygon): [farm-upload-example.geojson](examples/farm-upload-example.geojson)
