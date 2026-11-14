# AgroFarm — NASA Space Apps Challenge 2026 Presentation (Max 7 Slides)

> **Compliance note:** Maximum 7 slides. Do not include NASA logos/branding or photographs of minors (< 18 years old).

---

## Slide 1 — Problem & Mission
**Title:** Adapting Smallholder Farms to Climate Variability
- Farmers in Guatemala face shifting rainfall patterns and ENSO (El Niño / La Niña) extremes.
- Decisions on crop rotation require combining satellite/climate signals with local farm conditions and farmer priorities.
- **AgroFarm** is a decision-support tool that **supports — never replaces — farmers and local agronomists**.

---

## Slide 2 — Solution Overview
**Title:** What AgroFarm Does
- **Define the farm:** Register and draw or upload a parcel polygon (`EPSG:4326`, GeoJSON) plus local CSV/GeoJSON farm observations.
- **Set priorities:** Weight water use, income, soil structure, forage value, nitrogen fixing, erosion reduction, and market suitability, plus water/equipment constraints.
- **Simulate & compare:** Run ENSO / rainfall / temperature scenarios and compare **at least 3 crop rotation strategies** (always including the farm's current rotation).

---

## Slide 3 — Data & Scientific Transparency
**Title:** Grounded in Open Climate & Local Data
- **Active in current demo (`DEMO_MODE=true` / `ML_MODE=fixture`):**
  - `core-api` serves deterministic offline snapshots (`cached_demo`) for ENSO series (`NOAA CPC` sample), scenario yield anomaly simulation, and 3+ rotation comparisons.
  - `agrofarm-analytic` includes Python connectors for **NOAA CPC (ONI / RONI)** and **INSIVUMEH** daily weather stations (converting `-99.9` sentinels to `null`), ready to wire once HTTP endpoints are exposed via `docs/contract/ml-service-expected.yaml`.
- **Cataloged architecture (`docs/data/datasets.md`) for post-hackathon ingestion:** NASA POWER, CHIRPS v3, SMAP L4, MODIS (MOD13Q1, MOD11A2, MOD15A2H, MOD17A2H), HLS / Sentinel-2, SoilGrids 2.0, NASADEM / Copernicus DEM, GPM IMERG, ECOSTRESS.
- **Strict SI units & hygiene:** `EPSG:4326`, `YYYY-MM-DD`, missing values as `null`/`NaN` (never `-99.9` or `0`), SI units (`mm/day`, `°C`, `%`, `km/h`, `MJ/m²/day`).

---

## Slide 4 — Explainable Recommendations (Not a Black Box)
**Title:** Every Strategy Shows Full Decision Context
Each compared rotation strategy (`>= 3`, including `is_current: true`) displays:
- **Why:** Plain-language rationale tied to farmer priorities and climate scenario.
- **Evidence:** Explicit statements linked to data sources (`insivumeh_daily`, `nasa_power`, `noaa_cpc`).
- **Benefits & Gaps:** Expected upside alongside missing local data (e.g., limited parcel yield history).
- **Risks & Uncertainty:** Low/high score bounds and explicit `needs_local_review` flags for agronomist verification.
- **Provenance:** Model version, data versions, input hash, and timestamp persisted per recommendation.

---

## Slide 5 — System Architecture
**Title:** Modular, Contract-First & Offline-Resilient
- **Frontend (`agrofarm-frontend`):** React 19 + TypeScript + Vite.
- **Core API (`agrofarm-api`):** FastAPI + PostgreSQL + Alembic migrations + OpenAPI v1 contract tested with Schemathesis.
- **Analytics & ML (`agrofarm-analytic`):** Python data connectors (NOAA ENSO, INSIVUMEH) and ML scenario/rotation scoring service (`ML_MODE=http|fixture`, plus `DEMO_MODE=true` offline snapshot fallback).
- **Offline resilience:** `make seed-demo` + `DEMO_MODE=true` guarantees a working live demo even with zero internet access.

---

## Slide 6 — Live Demo Walkthrough (Script)
**Title:** End-to-End Flow in Under 3 Minutes (or 30s Highlight)
1. **Register / Login** (`POST /v1/auth/register`, `/v1/auth/login`) — or use seeded `demo@agrofarm.org`.
2. **Create / Draw Farm** (`POST /v1/farms`) — provisional Guatemala City pilot polygon (`EPSG:4326`), `maize -> fallow`.
3. **Upload Farm Data** (`POST /v1/farms/{id}/uploads`) — validated CSV/GeoJSON with row-level error reporting and SI unit checks.
4. **Explore ENSO & Simulate Scenario** (`GET /v1/climate/enso`, `POST /v1/scenarios/simulate`) — e.g., El Niño with `-15%` rainfall and `+1.0°C`.
5. **Compare 3+ Rotations** (`POST /v1/farms/{id}/recommendations`) — side-by-side comparison of current `maize -> fallow` vs. `maize -> beans -> sorghum` and cover-crop alternatives, highlighting `why`, `evidence`, `benefits`, `gaps`, `risks`, and `needs_local_review`.

---

## Slide 7 — Impact, Limitations & Next Steps
**Title:** Built to Empower Local Decisions
- **Who benefits:** Smallholder farmers and local agricultural extensionists needing transparent, climate-aware rotation options.
- **Honest limitations:** Current MVP runs with deterministic fixtures/offline snapshots for some satellite layers until full ingestion pipelines finish; local soil tests and agronomist review remain essential.
- **Next steps:** Connect live CHIRPS/SMAP/MODIS pipelines from `agrofarm-analytic`, deploy public Cloud Run preview, and validate with local Guatemala pilot plots.

---

## Speaker Script (30-Second Video / Live Pitch)

- **0:00–0:06 (Slide 1-2):** "Farmers in Guatemala face unpredictable El Niño and La Niña seasons. AgroFarm helps farmers and local agronomists compare crop rotations using climate data and their own farm priorities."
- **0:06–0:14 (Demo: Farm + Upload + ENSO):** "In AgroFarm, a farmer registers their parcel in EPSG:4326, uploads local field CSV or GeoJSON records with strict unit validation, and checks the latest NOAA ENSO phase."
- **0:14–0:24 (Demo: Scenario + 3 Rotations):** "Running an El Niño scenario compares at least three rotations—including their current maize-fallow baseline—showing clear scores, evidence, benefits, data gaps, and risks flagged for local expert review."
- **0:24–0:30 (Close):** "AgroFarm supports decisions without replacing the farmer, backed by an open, offline-ready API and transparent provenance."
