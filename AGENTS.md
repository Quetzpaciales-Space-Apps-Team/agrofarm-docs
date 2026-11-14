# AGENTS.md: Working Rules for `agrofarm-docs`

**Everything in this repository is written in English. This is the highest priority rule and it overrides any other instruction.** See rule G1.

This repository holds the shared documentation of the AgroFarm project: the team plan, the dataset catalog, architecture decisions, the operations runbook, and the decisions and non-code tasks tracked as issues.

---

## 0. Product context

We are building a simulator that predicts how crops will grow under given weather, soil and global climate conditions (for example El Nino and La Nina), and recommends crop rotation actions after a farmer uploads data about a specific farm. It compares at least three rotation strategies, including the current one. The tool **supports** decisions. It never replaces farmers or local agronomists.

---

# PART A: Global rules (identical in every repository)

The canonical copy of Part A lives in `agrofarm-docs/AGENTS.md`. Change it there first, then copy the same text to the other three repositories the same day.

## G1. Language: English first

- All code identifiers, comments, commit messages, branch names, PR titles and descriptions, issues, documentation, API fields, dataset and column names, log messages, error messages and **UI copy** are in English.
- Spanish exists only as an i18n catalog in `agrofarm-frontend`, added in the final phase. It never appears in source code, tests, commits or docs.
- Team source documents written in Spanish stay outside the repositories. Their English versions live in `agrofarm-docs`.
- Chatting with humans in Spanish is fine. Nothing produced in a repo is in Spanish.

## G2. Test-driven development (mandatory)

1. **Red:** write a failing test for the behavior. Run it. Confirm it fails for the right reason.
2. **Green:** write the smallest code that makes it pass.
3. **Refactor:** clean up with all tests green.

- Bug fix: first write a regression test that reproduces the bug.
- Prefer separate commits: `test: ...` first, then `feat: ...` or `fix: ...`.
- Never delete, skip or weaken a test to make a change pass. If a test is wrong, explain why in the PR.
- CI enforces at least 80% line coverage on changed code.

## G3. CI/CD (mandatory)

- GitHub Actions. Every pull request runs: lint, type check, unit tests, integration tests, Docker image build, vulnerability scan.
- **A pull request merges only when every check is green.** The single required status check is the job named `ci-gate`. It depends on every other job and fails if any of them failed or was cancelled. Keep that job name stable. New jobs are added to its `needs` list.
- `develop` and `main` are always green and always deployable.
- Merge to `develop` deploys to **staging** automatically. Merge to `main` deploys to **production** after a manual approval.
- No manual deploys. The pipeline is code in the repo. Rollback means redeploying the previous image tag.
- Authenticate to GCP from CI with Workload Identity Federation. Never store service account JSON keys.

### G3.1 Test scope: full suite first, touched modules when it gets slow

- Default: every pull request runs the **full** test suite of the repo.
- When the pull request pipeline gets too slow (median above 10 minutes over the last 20 runs), switch pull requests to **affected-only** mode: run only the tests of the modules the change touches.
  - Detect touched modules with path filters in the workflow.
  - Inside a module, select tests by changed files (for example `vitest --changed origin/develop`, or one pytest path per package).
- Safeguards that always apply in affected-only mode:
  1. A change to shared files runs everything: lockfiles, CI workflows, Dockerfiles, root configuration, the OpenAPI contract, database migrations, shared test setup.
  2. The full suite always runs on every push to `develop`, on every release pull request into `main`, and nightly.
  3. `ci-gate` treats a skipped job as passed and a failed or cancelled job as failed, so path filters never block or bypass the required check.
- Turning on affected-only mode is its own pull request and states the measured timings.
- Slow tests are never fixed by deleting, skipping or weakening tests (rule G2).

## G4. Docker (mandatory)

