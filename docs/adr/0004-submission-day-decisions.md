# 0004. Submission-day decisions: model target, pilot crops, reference area and review status

- Status: accepted
- Date: 2026-11-15
- Deciders: `eldmark` (data analysis). The crop choice still needs confirmation from `JorgeVilledaS` (recommendation algorithm).

Area decision update: [ADR 0006](0006-ceda-usac-pilot-site.md) selects CEDA/USAC,
zone 12, as the pilot site. The original area decision below remains historical
context; it does not identify the current selected site. Parcel boundaries and
current crops remain pending.

## Context

The submission closes on 2026-11-15 at 23:59, local time. Several open decisions blocked work in `agrofarm-analytic` and in the frontend. There is no yield data per parcel, no decided farm polygon, and no agronomist available to review today. The team needed a version that is honest about these gaps instead of waiting for them to close.

## Options

1. Wait for a real label, a real farm polygon and an agronomist review before building. Cost: nothing reaches the submission.
2. Build with explicit provisional choices, mark them as provisional in the data, in the API output and in the app, and record what must be reviewed. Risk: a user reads a provisional value as a fact, so the marks must be visible.

## Decision

Option 2, with these choices.

| Topic | Decision | Issue |
|---|---|---|
| What the model predicts | For the submission, `POST /v1/simulate` answers from fixed rules and says so (`model_name` names a stub or rule engine, never a trained model). After the hackathon the first label to try is the seasonal maximum NDVI as a proxy, because no yield per parcel exists. | ML-005 |
| Pilot crops and strategies | Maize, black beans and a cover crop, with fallow as the bare-field option. At least three strategies are compared, including the current one. | AGR-001 |
| Area | No farm polygon is decided. The reference area is the box around the INSIVUMEH station, `-90.65 14.45 -90.40 14.75` (EPSG:4326), and the app says it is a reference area, not a farm. | DEC-003 |
| Review of crop traits | No local agronomist or farmer is available today. Crop traits and rule thresholds stay marked provisional, and every recommendation keeps `needs_local_review: true`. | DEC-006 |
| Cropland mask | No binary mask is used to select cells. The cropland fraction is used as a weight. | DS-042 |
| Erosion and waterlogging zones | Not shown in the demo. Their thresholds are unreviewed heuristics. Revisit last. | DS-041 |
| ERA5-Land | Skipped. NASA POWER and CHIRPS cover climate and rainfall, and ERA5-Land needs a Copernicus CDS account. | DS-022 |
| Rio Contreras rainfall | Left out. The data was never received. | DEC-008, DS-015 |

## Consequences

- The app and the submission text must never describe the simulation as a trained model. The rainfall baseline that exists does not beat the monthly climatology and is not served.
- The crop traits table is versioned with `status: provisional` and `reviewed_by: null`. Removing that status needs a named reviewer.
- Every layer and summary computed for the reference area carries that name. Historical yield references (see `docs/data/ceda-evidence.md`) are never copied onto its pixels.
- Open after the hackathon: the label (ML-005), the farm polygon (DEC-003), the agronomist review (DEC-006), the thresholds of the terrain zones.
