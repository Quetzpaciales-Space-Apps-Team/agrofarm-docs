# Challenge Requirements & Demo Verification Checklist (`DEMO-001`)

## 1. Challenge Requirements Traceability Matrix

| Challenge Requirement | Satisfying Endpoint / Artifact / Screen | Verification Status |
|---|---|---|
| Decision-support framing (supports, does not replace farmer/expert) | `POST /v1/farms/{farm_id}/recommendations` returns `disclaimer` + `needs_local_review`; `presentation.md` Slides 1 & 4 | Implemented & tested in `core-api` |
| Compare at least 3 crop rotation strategies (including current) | `POST /v1/farms/{farm_id}/recommendations` enforces `len(strategies) >= 3` and `any(s.is_current)` in `core_api.domain.recommendations` | Implemented & tested in `core-api` |
| Each recommendation includes why, evidence, benefits, gaps, risks, uncertainty, priority scores | `POST /v1/farms/{farm_id}/recommendations` schema & `map_and_validate_recommendations` | Implemented & tested in `core-api` |
| Uses NASA/climate + local farm data + farmer priorities | `GET /v1/climate/enso`, `PUT /v1/farms/{farm_id}/priorities`, `POST /v1/farms/{farm_id}/uploads`, `agrofarm-analytic` connectors (NOAA ENSO, INSIVUMEH) | Implemented (API + connectors) |
| Farm data upload (CSV/GeoJSON) with column, unit, date, CRS validation | `POST /v1/farms/{farm_id}/uploads` following `docs/data/farm-upload-schema.md` (`DEC-005`) | Implemented & tested in `core-api` |
| OpenAPI documentation | `agrofarm-api/docs/contract/openapi.yaml` + FastAPI `/docs` and `/openapi.json` | Implemented & Schemathesis-verified |
| Offline demo resilience (works without internet) | `DEMO_MODE=true` (`DemoMLClient` + `demo_snapshots/*.json`) + `make seed-demo` | Implemented & tested in `core-api` |
| Presentation in English, max 7 slides, no NASA logos, no minors | `docs/demo/presentation.md` (7 slides + 30s script; `.pptx` export optional if PowerPoint/Slides needed) | Ready in `agrofarm-docs` |
| Submission form copy in English & public links without login | `docs/demo/submission-form.md` (`DEMO-003`) | Ready in `agrofarm-docs` |

## 2. Demo Script Coverage Check
- [x] Register / Login (`POST /v1/auth/register`, `POST /v1/auth/login`, or seeded `demo@agrofarm.org` / `REMOVED-DEMO-PASSWORD`)
- [x] Draw / Create Farm (`POST /v1/farms` with `EPSG:4326` GeoJSON Polygon)
- [x] Upload Data (`POST /v1/farms/{farm_id}/uploads` using `docs/data/examples/farm-upload-template.csv` or `farm-upload-example.geojson`)
- [x] Run an ENSO Scenario (`GET /v1/climate/enso` + `POST /v1/scenarios/simulate`)
- [x] Compare 3+ Rotations (`POST /v1/farms/{farm_id}/recommendations`)
- [ ] Frontend live screen capture / URL (`FE-505` — pending `agrofarm-frontend#36`)

## 3. Offline Demo Runbook (Zero Internet Required)
From `agrofarm-api/`:
```bash
docker compose up -d --wait db
export DATABASE_URL=postgresql+psycopg://agrofarm:local-dev-only@localhost:5432/agrofarm
uv run alembic upgrade head
uv run python -m core_api.seed_demo
DEMO_MODE=true uv run uvicorn core_api.main:create_app --factory --port 8080
```
*(If port 5432 is busy locally, pass `DB_PORT=5433` and update `DATABASE_URL` port to `5433`.)*

Note on `.pptx`: `libreoffice` is available locally, while `pandoc`/`python-pptx` are not installed; `docs/demo/presentation.md` contains the complete 7-slide deck and speaker script ready to paste into Google Slides / PowerPoint or export to PDF.
