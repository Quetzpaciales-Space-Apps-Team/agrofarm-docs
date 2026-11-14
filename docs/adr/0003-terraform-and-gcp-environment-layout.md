# 0003. Terraform location, GCP environment layout and Docker contract

- Status: accepted
- Date: 2026-11-14
- Deciders: @angcoder-c

## Context

Rule G6 specifies Google Cloud Platform (Cloud Run services and jobs, Cloud SQL for PostgreSQL, Artifact Registry, Secret Manager and Cloud Storage) and Rule G3 requires Workload Identity Federation (WIF) from GitHub Actions without service account JSON keys. ADR 0001 fixed the organization to four repositories (`agrofarm-frontend`, `agrofarm-api`, `agrofarm-analytic`, `agrofarm-docs`) with no separate infrastructure repository.

We need a repeatable Infrastructure-as-Code (Terraform) setup that provisions all GCP resources for staging (`develop`) and production (`main`) within the hackathon budget and integrates cleanly with the Docker images built across the three code repositories.

## Options

1. **Keep Terraform in `agrofarm-api/infra/terraform` with reusable modules**, using a single GCP project in `us-central1` where staging and production resources use `-staging` and `-prod` suffixes, and store remote state in a versioned GCS bucket created by an idempotent bootstrap script.
2. **Create a fifth repository (`agrofarm-infra`)** and two separate GCP projects (`staging` and `prod`).
3. **Split Terraform across all four repositories**, with each repository managing its own Cloud Run service and IAM bindings.

## Decision

We chose **Option 1**:

- **Location:** All Terraform configurations and modules live in `agrofarm-api/infra/terraform` alongside `agrofarm-api/infra/bootstrap.sh`. `core-api` owns Cloud SQL and orchestrates the internal services, making `agrofarm-api` the natural home without breaking the four-repository constraint from ADR 0001.
- **Single GCP project & region:** One GCP project in `us-central1` hosts both environments. Environment-scoped resources (Cloud Run services/jobs, Cloud SQL databases/instances, buckets, secrets) are suffixed with `-staging` and `-prod` via `envs/staging.tfvars` and `envs/prod.tfvars`.
- **Remote state:** Terraform state lives in a versioned, private GCS bucket (`<project-id>-tfstate`) provisioned once by `infra/bootstrap.sh`.
- **Database baseline:** Local development uses `postgis/postgis:16-3.4` with only `pg_trgm` and `unaccent` enabled in the initial setup; Cloud SQL runs PostgreSQL 16 with `pg_trgm` and `unaccent`. Enabling `postgis` waits for ADR `BE-015`.
- **Docker and Cloud Run contract:**
  - All images are pushed to a single Artifact Registry repository: `us-central1-docker.pkg.dev/<project-id>/agrofarm/<service>:<git-sha>`.
  - Every service container listens on `${PORT:-8080}` as a non-root user and exposes `GET /healthz` and `GET /readyz`.
  - Environment variable names match across `.env.example`, `docker-compose.yml` and Terraform Cloud Run `env` blocks (`PORT`, `LOG_LEVEL`, `DATABASE_URL`, `CLOUD_SQL_INSTANCE`, `ML_SERVICE_URL`, `CORE_API_URL`, `GCS_BUCKET_RAW`, `GCS_BUCKET_CLEAN`, `GCS_BUCKET_MODELS`, `GCS_BUCKET_UPLOADS`, `CORS_ORIGINS`).

## Consequences

- Provisioning is centralized in one state tree per environment (`staging` and `prod` state prefixes), preventing circular dependencies between service accounts, Cloud Run URLs and IAM invoker bindings.
- `ml-service` and `data-service` are deployed with `--no-allow-unauthenticated`; Terraform grants `roles/run.invoker` on `ml-service` only to the `core-api` runtime service account.
- Continuous deployment workflows (`BE-003`, `AN-002`, `FE-007`) only build images, run migrations/jobs and update the Cloud Run image tag using the WIF provider and `ci-deployer` service account created by Terraform.
