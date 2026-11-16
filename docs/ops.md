# Operations runbook

Every manual cloud or GitHub step is written here so it can be repeated. No secrets or sensitive account identifiers are hardcoded in this file or in workflow YAML files: secrets live in Google Secret Manager and encrypted GitHub Environment Secrets.

## 1. GCP project and Terraform foundation (OPS-001)

Infrastructure as Code lives in `agrofarm-api/infra/terraform` (see [ADR 0003](adr/0003-terraform-and-gcp-environment-layout.md)).

### 1.1 Fixed conventions

| Item | Value |
|---|---|
| Region | `us-central1` |
| Environments | `staging` (from `develop`) and `prod` (from `main`) in a dedicated GCP project |
| State bucket | `<project-id>-tfstate` (versioning enabled, uniform bucket-level access) |
| Artifact Registry | `us-central1-docker.pkg.dev/<project-id>/agrofarm/<service>:<git-sha>` |
| Services | `core-api`, `ml-service` (internal IAM-only), `data-service` (Cloud Run job), `frontend` |
| Cloud SQL | PostgreSQL 16 (`agrofarm-pg-staging`, `agrofarm-pg-prod`, `ENTERPRISE` edition), extensions `pg_trgm` and `unaccent` |
| Storage buckets | `<project-id>-raw-<env>`, `<project-id>-clean-<env>`, `<project-id>-models-<env>`, `<project-id>-uploads-<env>` |

### 1.2 Bootstrap and apply steps

1. Authenticate locally with Google Cloud SDK:
   ```bash
   gcloud auth login
   export GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)"
   ```
2. Run the one-time idempotent bootstrap script from `agrofarm-api`:
   ```bash
   GCP_PROJECT_ID="<project-id>" ./infra/bootstrap.sh
   ```
   This enables `storage.googleapis.com`, `cloudresourcemanager.googleapis.com`, `iam.googleapis.com`, `serviceusage.googleapis.com`, `cloudbilling.googleapis.com` and creates the versioned GCS state bucket `<project-id>-tfstate`.
3. Initialize and apply the `staging` environment:
   ```bash
   cd infra/terraform
   terraform init -backend-config="bucket=<project-id>-tfstate" -backend-config="prefix=agrofarm/staging"
   terraform apply -var-file="envs/staging.tfvars" -var="project_id=<project-id>"
   ```
4. Initialize and apply the `prod` environment:
   ```bash
   terraform init -reconfigure -backend-config="bucket=<project-id>-tfstate" -backend-config="prefix=agrofarm/prod"
   terraform apply -var-file="envs/prod.tfvars" -var="project_id=<project-id>"
   ```

### 1.3 Service accounts, Workload Identity Federation, and GitHub Environment Secrets

Terraform creates dedicated least-privilege service accounts per environment:
- `sa-core-api-<env>`: Cloud SQL client, read access to `clean` bucket, read/write to `uploads` bucket, secret accessor for DB and JWT secrets, `roles/run.invoker` on `ml-service-<env>`.
- `sa-ml-service-<env>`: read-only access to `clean` and `models` buckets.
- `sa-data-service-<env>`: read/write access to `raw` and `clean` buckets, secret accessor for external data API credentials.
- `sa-frontend-<env>`: minimal runtime account with no data bucket or database access.
- `sa-ci-deployer-<env>`: used by GitHub Actions through Workload Identity Federation (`github-pool-<env>` / `github-provider-<env>`), restricted to `assertion.repository_owner == "Quetzpaciales-Space-Apps-Team"`. No JSON keys exist.

To avoid hardcoding project IDs, project numbers, or service account emails in `.github/workflows/cd.yml`, each deployment repository (`agrofarm-api`, `agrofarm-analytic`, `agrofarm-frontend`) defines two GitHub Environments (`staging` and `production`, with manual review on `production`) holding encrypted Environment Secrets:
- `GCP_PROJECT_ID`
- `GCP_REGION`
- `GAR_REPOSITORY`
- `GCP_WIF_PROVIDER`
- `GCP_SA_CI_DEPLOYER`

## 2. Domains, CORS and cookies (OPS-002)

### 2.1 Registrable domain and environment URLs

The frontend and API share the registrable domain `agrofarming.site` so refresh token cookies work across subdomains without third-party cookie blocking:

| Environment | Frontend Origin | Core API Origin | ML Service Origin |
|---|---|---|---|
| Local development | `http://localhost:5173` | `http://localhost:8080` | `http://localhost:8081` |
| Staging (`develop`) | `https://staging.agrofarming.site` (plus Cloud Run `frontend-staging` URL) | `https://api-staging.agrofarming.site` (plus Cloud Run `core-api-staging` URL) | Cloud Run `ml-service-staging` URL (internal IAM-only) |
| Production (`main`) | `https://agrofarming.site` | `https://api.agrofarming.site` | Cloud Run `ml-service-prod` URL (internal IAM-only) |

