# NASA Space Apps Challenge 2026 — Submission Form Copy (`DEMO-003`)

> All text below is in English and reflects only verified capabilities in the team repositories.

---

## Project Name
**AgroFarm: Climate-Aware Crop Rotation Decision Support**

## High-Level Project Summary (Short)
AgroFarm is a decision-support prototype for smallholder farmers and local agronomists. It displays historical NASA POWER and ENSO indicators and compares at least three crop rotation strategies, including the farm's current rotation, using declared rules and farmer-defined priorities. Every recommendation presents the rationale, supporting evidence, expected benefits, information gaps, and risks requiring local expert review. Uploaded farm observations are validated and stored but do not yet change the results.

## Detailed Project Description
Smallholder farmers in Guatemala face increasing rainfall variability and El Niño / La Niña (ENSO) extremes, yet most agricultural tools either hide assumptions in black-box scores or ignore the farmer's own water, equipment, and income constraints.

**AgroFarm** addresses this by putting the farmer and local agronomist in control:
1. **Example Farm and Farmer Priorities:** The guest demo starts with an example farm. The API supports parcel boundaries in `EPSG:4326` GeoJSON and seven priority weights (water use, income, soil structure, forage value, nitrogen fixing, erosion reduction, and market suitability), plus water and equipment settings. The app does not yet have an interactive map for drawing a real parcel. The pilot reference geometry is a bounding box around the INSIVUMEH station, not a surveyed farm boundary. API support for a setting does not establish that every rule uses it.
2. **Validated Local Data Upload through the API:** The API accepts CSV or GeoJSON farm observations and returns row-level validation errors. Valid observations are stored. Uploads do not yet feed the simulation or change recommendations; this is a data collection capability, not farm-specific calibration. Browser upload and priority controls must be checked against the deployed frontend before they are described as available in the app.
3. **ENSO & Climate Scenario Simulation:** Users inspect historical ONI & RONI ENSO phases and move rainfall, temperature and ENSO controls to see an illustrative range (`p10`/`p50`/`p90`) of yield anomaly with the contribution of each input. The range comes from declared fixed rules, not from a trained model, and the response says so.
4. **Transparent Rotation Comparison:** AgroFarm evaluates at least three rotation strategies—always including the current baseline—returning per-priority scores, uncertainty bounds, `why`, `evidence`, `benefits`, `gaps`, `risks`, `needs_local_review`, and persisted provenance (`model_version`, `data_versions`, `input_hash`).

**Human-in-the-loop principle:** AgroFarm explicitly states on every recommendation that it supports decisions and does not replace farmers or local agronomists.

## Use of Super Intelligence (SI)

> "SI" in the Space Apps form means AI tools, not SI units. Draft: every team member must confirm/add the tools they used before submission.

Yes. AI tools were used to accelerate implementation and documentation; `TODO_TEAM_CONFIRM`: confirm that project ideas were not AI-generated. SI usage is disclosed in project text, repository metadata, and pull requests.

- **Code:** AI coding assistants (Claude Code, OpenAI Codex, Antigravity) assisted with backend/frontend scaffolding, tests, CI workflows, and OpenAPI contracts. Team members should confirm their individual tools before submission.
- **Documentation:** AI assistants helped draft or refine the project plan, dataset catalog, repository rules, and demo/submission materials (reviewed by team members).
- **Machine learning inside the product:** the active `/v1/simulate` and `/v1/rotations/score` endpoints run declared fixed rules and a rule engine over a provisional crop traits table, not a trained model; do not describe outputs as validated ML predictions. One model was trained as an experiment (seasonal peak NDVI on cropland from MODIS, LightGBM). It missed the skill rule set before training (error 4.4 % lower than climatology, 5 % needed) and is reported only as an annex result, not used by the app: see [the annex](../model/ndvi-experimental-result.md).
- **Images, video and audio:** `TODO_TEAM_CONFIRM`: state "none generated with AI", or list any generated assets and add a visible watermark.

