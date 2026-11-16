# Demo & Submission Progress (`agrofarm-docs`)

## Pull requests of the demo and submission documents

| Pull request | State |
|---|---|
| `docs/ai-usage-marcelo` (#47): adds `MarceloDetlefsen` to `AI_USAGE.md` (G11) | Merged into `develop` on 2026-11-15 |
| `docs/submission-final` (#48): submission form, presentation, checklist, `video-script.md`, `ASSUMPTIONS.md` | Merged into `develop` on 2026-11-15 |
| `docs/dec-001-demo-time` (#50) and `chore/codeowners-team` (#49) | Merged into `develop` on 2026-11-15 |
| `docs/final-update` (this update) | Open, waiting for human review |

## Status on 2026-11-15

Checked with `gh` and `curl` on 2026-11-15 (about 21:58 Guatemala time).

### Repositories

| Repository | Visibility | Branches |
|---|---|---|
| `agrofarm-frontend` | PUBLIC | `develop`, `main` |
| `agrofarm-api` | PUBLIC | `develop`, `main` |
| `agrofarm-analytic` | PUBLIC | `develop`, `main` |
| `agrofarm-docs` | PUBLIC | `develop`, `main` |

All four repositories are public, so the `G12` item "make the repositories public" is done. Feature branches were deleted after their pull requests merged (see [`../ops.md`](../ops.md), section 6).

### Live URLs

| URL | State |
|---|---|
| `https://frontend-staging-7l2bzjrqpq-uc.a.run.app` | Verified: serves the frontend (HTTP 200) |
| `https://core-api-staging-7l2bzjrqpq-uc.a.run.app` | Verified: the staging API behind the frontend |
| `https://agrofarming.site` | Not confirmed. The custom domain was reported as not configured. When checked, it answered HTTP 200 with the same frontend bundle and the same `/config.json` as the staging URL. Whether this mapping is intended and stable is not confirmed, so the submission form uses the Cloud Run URL as the primary link. |

### Open issues

Only one issue was open in the four repositories when checked: `agrofarm-docs` #18, "DEMO-002 Full demo rehearsal without errors" (`needs-human`). No other issue was open.

### Pull requests

Feature pull requests of the three code repositories merged into `develop`. Each code repository also had one open `docs/final-update` pull request (documentation, waiting for human review). The `develop` to `main` sync is described in [`../ops.md`](../ops.md), section 6.

## Still to do by a human

1. **Fill the placeholders** in `docs/demo/submission-form.md`: every `TODO_TEAM_CONFIRM` (ideas not AI-generated; AI media status) and every `TODO_PUBLIC_URL` (video, slides; the repository URLs are now public and can be written in place).
2. **Slides (max 7) or a video (max 30 s):** produce at least one from `presentation.md` or `video-script.md`, share it with "Anyone with the link can view", and put the link in the form.
3. **AI use:** each team member adds the AI tools they used to the `AI_USAGE.md` of each repository.
4. **Incognito walkthrough (`DEMO-002`)** on the staging URL, then close `agrofarm-docs` #18.
5. **Click "Submit for Judging"** on the Space Apps portal before 2026-11-15 23:59 (Guatemala time).
