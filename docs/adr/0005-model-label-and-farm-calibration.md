# 0005. Model label and how farm uploads will be used

- Status: proposed
- Date: 2026-11-15
- Deciders: `eldmark` accepted the NDVI model as an annex result on 2026-11-15. The choice below for the product still needs a person from the machine learning role (`JorgeVilledaS`, to confirm) to accept it. Draft written with Claude Code (`claude-sonnet-5-5`).

## Context

No public source has crop yield per parcel (issue ML-005). On 2026-11-15 three candidate labels were each validated one whole year at a time against climatology, with the pass rule written before training: error at least 5 % lower, better in at least 60 % of the years, and better in at least one El Nino year and one La Nina year. Details, per-year numbers and limits are in `experiments/2026-11-15-label-search/` of `agrofarm-analytic`.

| Label | Resolution | Period | Error against climatology | Result |
|---|---|---|---|---|
| Seasonal peak NDVI on cropland (MODIS MOD13Q1) | 0.05 degrees, about 5.5 km | 2000 to 2024 | 4.4 % lower | not passed (5 % needed) |
| GDHY v1.2/1.3 maize yield | 0.5 degrees | 1995 to 2016 | 6.3 % higher | not passed |
| GGCP10 maize production | 5 arc-minutes, about 10 km | 2010 to 2020 | 2.1 % higher | not passed |

SPAM 2010 is a single year and cannot train a model over time. It was not used.

## Options

1. Serve a trained model on one of these labels. Risk: none passed the rule. A model that is not better than "expect a normal year" would be shown with false authority (rule G10).
2. Keep the declared fixed rules for the simulation, and calibrate with each farm's own data when it has enough. Cost: the simulation says plainly that it is not a trained model.
3. Keep searching for a label (seasonal mean NDVI, EVI, GPP, soil moisture, a better cropland map). Cost: time, with no guarantee.

## Decision (proposed)

Option 2 now, option 3 after the hackathon.

- **Label per crop:** none is accepted. The seasonal peak NDVI on cropland stays an experimental result, reported as an annex, and is the first label to improve on. It predicts greenness, not yield.
- **Resolution, period and limits of that experiment:** 0.05 degrees, rainy seasons 2000 to 2024, May to October. Limits: NDVI read at about 1 km without the per-pixel quality flag, a 2021 cropland map that marks only 2.8 % of the area as cropland, saturation of NDVI in dense vegetation, 25 independent years.
- **Farm uploads and calibration (proposal, not built):** an upload is validated and stored today and does not change any answer. Calibration of a farm (issue ML-060) should start only when the farm has its own series of seasonal results, for example several seasons of yield or NDVI of its parcels, and should be shown per farm with its own validation by whole years. Until a person sets the minimum number of seasons, no farm is calibrated.

## Consequences

- `/v1/simulate` keeps answering from fixed rules and keeps saying so in `model_name`. No page or text calls it a trained or validated model.
- The NDVI model is not stored in the model registry and is not loaded by `ml-service`.
- ML-005 stays open until a person accepts or changes this ADR. ML-060 and ML-030 (quantile uncertainty and attributions from a trained model) stay blocked on a label that passes the rule.
- The pass rule is kept for the next label, so a later result is judged the same way.