## NASA Data Used
- **NASA POWER (agroclimatology), shown in the app:** monthly rainfall and mean, minimum and maximum temperature for the reference point (INSIVUMEH station, 14.59, -90.53), 1995 to 2025, served by `GET /v1/climate/nasa-power` and charted in the climate panel with its source, attribution and a note that it is a reanalysis grid cell of about 50 km, not a station. The values are a stored snapshot, not a live call. The `agrofarm-analytic` connector can also fetch point and regional series from the POWER API.
- **NASA MODIS MOD13Q1 NDVI (Terra), used in an experiment only:** the seasonal peak NDVI on cropland, 2000 to 2024, is the label of an experimental model reported as an annex ([annex](../model/ndvi-experimental-result.md)). It did not pass the skill rule and the app does not use it.
- **Other cataloged NASA Earth Observation datasets (`docs/data/datasets.md`, planned pipeline):** SMAP L4 (soil moisture), MOD11A2, MOD15A2H, MOD17A2H, HLS, GPM IMERG, ECOSTRESS and NASADEM. They are not integrated into the demo.
- **Demo mode:** the public demo serves the NASA POWER and ENSO series from stored snapshots. The intended live simulation and rotation path uses declared fixed rules. If that service is unavailable, the API can return saved example answers labeled `cached_demo` in provenance. Those answers do not change with the scenario. A staging API check on 2026-11-15 still returned that fallback; verify that scenario changes affect the results before presenting the demo as interactive.

## Space Agency / Partner / Other Data & SI Units Used
- **NOAA Climate Prediction Center (CPC):** Oceanic Niño Index (ONI) and Relative Oceanic Niño Index (RONI) via the `agrofarm-analytic` ENSO connector (`enso.py`) and cached demo snapshots (`GET /v1/climate/enso`).
- **INSIVUMEH (Guatemala):** Local daily meteorological station connector (`insivumeh.py` in `agrofarm-analytic`, converting `-99.9` sentinels to `null`) and demo evidence snapshots.
- **User-Provided Farm Data:** Parcel boundaries (`EPSG:4326` GeoJSON) and field observations (CSV/GeoJSON) validated by `POST /v1/farms/{farm_id}/uploads`.
- **International System (SI) & Standard Units:** All inputs and API contracts enforce `mm/day` (rainfall), `°C` (temperature), `%` (humidity and yield anomaly), `km/h` (wind), `MJ/m²/day` (solar radiation), `YYYY-MM-DD` dates, and `null`/`NaN` for missing values.

## Technology Stack
- **Backend API (`agrofarm-api`):** Python, FastAPI, PostgreSQL, SQLAlchemy, Alembic, Pydantic, OpenAPI v1, Schemathesis.
- **Analytics & ML (`agrofarm-analytic`):** Python data connectors (INSIVUMEH, NOAA CPC ONI/RONI, NASA POWER, CHIRPS, SoilGrids, Copernicus DEM, ESA WorldCover, Planetary Computer NDVI, Meteomatics forecast) and an ML service with a fixed-rule simulation and a rotation rule engine over a provisional crop traits table.
- **Frontend (`agrofarm-frontend`):** React 19, TypeScript, Vite, Vitest.
- **Documentation & Governance (`agrofarm-docs`):** Markdown ADRs, OpenAPI contracts, data upload schemas (`DEC-005`).

---

## Public Links & Incognito Verification Checklist (No Login Required)

Before submitting on the Space Apps portal, open an **incognito/private browser window** and verify every link loads without authentication:

- [ ] `agrofarm-api` repository: `TODO_PUBLIC_URL` (confirm public visibility: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-api`)
- [ ] `agrofarm-analytic` repository: `TODO_PUBLIC_URL` (confirm public visibility: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-analytic`)
- [ ] `agrofarm-frontend` repository: `TODO_PUBLIC_URL` (confirm public visibility: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-frontend`)
- [ ] `agrofarm-docs` repository: `TODO_PUBLIC_URL` (confirm public visibility: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-docs`)
- [ ] Live app URL (provisional staging): `https://frontend-staging-7l2bzjrqpq-uc.a.run.app` (custom domain `https://agrofarming.site` is `DNS pending`; confirm the public demo opens without login and never share credentials)
- [ ] Demo video link (`<= 30s`): `TODO_PUBLIC_URL` (confirm "Anyone with the link can view", no NASA logos, no minors)
- [ ] Presentation slides link (max 7 slides): `TODO_PUBLIC_URL` (confirm "Anyone with the link can view", no NASA logos, no minors)