- Every repo that ships a service has a multi-stage `Dockerfile` (pinned base image versions, non-root user, healthcheck) and a `docker-compose.yml` for local development.
- `docker compose up` must give a working local environment.
- Configuration comes from environment variables. Commit `.env.example`. Never commit `.env`.
- Standard Makefile targets in every repo: `make dev`, `make test`, `make lint`, `make typecheck`, `make build`, `make check` (lint + typecheck + test).

## G5. Microservices

Four repositories. Every service is deployable alone.

| Repo | Service(s) | Responsibility |
|---|---|---|
| `agrofarm-frontend` | `frontend` | React + Vite single page app (maps, simulation UI) |
| `agrofarm-api` | `core-api` | Public REST API: auth, farms, uploads, search, orchestration. Owns PostgreSQL. |
| `agrofarm-analytic` | `ml-service` | Internal service: crop simulation model, uncertainty, rotation scoring |
| `agrofarm-analytic` | `data-service` | Data pipelines: ingestion, cleaning, harmonization of weather, soil and satellite data |
| `agrofarm-docs` | none | Team plan, dataset catalog, ADRs, operations runbook, decisions and non-code tasks |

- Services talk only through HTTP contracts defined in OpenAPI. No shared code between services, including the two services inside `agrofarm-analytic`.
- No reaching into another service's storage. The one published data contract is the `clean/` datasets that `data-service` writes with a manifest: other services read them read-only, by manifest version.
- Only `core-api` talks to PostgreSQL.
- Contract first: change the OpenAPI file, then tests, then code.

## G6. Cloud: GCP

Cloud Run (services and jobs), Cloud SQL for PostgreSQL, Artifact Registry, Secret Manager, Cloud Storage. Document every manual cloud step in `docs/ops.md` of `agrofarm-docs`.

## G7. Security baseline

- No secrets in git, logs, tests or screenshots. Use Secret Manager and env vars.
- Validate all input at the boundary. Never trust the client.
- Least privilege for every credential and service account.
- Dependencies are pinned by lockfile and scanned in CI.

## G8. Git workflow

- Two long-lived branches: `develop` (integration, default branch, deploys to staging) and `main` (production releases).
- Work happens on short-lived branches cut from `develop`: `feat/<task-id>-<slug>`, `fix/...`, `chore/...`, `docs/...`, `test/...`, `refactor/...`, `ci/...`.
- **Every change reaches `develop` through a pull request. Pull requests from work branches target `develop` only, never `main`.**
- `main` only receives release pull requests from `develop`. An urgent production fix uses a `hotfix/...` branch cut from `main`, with a pull request into `main` and a second one back into `develop`.
- No direct pushes and no force pushes to `develop` or `main`.
- Conventional Commits. Squash merge into `develop`. Release pull requests into `main` use a merge commit so the two branches do not diverge.
- Small pull requests (aim for under 400 changed lines).
- A human reviews and merges. **Agents never push to `develop` or `main` and never merge their own PR.**

## G9. Rules for agents

1. Read this file and the README first.
2. Take only issues labeled `agent-ready`. Issues labeled `needs-human` are decisions or account work for people.
3. One task per branch and per PR. Stay inside the scope of the task. The PR targets `develop` and says `Closes #<issue>`.
4. Ambiguous requirement: ask. Do not guess silently.
5. No new dependency without a one-line justification in the PR description.
6. Run `make check` before saying the work is done.
7. Never run destructive commands (force push, dropping databases, deleting outside the workspace).
8. Update docs and the OpenAPI file together with the code.
9. In the final message report: what was done, what was not done, what you could not verify.

## G10. Domain safety

Recommendations are decision support. Every recommendation, in the API and in the UI, must carry reasons, evidence, data gaps, risks and uncertainty. Never present model output as certain. Never remove the disclaimer.

---

# PART B: Rules for this repository

## 1. What lives here

