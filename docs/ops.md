# Operations runbook

Every manual cloud or GitHub step is written here so it can be repeated. No secrets in this file: secrets live in Secret Manager.

## 1. GCP project

Pending: issue OPS-001. Record the project id, the region, enabled APIs, Artifact Registry repository, Cloud SQL instance, buckets, service accounts and the Workload Identity Federation setup.

## 2. Domains, CORS and cookies

Pending: issue OPS-002. The frontend and the API must share the same registrable domain so the refresh token cookie works.

## 3. External accounts

Pending: issue OPS-003. NASA Earthdata, Meteomatics (1,000 queries per day), Copernicus Climate Data Store, ICC data request.

## 4. GitHub settings

- Default branch: `develop` in the four repositories.
- Long-lived branches: `develop` (staging) and `main` (production).
- Required check: `ci-gate`.
- Branch protection: see issue OPS-004 for the current status.

## 5. Deploy and rollback

Pending: filled in by the CD tasks (FE-007, BE-003, AN-002).