### 2.2 CORS allowlist per environment

Wildcard `*` is rejected by `core-api` startup validation (`Settings._no_wildcard_origin`). Explicit allowlists configured via `CORS_ORIGINS`:
- **Staging:** `https://agrofarming.site,https://staging.agrofarming.site,<frontend-staging-cloud-run-url>,http://localhost:5173`
- **Production:** `https://agrofarming.site`

### 2.3 Refresh token cookie attributes

- `HttpOnly`: `true` (never readable by `document.cookie` or JavaScript)
- `Secure`: `true` in `staging` and `prod` (HTTPS-only)
- `SameSite`: `Lax` (supported because frontend and API share the registrable domain `agrofarming.site`)
- `Path`: `/v1/auth`

## 3. External accounts and Secret Manager (OPS-003)

Terraform provisions the Secret Manager secret containers with initial placeholder versions (`lifecycle { ignore_changes = [secret_data] }`); real external provider credentials are added out-of-band so credentials never touch git or Terraform variables:

```bash
printf "%s" "<token>" | gcloud secrets versions add earthdata-token-staging --data-file=-
printf "%s" "<user:pass>" | gcloud secrets versions add meteomatics-credentials-staging --data-file=-
printf "%s" "<key>" | gcloud secrets versions add cds-api-key-staging --data-file=-
```

Required external accounts:
1. NASA Earthdata (AppEEARS / SMAP / MODIS / VIIRS)
2. Meteomatics (1,000 queries/day budget, cached)
3. Copernicus Climate Data Store (ERA5-Land)
4. ICC / Rio Contreras rainfall permission (see DEC-008)

## 4. GitHub settings (OPS-004)

- Default branch: `develop` in all four repositories.
- Long-lived branches: `develop` (staging) and `main` (production).
- Required check: `ci-gate`, plus branch flow enforcement via the `policy` job in `.github/workflows/ci.yml` (rejects PRs into `main` unless they come from `develop` or `hotfix/*`, and enforces branch naming prefixes).
- Automated configuration script: `agrofarm-api/infra/github-protect.sh` applies branch protection on `develop` and `main` across all four repositories via `gh api` (pull request required, `ci-gate` status check required, force pushes and deletion blocked).

## 5. Deploy and rollback

- **Staging (`develop`):** Every merge into `develop` triggers `.github/workflows/cd.yml`, builds the Docker image tagged with the commit SHA, pushes it to Artifact Registry, runs database migrations via the `core-api-migrate-staging` Cloud Run job (for `agrofarm-api`), deploys the new Cloud Run revision, and masks the service URL while running `/healthz` smoke checks.
- **Production (`main`):** Merging a release PR from `develop` into `main` uses the `production` GitHub environment, runs `core-api-migrate-prod`, and promotes the commit SHA image to `*-prod`.
- **Rollback:** Shift Cloud Run traffic back to the previous known-good revision (see `deploy/rollback.md` in each repository):
  ```bash
  gcloud run services update-traffic <service>-<env> \
    --region=us-central1 \
    --to-revisions=<previous-revision>=100
  ```

## 6. CI/CD and branches

Verified on 2026-11-15 and 2026-11-16 with `gh`:

- **Failed runs while private.** On 2026-11-16 02:10 UTC the `ci` and CD workflows of `agrofarm-api` and `agrofarm-analytic` failed with GitHub's annotation "The job was not started because recent account payments have failed or your spending limit needs to be increased". No job ran. The repositories were private at that time. After they became public, the runs were re-run and passed: staging deployed and production was skipped.
- **Branches.** Only `main` and `develop` exist in all four repositories. Feature branches were deleted on 2026-11-15 after their pull requests merged. (Open `docs/final-update` pull request branches are the exception while they wait for review.)
- **Production deploys.** A push to `main` in `agrofarm-frontend`, `agrofarm-api` and `agrofarm-analytic` deploys to production Cloud Run without required reviewers. Production had never been deployed before 2026-11-16. This differs from the manual approval described in section 5 and in rule G3. `main` of the four repositories is synced from `develop` by a pull request at the end of 2026-11-15. The result of that sync is not confirmed in this document.
- **Pending, needs GCP access, not done:**
  1. `terraform apply` for `ml_min_instances=1` on staging.
  2. Upload of the model artifacts to the staging `models` bucket.
  3. Earthdata credentials in Secret Manager (section 3).
- **Not confirmed:** the state of `agrofarming.site` (see [`demo/PROGRESS.md`](demo/PROGRESS.md)) and any GitHub spending-limit or billing change.
