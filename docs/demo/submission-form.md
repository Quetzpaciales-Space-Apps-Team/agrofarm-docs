# NASA Space Apps Challenge 2026 — Submission Form Copy (`DEMO-003`)

> All text below is in English and reflects only verified capabilities in the team repositories.

---

## Project Name
**AgroFarm: Climate-Aware Crop Rotation Decision Support**

## High-Level Project Summary (Short)
AgroFarm is a decision-support tool for smallholder farmers and local agronomists that compares at least three crop rotation strategies—always including the farmer's current rotation—by combining climate and ENSO indicators, local farm records, and farmer-defined priorities. Every recommendation transparently presents the rationale, supporting evidence, expected benefits, information gaps, and risks requiring local expert review.

## Detailed Project Description
Smallholder farmers in Guatemala face increasing rainfall variability and El Niño / La Niña (ENSO) extremes, yet most agricultural tools either hide assumptions in black-box scores or ignore the farmer's own water, equipment, and income constraints.

**AgroFarm** addresses this by putting the farmer and local agronomist in control:
1. **Farm & Priority Mapping:** Farmers define their parcel boundary in `EPSG:4326` GeoJSON and weight seven priorities (water use, income, soil structure, forage value, nitrogen fixing, erosion reduction, and market suitability) alongside water availability and equipment constraints.
2. **Validated Local Data Upload:** Farmers or extensionists upload CSV or GeoJSON parcel observations (`YYYY-MM-DD`, SI units: `mm/day`, `°C`, `%`, `km/h`, `MJ/m²/day`, missing values as `null`/`NaN`). Invalid rows return clear, row-level feedback.
3. **ENSO & Climate Scenario Simulation:** Users inspect historical/current ONI & RONI ENSO phases and simulate rainfall/temperature shifts to see projected yield anomaly ranges (`p10`/`p50`/`p90`) and feature attributions.
4. **Transparent Rotation Comparison:** AgroFarm evaluates at least three rotation strategies—always including the current baseline—returning per-priority scores, uncertainty bounds, `why`, `evidence`, `benefits`, `gaps`, `risks`, `needs_local_review`, and persisted provenance (`model_version`, `data_versions`, `input_hash`).

**Human-in-the-loop principle:** AgroFarm explicitly states on every recommendation that it supports decisions and does not replace farmers or local agronomists.

## NASA Data Used
- **Current Demo Reality (`DEMO_MODE=true` / `ML_MODE=fixture`):** In the live hackathon demo, `core-api` serves deterministic offline snapshots (`cached_demo`) and fixtures that carry `nasa_power` / `insivumeh_daily` / `enso_monthly` provenance metadata while the `agrofarm-analytic` `ml-service` HTTP endpoints (`docs/contract/ml-service-expected.yaml`) are wired in.
- **Cataloged NASA Earth Observation datasets (`docs/data/datasets.md`, planned pipeline):** NASA POWER (agroclimatology), SMAP L4 (soil moisture), MODIS (MOD13Q1, MOD11A2, MOD15A2H, MOD17A2H), HLS / Sentinel-2, GPM IMERG, ECOSTRESS, and NASADEM.

## Space Agency / Partner / Other Data & SI Units Used
- **NOAA Climate Prediction Center (CPC):** Oceanic Niño Index (ONI) and Relative Oceanic Niño Index (RONI) via the `agrofarm-analytic` ENSO connector (`enso.py`) and cached demo snapshots (`GET /v1/climate/enso`).
- **INSIVUMEH (Guatemala):** Local daily meteorological station connector (`insivumeh.py` in `agrofarm-analytic`, converting `-99.9` sentinels to `null`) and demo evidence snapshots.
- **User-Provided Farm Data:** Parcel boundaries (`EPSG:4326` GeoJSON) and field observations (CSV/GeoJSON) validated by `POST /v1/farms/{farm_id}/uploads`.
- **International System (SI) & Standard Units:** All inputs and API contracts enforce `mm/day` (rainfall), `°C` (temperature), `%` (humidity and yield anomaly), `km/h` (wind), `MJ/m²/day` (solar radiation), `YYYY-MM-DD` dates, and `null`/`NaN` for missing values.

## Technology Stack
- **Backend API (`agrofarm-api`):** Python, FastAPI, PostgreSQL, SQLAlchemy, Alembic, Pydantic, OpenAPI v1, Schemathesis.
- **Analytics & ML (`agrofarm-analytic`):** Python data connectors (NOAA CPC ONI/RONI, INSIVUMEH) and rainfall/scenario ML service.
- **Frontend (`agrofarm-frontend`):** React 19, TypeScript, Vite, Vitest.
- **Documentation & Governance (`agrofarm-docs`):** Markdown ADRs, OpenAPI contracts, data upload schemas (`DEC-005`).

---

## Public Links & Incognito Verification Checklist (No Login Required)

Before submitting on the Space Apps portal, open an **incognito/private browser window** and verify every link loads without authentication:

- [ ] `agrofarm-api` repository: `TODO_PUBLIC_URL` (confirm public visibility: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-api`)
- [ ] `agrofarm-analytic` repository: `TODO_PUBLIC_URL` (confirm public visibility: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-analytic`)
- [ ] `agrofarm-frontend` repository: `TODO_PUBLIC_URL` (confirm public visibility: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-frontend`)
- [ ] `agrofarm-docs` repository: `TODO_PUBLIC_URL` (confirm public visibility: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-docs`)
- [ ] Live app URL: `https://agrofarming.site` (confirm accessible without login or with demo credentials `demo@agrofarm.org` / `DemoPass2026!`)
- [ ] Demo video link (`<= 30s`): `TODO_PUBLIC_URL` (confirm "Anyone with the link can view", no NASA logos, no minors)
- [ ] Presentation slides link (max 7 slides): `TODO_PUBLIC_URL` (confirm "Anyone with the link can view", no NASA logos, no minors)
