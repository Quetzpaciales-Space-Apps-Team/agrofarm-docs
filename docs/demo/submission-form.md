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
- **NASA POWER (Agroclimatology):** Referenced in scenario and recommendation provenance metadata (`nasa_power`) and documented in the project dataset catalog (`docs/data/datasets.md`) for solar radiation, temperature, precipitation, humidity, and wind baselines.
- **Cataloged NASA Earth Observation datasets in `docs/data/datasets.md` (architecture & planned ingestion):** SMAP L4 (soil moisture), MODIS (MOD13Q1 NDVI/EVI, MOD11A2 LST, MOD15A2H LAI, MOD17A2H GPP), HLS / Sentinel-2, GPM IMERG, ECOSTRESS, and NASADEM. *(Note: in the current MVP build, `core-api` serves deterministic fixtures and cached offline demo snapshots for satellite-derived inputs while `agrofarm-analytic` connectors are being completed.)*

## Space Agency / Partner / Other Data Used
- **NOAA Climate Prediction Center (CPC):** Oceanic Niño Index (ONI) and Relative Oceanic Niño Index (RONI) via the `agrofarm-analytic` ENSO connector (`enso.py`) and `GET /v1/climate/enso`.
- **INSIVUMEH (Guatemala National Institute of Seismology, Volcanology, Meteorology, and Hydrology):** Local daily meteorological station data via the `agrofarm-analytic` INSIVUMEH connector (`insivumeh.py`) and demo evidence snapshots.
- **User-Provided Farm Data:** Parcel boundaries (GeoJSON) and field/climate observations (CSV/GeoJSON) uploaded through `POST /v1/farms/{farm_id}/uploads`.

## Technology Stack
- **Backend API (`agrofarm-api`):** Python, FastAPI, PostgreSQL, SQLAlchemy, Alembic, Pydantic, OpenAPI v1, Schemathesis.
- **Analytics & ML (`agrofarm-analytic`):** Python data connectors (NOAA CPC ONI/RONI, INSIVUMEH) and rainfall/scenario ML service.
- **Frontend (`agrofarm-frontend`):** React 19, TypeScript, Vite, Vitest.
- **Documentation & Governance (`agrofarm-docs`):** Markdown ADRs, OpenAPI contracts, data upload schemas (`DEC-005`).

---

## Public Links & Incognito Verification Checklist (No Login Required)

Before submitting on the Space Apps portal, open an **incognito/private browser window** and verify every link loads without authentication:

- [ ] `agrofarm-api` repository: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-api` (confirm public visibility)
- [ ] `agrofarm-analytic` repository: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-analytic` (confirm public visibility)
- [ ] `agrofarm-frontend` repository: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-frontend` (confirm public visibility)
- [ ] `agrofarm-docs` repository: `https://github.com/Quetzpaciales-Space-Apps-Team/agrofarm-docs` (confirm public visibility)
- [ ] Live demo URL / deployed app (if deployed): `<PENDING_DEPLOY_URL>` (confirm accessible without login or with clearly listed demo credentials `demo@agrofarm.org` / `DemoPass2026!`)
- [ ] Demo video / slide deck link: `<PENDING_DECK_OR_VIDEO_URL>` (confirm "Anyone with the link can view", max 7 slides or `<= 30s` video, no NASA logos, no minors)
