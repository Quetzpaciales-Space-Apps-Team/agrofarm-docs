# AgroFarm — NASA Space Apps Challenge 2026 Presentation (Max 7 Slides)

> **Compliance note:** Maximum 7 slides. Do not include NASA logos/branding or photographs of minors (< 18 years old).

---

## Slide 1 — Problem & Mission
**Title:** Adapting Smallholder Farms to Climate Variability
- Farmers in Guatemala face shifting rainfall patterns and ENSO (El Niño / La Niña) extremes.
- Decisions on crop rotation require combining climate/satellite indicators with local farm conditions and farmer priorities.
- **AgroFarm** is a decision-support tool that **supports — never replaces — farmers and local agronomists**.

---

## Slide 2 — Solution Overview
**Title:** What AgroFarm Does
- **Passwordless Judge Entry (`Try the demo`):** One click (`POST /v1/auth/demo`) creates an isolated guest session with an example farm — no login or published credentials required.
- **Set Priorities & Upload Data:** Weight 7 farmer priorities (`0..1`) + water/equipment constraints, and validate local CSV/GeoJSON parcel records (`EPSG:4326`, SI units).
- **Simulate & Compare:** Explore NASA POWER + NOAA ENSO history, run climate scenarios, and compare **at least 3 crop rotation strategies** (always including the current rotation).

---

## Slide 3 — Data & Scientific Transparency
**Title:** Grounded in Open Climate & Local Data
- **Served live in the app (`useMocks: false` against `core-api` + `ml-service`):**
  - **NASA POWER (`GET /v1/climate/nasa-power`):** Monthly agroclimatology (1995–2025 at `14.59, -90.53`, ~50 km reanalysis grid cell) served from an offline snapshot with full attribution.
  - **NOAA CPC ENSO (`GET /v1/climate/enso`):** Historical ONI & RONI series since `1950-01`.
  - **Rule-based Simulation & Rotations:** `POST /v1/scenarios/simulate` runs `agrofarm-stub` (declared fixed rules) and `POST /v1/farms/{id}/recommendations` runs `agrofarm-rotation-rule-engine` (`rules-0.1.1`) over provisional crop traits (`maize`, `black_beans`, `cover_crop`, `fallow`).
  - **Trained experimental modules with explicit limits:** Regional MODIS NDVI outlook (`vegetation/simulate`) and maize-leaf photo screening (`leaves/assess`), both carrying validation caveats and local-review requirements.
- **Strict SI units & hygiene:** `EPSG:4326`, `YYYY-MM-DD`, missing values as `null` (never `-99.9` or `0`), SI units (`mm/day`, `°C`, `%`, `km/h`, `MJ/m²/day`).

---

## Slide 4 — Explainable Recommendations (Not a Black Box)
**Title:** Every Strategy Shows Full Decision Context
Each compared rotation strategy (`>= 3`, including `is_current: true`) displays:
- **Why:** Plain-language rationale tied to farmer priorities and climate scenario.
- **Evidence:** Explicit statements linked to data sources (`insivumeh_daily`, `nasa_power`, `crop_traits`).
- **Benefits & Gaps:** Expected upside alongside missing local data (e.g., no parcel yield history).
- **Risks & Uncertainty:** Low/high score bounds and explicit `needs_local_review: true` flags for agronomist verification.
- **Provenance & Disclaimer:** Model name/version, data versions, input hash, timestamp, and visible human-in-the-loop disclaimer.

---

## Slide 5 — System Architecture
**Title:** Modular, Contract-First & Resilient
- **Frontend (`agrofarm-frontend`):** React 19 + TypeScript + Vite (`https://frontend-staging-7l2bzjrqpq-uc.a.run.app`, live against `core-api-staging`).
- **Core API (`agrofarm-api`):** FastAPI + PostgreSQL + Alembic + OpenAPI v1 contract tested with Schemathesis.
- **Analytics & ML (`agrofarm-analytic`):** Python data connectors (INSIVUMEH, NOAA ENSO, NASA POWER, CHIRPS, SoilGrids, DEM, WorldCover, Planetary Computer NDVI) + private Cloud Run `ml-service` (`--no-allow-unauthenticated`, Google ID token auth).
- **Offline resilience:** `DEMO_MODE=true` keeps cached snapshots as fallback if `ml-service` is unreachable.

---

## Slide 6 — Live Demo Walkthrough (Script)
**Title:** End-to-End Flow Without Login
1. **Open `https://frontend-staging-7l2bzjrqpq-uc.a.run.app` in incognito** and click **"Try the demo"** (`POST /v1/auth/demo`).
2. **Inspect Farm & Priorities** (`GET /v1/farms/{id}`, `PUT /v1/farms/{id}/priorities`) — adjust 7 priority weights and constraints.
3. **Upload Farm Data** (`POST /v1/farms/{id}/uploads`) — validate CSV/GeoJSON (`DEC-005`) with row-level error feedback.
4. **Explore NASA POWER & ENSO + Simulate** (`GET /v1/climate/nasa-power`, `GET /v1/climate/enso`, `POST /v1/scenarios/simulate`).
5. **Compare 4 Rotation Strategies** (`POST /v1/farms/{id}/recommendations`) — inspect the baseline marked as the current rotation against the other candidates (for example `maize -> black_beans` and `maize -> cover_crop`) with `why`, `evidence`, `benefits`, `gaps`, `risks`, `needs_local_review`, and `disclaimer`.

---

## Slide 7 — Impact, Limitations & Next Steps
**Title:** Built to Empower Local Decisions
- **Who benefits:** Smallholder farmers and local agricultural extensionists needing transparent, climate-aware rotation options.
- **Honest limitations:** Simulation and rotation scoring use declared fixed rules and provisional crop traits (no parcel-level yield training data yet); local soil tests and agronomist review remain essential.
- **Example farm note:** the guest farm created by `POST /v1/auth/demo` has the current rotation `maize, beans` in the API code. The offline demo snapshot and the frontend test stub use `maize, fallow` instead. Which baseline the staging comparison shows is not confirmed; check it during the rehearsal (`DEMO-002`) and say only what the screen shows. It is an example, not the real rotation of any parcel.
- **Next steps:** Calibrate models with local parcel yields (`ML-060`), complete agronomist trait review (`AGR-004`), and promote `develop` -> `main` across all 4 repositories.

---

## Speaker Script (30-Second Video / Live Pitch)
*(See [`video-script.md`](video-script.md) for the timestamped screen-by-screen script.)*