```
docs/
  plan/project-plan.md   team plan: pipeline, roles, phases, checkpoints, handoffs, risks, open decisions
  data/datasets.md       dataset catalog: what each source gives, resolution, period, access, limits
  adr/                   cross-service architecture decisions (one file per decision)
  ops.md                 operations runbook: every manual cloud step, domains, accounts, branch settings
  agronomy/              pilot crops, rotation strategies, strategy sheets, app copy and glossary
  demo/                  demo script, requirements checklist, rehearsal notes
```

- Service-specific documentation stays in the service repository. This repo holds what more than one service needs.
- No secrets, no credentials, no personal data. Account names go in `docs/ops.md`, secrets go in Secret Manager.
- No raw datasets in git. Link to the bucket and the manifest.

## 2. Writing rules

- English, plain language, short sentences. Always give units.
- Say what is verified and what is assumed. Mark unverified facts as unverified.
- One topic per pull request. A decision is recorded as an ADR, never only in chat.
- ADR file name: `docs/adr/NNNN-short-title.md`, using `docs/adr/0000-template.md`. Status is one of `proposed`, `accepted`, `rejected`, `superseded`.
- Part A of this file is the canonical copy of the global rules. A change to Part A is one pull request here, followed the same day by a sync pull request in each of the other three repositories.

## 3. Checks

- The `policy` and `ci-gate` jobs run on every pull request. Add a Markdown lint and a link check job to the `needs` list of `ci-gate` when the first documents land.
- This repo ships no service, so rule G4 (Docker) does not apply here.

---

# PART D: Phased plan and tasks

Each task is a GitHub issue with the same ID in its title. The full acceptance criteria live in the issue. `core` tasks are inside the cut line (minimum for the demo). `stretch` tasks come after it.

## Phase 0: Kickoff

- [ ] **DEC-001** Set the hackathon delivery date and demo time. *(core, needs-human)*
- [ ] **DEC-002** Confirm the pilot region and how US-only challenge datasets are handled. *(core, needs-human)*
- [ ] **DEC-003** Define the pilot farm polygon, the training area and the crops grown today. *(core, needs-human)*
- [ ] **DEC-004** Decide what "controlled environment" means: scenario simulation or greenhouse. *(core, needs-human)*
- [ ] **DEC-007** Fill the team roster: names and GitHub users per role, update CODEOWNERS. *(core, needs-human)*
- [ ] **OPS-001** GCP foundation: project, region, APIs, Artifact Registry, Cloud SQL, buckets, service accounts, Workload Identity Federation. *(core, needs-human)*
- [ ] **OPS-004** Protect `develop` and `main`: pull request required, `ci-gate` required, no force push. *(core, needs-human)*
- [ ] **AGR-001** Choose 3 to 5 pilot crops and at least three rotation strategies, including the current one. *(core, needs-human)*

## Phase 1: Data

- [ ] **DEC-005** Define the farm upload schema (fields, units, required columns). *(core, needs-human)*
- [ ] **DEC-006** Find a local agronomist or farmer who will review the recommendations. *(core, needs-human)*
- [ ] **DEC-008** Confirm permission to use the Rio Contreras rainfall data. *(core, needs-human)*
- [ ] **OPS-002** Choose the domains for the frontend and the API (same registrable domain) and the CORS allowlist. *(core, needs-human)*
- [ ] **OPS-003** Create the external data accounts and store their credentials in Secret Manager. *(core, needs-human)*

## Phase 3: Integration

- [ ] **AGR-002** Write one strategy sheet per rotation: why, evidence, benefits, gaps, risks for local review. *(core, needs-human)*
- [ ] **AGR-003** Write the plain-language app copy, the glossary and the disclaimer (English). *(core, needs-human)*

## Phase 4: Polish and demo

- [ ] **AGR-004** Get the strategy sheets reviewed by a local agronomist or farmer. *(stretch, needs-human)*
- [ ] **DEMO-001** Demo script, presentation and challenge requirements checklist. *(core, needs-human)*
- [ ] **DEMO-002** Full demo rehearsal without errors. *(core, needs-human)*
