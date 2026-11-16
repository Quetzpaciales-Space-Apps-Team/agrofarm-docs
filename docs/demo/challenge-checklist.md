# Challenge Requirements & Demo Verification Checklist (`DEMO-001`)

## 1. Challenge Requirements Traceability Matrix

| Challenge Requirement | Satisfying Endpoint / Artifact / Screen | Verification Status |
|---|---|---|
| Decision-support framing (supports, does not replace farmer/expert) | `POST /v1/farms/{farm_id}/recommendations` returns `disclaimer` + `needs_local_review`; visible across frontend views | Implemented & live in staging |
| Compare at least 3 crop rotation strategies (including current) | `POST /v1/farms/{farm_id}/recommendations` returns 4 strategies (`>= 3`, `is_current: true`) via `agrofarm-rotation-rule-engine` (`rules-0.1.1`) | Implemented & live in staging |
| Each recommendation includes why, evidence, benefits, gaps, risks, uncertainty, priority scores | `POST /v1/farms/{farm_id}/recommendations` schema & frontend comparison cards/drawer | Implemented & live in staging |
| Uses climate + local farm data + farmer priorities | `GET /v1/climate/enso`, `PUT /v1/farms/{farm_id}/priorities`, `POST /v1/farms/{farm_id}/uploads`, NOAA ENSO & INSIVUMEH | Implemented & live in staging |
| Uses NASA data in a visible app feature | `GET /v1/climate/nasa-power` (1995–2025 monthly series at `14.59, -90.53`) charted in frontend + MODIS NDVI regional outlook (`vegetation/simulate`) | Implemented & live in staging |
| Farm data upload (CSV/GeoJSON) with column, unit, date, CRS validation | `POST /v1/farms/{farm_id}/uploads` following `docs/data/farm-upload-schema.md` (`DEC-005`) | Implemented & live in staging |
| OpenAPI documentation | `agrofarm-api/docs/contract/openapi.yaml` + FastAPI `/docs` and `/openapi.json` | Implemented & Schemathesis-verified |
| Passwordless public judge demo | `"Try the demo"` -> `POST /v1/auth/demo` (`https://frontend-staging-7l2bzjrqpq-uc.a.run.app`; `https://agrofarming.site` also answered HTTP 200 on 2026-11-15, not confirmed as stable) | Implemented & live in staging |
| Presentation in English, max 7 slides, no NASA logos, no minors | `docs/demo/presentation.md` (7 slides) + `docs/demo/video-script.md` (30s script) | Ready in `agrofarm-docs` |
| Submission form copy in English & public links without login | `docs/demo/submission-form.md` (`DEMO-003`) | Draft updated; all four repositories are PUBLIC; video/slides URLs and `TODO_*` placeholders pending (human) |

---

## 2. Final Submission Delivery Checklist (Before `23:59` Local Time)

- [x] **Public Repositories (`G12`):** all four repositories (`agrofarm-api`, `agrofarm-analytic`, `agrofarm-frontend`, `agrofarm-docs`) are `PUBLIC` (checked with `gh repo view` on 2026-11-15).
- [ ] **Incognito Link Check:** Open `https://frontend-staging-7l2bzjrqpq-uc.a.run.app`, all 4 GitHub repos, video link, and slides link in an **incognito/private browser window** and confirm zero login/permission prompts. Add `https://agrofarming.site` only if the team confirms it.
- [ ] **Full No-Login Demo Walkthrough (`DEMO-002`, issue `agrofarm-docs#18`, still open):** Complete `"Try the demo"` -> farm & priorities -> CSV/GeoJSON upload -> ENSO & NASA POWER -> simulate -> `>= 3` rotation strategies -> confirm `disclaimer` is visible.
- [ ] **Media Compliance:** Video `<= 30s` and/or slides `<= 7` uploaded with `"Anyone with the link can view"`, no NASA logos/branding, no images of minors (`< 18`), and AI watermarks if any media was AI-generated.
- [ ] **Submission Form:** All fields in English, `TODO_TEAM_CONFIRM` and `TODO_PUBLIC_URL` resolved, submitted on the Space Apps portal before `23:59` local time.

---

## Still to do by a human

1. Fill the placeholders `TODO_TEAM_CONFIRM` and `TODO_PUBLIC_URL` in `docs/demo/submission-form.md`.
2. Produce slides (max 7) or a video (max 30 s) and share them with an open link.
3. Each team member adds the AI tools they used to the `AI_USAGE.md` of each repository.
4. Run the incognito walkthrough and close `agrofarm-docs#18`.
5. Click "Submit for Judging" before 23:59 (Guatemala time) on 2026-11-15.

---

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
