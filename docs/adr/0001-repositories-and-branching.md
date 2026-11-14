# 0001. Repositories, services and branching model

- Status: accepted
- Date: 2026-11-14
- Deciders: repository admin

## Context

The working rules describe four deployables: `frontend`, `core-api`, `ml-service` and `data-service`. The organization has four repositories: `agrofarm-frontend`, `agrofarm-api`, `agrofarm-analytic` and `agrofarm-docs`. One of them is for documentation, so there is one repository fewer than there are services.

The working rules also proposed trunk-based development on `main`. The team wants an integration branch so that staging and production are separate.

## Options

1. Put `ml-service` and `data-service` in `agrofarm-analytic` as two independent services.
2. Create a fifth repository for `data-service`.
3. Merge machine learning and data pipelines into a single service.

## Decision

- Option 1. `agrofarm-analytic` holds `services/ml` and `services/data`. Each has its own package, lockfile, image, contract and CI job group. No import crosses between them.
- `agrofarm-docs` holds shared documentation and the decisions and non-code tasks.
- Two long-lived branches in every repository. `develop` is the default branch and deploys to staging. `main` deploys to production. Work branches open pull requests into `develop` only. `main` receives release pull requests from `develop`.
- A pull request merges only when every check is green. The single required check is `ci-gate`.
- Pull requests run the full test suite. When the pipeline gets slow, pull requests run only the tests of the touched modules, with the safeguards of rule G3.1.

## Consequences

- One repository fewer to maintain. CI in `agrofarm-analytic` must be scoped per service with path filters.
- A change that needs both analytic services is two pull requests.
- The 10 minute threshold in rule G3.1 is a starting value. Adjust it with real timings.
- Branch protection on private repositories needs a paid GitHub plan. Until that is settled (issue OPS-004), the branch flow is enforced by convention and by the `policy` CI job.
