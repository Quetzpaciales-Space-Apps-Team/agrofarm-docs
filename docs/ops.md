# Operations runbook

Every manual cloud or GitHub step is written here so it can be repeated. No secrets in this file: secrets live in Secret Manager.

## 1. GCP project and Terraform foundation (OPS-001)

Infrastructure as Code lives in `agrofarm-api/infra/terraform` (see [ADR 0003](adr/0003-terraform-and-gcp-environment-layout.md)).

### 1.1 Fixed conventions

| Item | Value |
|---|---|
| Region | `us-central1` |
| Environments | `staging` (from `develop`) and `prod` (from `main`) in a single GCP project |
| State bucket | `<project-id>-tfstate` (versioning enabled, uniform bucket-level access) |
| Artifact Registry | `us-central1-docker.pkg.dev/<project-id>/agrofarm/<service>:<git-sha>` |
| Services | `core-api`, `ml-service`, `data-service` (Cloud Run job), `frontend` |
| Cloud SQL | PostgreSQL 16 (`agrofarm-pg-staging`, `agrofarm-pg-prod`), extensions `pg_trgm` and `unaccent` |
| Storage buckets | `<project-id>-raw-<env>`, `<project-id>-clean-<env>`, `<project-id>-models-<env>`, `<project-id>-uploads-<env>` |

### 1.2 Bootstrap and apply steps

1. Authenticate locally with Google Cloud SDK:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```
2. Run the one-time idempotent bootstrap script from `agrofarm-api`:
   ```bash
   GCP_PROJECT_ID=<your-project-id> ./infra/bootstrap.sh
   ```
   This enables `storage.googleapis.com`, `cloudresourcemanager.googleapis.com`, `iam.googleapis.com`, `serviceusage.googleapis.com` and creates the versioned GCS state bucket `<project-id>-tfstate`.
3. Initialize and apply the `staging` environment:
   ```bash
   cd infra/terraform
   terraform init -backend-config="bucket=<project-id>-tfstate" -backend-config="prefix=agrofarm/staging"
   terraform plan -var-file="envs/staging.tfvars" -var="project_id=<project-id>"
   terraform apply -var-file="envs/staging.tfvars" -var="project_id=<project-id>"
   ```
4. Initialize and apply the `prod` environment:
   ```bash
   terraform init -reconfigure -backend-config="bucket=<project-id>-tfstate" -backend-config="prefix=agrofarm/prod"
   terraform plan -var-file="envs/prod.tfvars" -var="project_id=<project-id>"
   terraform apply -var-file="envs/prod.tfvars" -var="project_id=<project-id>"
   ```

### 1.3 Service accounts and Workload Identity Federation

Terraform creates dedicated least-privilege service accounts per environment:
- `sa-core-api-<env>`: Cloud SQL client, read access to `clean` bucket, read/write to `uploads` bucket, secret accessor for DB and JWT secrets, `roles/run.invoker` on `ml-service-<env>`.
- `sa-ml-service-<env>`: read-only access to `clean` and `models` buckets.
- `sa-data-service-<env>`: read/write access to `raw` and `clean` buckets, secret accessor for external data API credentials.
- `sa-frontend-<env>`: minimal runtime account with no data bucket or database access.
- `sa-ci-deployer`: used by GitHub Actions through Workload Identity Federation (`github-pool` / `github-provider`), restricted to `assertion.repository_owner == "Quetzpaciales-Space-Apps-Team"`.

## 2. Domains, CORS and cookies (OPS-002)

Pending final custom domain selection in issue OPS-002:
- The frontend and `core-api` must share the same registrable domain in production so `httpOnly; Secure; SameSite=Lax` refresh cookies work across subdomain calls.
- `CORS_ORIGINS` is passed via Terraform (`cors_origins` variable in `envs/*.tfvars`) and never uses `*` with credentials.

## 3. External accounts and Secret Manager (OPS-003)

Terraform provisions the Secret Manager secret containers; secret versions for external providers are populated manually so credentials never touch git or Terraform variables:

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

- Default branch: `develop` in the four repositories.
- Long-lived branches: `develop` (staging) and `main` (production).
- Required check: `ci-gate`.
- Automated configuration script: `agrofarm-api/infra/github-protect.sh` configures branch protection rules on `develop` and `main` across all four repositories via `gh api` (requires GitHub Team/Enterprise on private repos or public repositories; otherwise enforced by the `policy` job in `.github/workflows/ci.yml`).

## 5. Deploy and rollback

- **Staging (`develop`):** Every merge into `develop` builds the Docker image tagged with the commit SHA, pushes it to `us-central1-docker.pkg.dev/<project-id>/agrofarm/<service>:<sha>`, runs database migrations via the `core-api-migrate-staging` Cloud Run job (for `agrofarm-api`), and deploys the new Cloud Run revision.
- **Production (`main`):** Merging a release PR from `develop` into `main` waits for manual approval on the `production` GitHub environment, runs `core-api-migrate-prod`, and promotes the exact image SHA already verified in staging without rebuilding.
- **Rollback:** Shift Cloud Run traffic back to the previous known-good revision:
  ```bash
  gcloud run services update-traffic <service>-<env> \
    --region=us-central1 \
    --to-revisions=<previous-revision>=100
  ```
