# NASA Space Apps Challenge 2026 — Submission Form Copy (`DEMO-003`)

> All text below is in English and reflects only verified capabilities in the team repositories.

---

## Project Name
**AgroFarm: Climate-Aware Crop Rotation Decision Support**

## High-Level Summary
AgroFarm is a decision-support prototype for smallholder farmers and local agronomists. It displays historical NASA POWER and NOAA CPC ENSO indicators, runs live climate-scenario and rotation-comparison services (`>= 3` strategies including the farm's current rotation), and presents the rationale, evidence, benefits, information gaps, risks, uncertainty bounds, and local-review disclaimer for every recommendation.

## Link to Demo
- **Primary Live Demo URL (no login required — click `"Try the demo"`):** `https://frontend-staging-7l2bzjrqpq-uc.a.run.app` (verified)
- **Custom domain:** `https://agrofarming.site` answered with the same app on 2026-11-15, but it was reported as not configured; not confirmed, so do not list it unless the team confirms it.

## Link to Final Project
- **Demo Video (`<= 30s`):** `TODO_PUBLIC_URL`
- **Presentation Slides (`<= 7` slides):** `TODO_PUBLIC_URL`
- **Public Repositories (`G12` — all 4 verified PUBLIC on 2026-11-15):**
  - `agrofarm-api`: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-api` (PUBLIC)
  - `agrofarm-analytic`: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-analytic` (PUBLIC)
  - `agrofarm-frontend`: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-frontend` (PUBLIC)
  - `agrofarm-docs`: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-docs` (PUBLIC)

## Detailed Description
Smallholder farmers in Guatemala face increasing rainfall variability and El Niño / La Niña (ENSO) extremes, yet most agricultural tools either hide assumptions in black-box scores or ignore the farmer's own water, equipment, and income constraints.

**AgroFarm** addresses this by putting the farmer and local agronomist in control (live without mocks against `core-api` + `ml-service` in staging):
1. **Passwordless Judge Demo & Example Farm (`POST /v1/auth/demo`):** Visitors open the app without credentials via `"Try the demo"`, receiving an isolated guest session and an example farm with seven farmer priority weights (`water_use`, `income`, `soil_structure`, `forage_value`, `nitrogen_fixing`, `erosion_reduction`, `market_suitability`) plus water availability and equipment constraints.
2. **Validated Local Data Upload (`POST /v1/farms/{farm_id}/uploads`):** Farmers or extensionists upload CSV or `EPSG:4326` GeoJSON observations (`YYYY-MM-DD`, SI units, `null` for missing values) with row-level validation errors. Valid observations are stored (uploads do not yet calibrate the rotation rules).
3. **NASA POWER & ENSO Climate Context (`GET /v1/climate/nasa-power`, `GET /v1/climate/enso`):** Users inspect monthly NASA POWER agroclimatology (1995–2025 at `14.59, -90.53`) and historical NOAA CPC ONI/RONI ENSO phases.
4. **Scenario Simulation & Transparent Rotation Comparison (`POST /v1/scenarios/simulate`, `POST /v1/farms/{farm_id}/recommendations`):** Users adjust rainfall, temperature, and ENSO controls to inspect yield-anomaly ranges (`p10`/`p50`/`p90` from the declared fixed-rule `agrofarm-stub`) and compare **at least three rotation strategies** (including the current rotation) scored by `agrofarm-rotation-rule-engine` (`rules-0.1.1`) over a provisional crop traits table (`maize`, `black_beans`, `cover_crop`, `fallow`). Every strategy includes `why`, `evidence`, `benefits`, `gaps`, `risks`, `needs_local_review`, `uncertainty`, per-priority `scores`, `provenance`, and a visible `disclaimer`.
5. **Additional Experimental / Screening Endpoints Integrated in the App:** Regional cropland NDVI outlook (`POST /v1/farms/{farm_id}/vegetation/simulate`, trained LightGBM quantiles with explicit notice that it missed the 5% skill target) and maize-leaf photo screening (`POST /v1/farms/{farm_id}/leaves/assess`, uncalibrated candidate classes requiring local review).

**Human-in-the-loop principle:** AgroFarm explicitly states on every screen and recommendation that it supports decisions and does not replace farmers or local agronomists.

## Use of Super Intelligence (SI)

> "SI" in the Space Apps form means AI tools, not SI units. Draft: every team member must confirm/add the tools they used before submission.

Yes. AI coding assistants were used to accelerate implementation and documentation; `TODO_TEAM_CONFIRM`: confirm that project ideas were not AI-generated. SI usage is disclosed in project text, `AI_USAGE.md` across repositories, and pull requests.

- **Code:** AI coding assistants (Claude Code, OpenAI Codex, Antigravity) assisted with backend/frontend scaffolding, tests, CI workflows, and OpenAPI contracts. Team members must confirm their individual tools before submission.
- **Documentation:** AI assistants helped draft or refine the project plan, dataset catalog, agronomy sheets, repository rules, and demo/submission materials (reviewed by team members).
- **Machine learning inside the product:** The active `/v1/simulate` and `/v1/rotations/score` endpoints in `ml-service` run declared fixed rules (`agrofarm-stub`) and a rule engine (`rules-0.1.1`) over a provisional crop traits table, not a trained yield model. A regional seasonal peak NDVI LightGBM model (`POST /v1/farms/{farm_id}/vegetation/simulate`) and a maize-leaf classifier (`POST /v1/farms/{farm_id}/leaves/assess`) are also served with explicit validation limits and local-review disclaimers.
- **Images, video and audio:** `TODO_TEAM_CONFIRM`: state "none generated with AI", or list any generated assets and add a visible watermark.

## NASA Data
- **NASA POWER (agroclimatology), served in the app (`GET /v1/climate/nasa-power`):** Monthly rainfall and mean/min/max temperature, relative humidity, solar radiation, and wind speed for the Guatemala City reference point (`14.59, -90.53`), 1995–2025, served from a stored offline snapshot of NASA POWER Daily API data with source, attribution, and ~50 km reanalysis grid-cell notice.
- **NASA MODIS MOD13Q1 NDVI (Terra):** Used in the regional cropland NDVI outlook (`POST /v1/farms/{farm_id}/vegetation/simulate`) and documented in [the annex](../model/ndvi-experimental-result.md) (4.4% error reduction vs. climatology, below the 5% target).
- **Other cataloged NASA Earth Observation datasets (`docs/data/datasets.md`, planned pipeline):** SMAP L4, MOD11A2, MOD15A2H, MOD17A2H, HLS, GPM IMERG, ECOSTRESS, and NASADEM (connectors/cataloged; not all shown in the live UI).

## Space Agency Partner Data & Other References
- **NOAA Climate Prediction Center (CPC):** Oceanic Niño Index (ONI) and Relative Oceanic Niño Index (RONI) served via `GET /v1/climate/enso` (from `1950-01`).
- **INSIVUMEH (Guatemala):** Local daily meteorological station connector (`insivumeh.py`) and reference evidence statements.
- **User-Provided Farm Data:** Parcel boundaries (`EPSG:4326` GeoJSON) and field observations (CSV/GeoJSON) validated by `POST /v1/farms/{farm_id}/uploads`.
- **International System (SI) & Standard Units:** `mm/day` (or `mm/month` for monthly aggregates), `°C`, `%`, `km/h`, `MJ/m²/day`, `YYYY-MM-DD` dates, and `null`/`NaN` for missing values.

## Technology Stack
- **Frontend (`agrofarm-frontend`):** React 19, TypeScript, Vite, Vitest (deployed without mocks against `core-api-staging`).
- **Core API (`agrofarm-api`):** Python, FastAPI, PostgreSQL, SQLAlchemy, Alembic, OpenAPI v1, Schemathesis.
- **Analytics & ML (`agrofarm-analytic`):** Python data connectors (INSIVUMEH, NOAA CPC ONI/RONI, NASA POWER, CHIRPS, SoilGrids, Copernicus DEM, ESA WorldCover, Planetary Computer NDVI, Meteomatics) and `ml-service` (fixed-rule simulation, rotation rule engine `rules-0.1.1`, regional NDVI outlook, maize-leaf screening).
- **Documentation (`agrofarm-docs`):** Markdown ADRs, OpenAPI contracts, `DEC-005` upload schemas, agronomy sheets.

---

## Public Links & Incognito Verification Checklist (No Login Required)

Before submitting on the Space Apps portal, open an **incognito/private browser window** and verify every link loads without authentication:

- [x] `agrofarm-api` repository: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-api` (PUBLIC; answered HTTP 200 without login on 2026-11-15, still open it once in a private window)
- [x] `agrofarm-analytic` repository: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-analytic` (PUBLIC; answered HTTP 200 without login on 2026-11-15, still open it once in a private window)
- [x] `agrofarm-frontend` repository: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-frontend` (PUBLIC; answered HTTP 200 without login on 2026-11-15, still open it once in a private window)
- [x] `agrofarm-docs` repository: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-docs` (PUBLIC)
- [ ] Live app URL: `https://frontend-staging-7l2bzjrqpq-uc.a.run.app` (verify `"Try the demo"` in incognito without login)
- [ ] Demo video link (`<= 30s`): `TODO_PUBLIC_URL` (confirm `"Anyone with the link can view"`, no NASA logos, no minors)
- [ ] Presentation slides link (max 7 slides): `TODO_PUBLIC_URL` (confirm `"Anyone with the link can view"`, no NASA logos, no minors)

## Still to do by a human

1. Fill every `TODO_TEAM_CONFIRM` (ideas not AI-generated; AI media status) and the two remaining `TODO_PUBLIC_URL` (the demo video link and the slides link). The repository URLs are already filled in.
2. Produce slides (max 7) or a video (max 30 s) and share them with an open link ("Anyone with the link can view").
3. Each team member adds the AI tools they used to the `AI_USAGE.md` of each repository.
4. Click "Submit for Judging" on the Space Apps portal before 2026-11-15 23:59 (Guatemala time).
