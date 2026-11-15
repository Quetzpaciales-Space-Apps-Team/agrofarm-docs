# 0005. Model label and how farm uploads will be used

- Status: accepted
- Date: 2026-11-15
- Deciders: `eldmark`, 2026-11-15. The project owner explicitly selected NDVI for the product's vegetation outlook despite the unmet acceptance threshold. This updates the earlier annex-only decision; it does not change the measured result or record acceptance by another team member. Initial draft: Claude Code (`claude-sonnet-5-5`); decision update: OpenAI Codex (`GPT-6`).

## Context

No public source has crop yield per parcel (issue ML-005). On 2026-11-15 three candidate labels were each validated one whole year at a time against climatology, with the pass rule written before training: error at least 5 % lower, better in at least 60 % of the years, and better in at least one El Nino year and one La Nina year. Details, per-year numbers and limits are in `experiments/2026-11-15-label-search/` of `agrofarm-analytic`.

| Label | Resolution | Period | Error against climatology | Result |
|---|---|---|---|---|
| Seasonal peak NDVI on cropland (MODIS MOD13Q1) | 0.05 degrees, about 5.5 km | 2000 to 2024 | 4.4 % lower | not passed (5 % needed) |
| GDHY v1.2/1.3 maize yield | 0.5 degrees | 1995 to 2016 | 6.3 % higher | not passed |
| GGCP10 maize production | 5 arc-minutes, about 10 km | 2010 to 2020 | 2.1 % higher | not passed |

SPAM 2010 is a single year and cannot train a model over time. It was not used.

## Options

1. Include NDVI in the product as a vegetation outlook, disclose the unmet threshold and retain the evaluation result. Cost: serving and user-facing integration still need implementation. Risk: users may read the outlook as a validated yield or ENSO forecast.
2. Keep the declared fixed rules for the simulation, and calibrate with each farm's own data when it has enough. Cost: the simulation says plainly that it is not a trained model.
3. Keep searching for a label (seasonal mean NDVI, EVI, GPP, soil moisture, a better cropland map). Cost: time, with no guarantee.

## Decision

Option 1 for NDVI only, with the limits below. GDHY and GGCP10 are not selected. The numerical acceptance rule stays unchanged; this is a product scope decision made after evaluation, not a passing model evaluation.

- **Label:** seasonal peak NDVI anomaly on cropland, relative to each grid cell's normal. The model covers mixed cropland and does not have a separate trained label for maize or black beans. It estimates vegetation greenness, not yield, growth rate or production.
- **Climate and ENSO use:** the fitted inputs include rainfall anomalies, temperature anomalies and seasonal/pre-season RONI. These support conditional what-if inputs. Setting an ENSO phase requires a documented conversion to RONI; it does not predict the next ENSO event or establish a causal crop response. Rainfall from the same season is an input, so this is not an advance seasonal forecast.
- **Required disclosure:** the leave-one-year-out evaluation reduced pooled quantile loss by 4.41 % relative to climatology, below the prespecified 5 % threshold. Skill was positive in 84 % of years, including three El Nino years and seven La Nina years. Correlation of yearly means was 0.127 and observed p10-p90 coverage was 75.6 %, below the nominal 80 %. Present those results rather than claiming the model is validated or generally reliable at distinguishing good years from bad ones.
- **Resolution, period and limits:** 0.05 degrees, rainy seasons 2000 to 2024, May to October. Limits: NDVI read at about 1 km without the per-pixel quality flag, a 2021 cropland map that marks only 2.8 % of the area as cropland, saturation of NDVI in dense vegetation, 25 independent years. This is regional information, not a parcel diagnosis.
- **Farm uploads and calibration (proposal, not built):** an upload is validated and stored today and does not change any answer. Calibration of a farm (issue ML-060) should start only when the farm has its own series of seasonal results, for example several seasons of yield or NDVI of its parcels, and should be shown per farm with its own validation by whole years. Until a person sets the minimum number of seasons, no farm is calibrated.

## Consequences

- At the time of this decision, `/v1/simulate` still answers from fixed rules. NDVI serving and integration are not deployed. Until the implementation lands, do not claim that the live app runs the NDVI model.
- Integration must declare an NDVI target and units explicitly. Never silently replace a yield-anomaly response with a vegetation-anomaly result. Keep uncertainty, out-of-range flags, model/data versions, evaluation status and local-review notices visible.
- The archived training card and experimental artifact version are historical evidence. Do not rewrite them to say they passed. The model evaluation gate and its tests remain intact.
- ML-005 can be reconciled with this accepted decision when the PR is merged. ML-030 still needs real serving and attribution work; ML-060 remains unimplemented and uploads do not calibrate results.
- The pass rule is kept for the next label, so a later result is judged the same way.

## Related scope decisions confirmed on 2026-11-15

- The project owner confirmed that someone with agronomy knowledge reviewed the project's crop-traits table. The reviewer's identity or public role, the reviewed version and any corrections have not yet been supplied. Record this as an owner-confirmed review, not an independent audit of the sources or approval of every rule threshold. The dataset author named below is not the crop-traits reviewer. Existing recommendation-level `needs_local_review` notices remain.
- Pest scoring in the rotation engine is deferred until suitable data is available. This changes the delivery scope; it does not mean the missing pest rule was implemented. Organic matter remains represented by the soil-structure score, not a separate calibrated model.
- The project owner selected a separate, multiclass maize-leaf photo feature. Candidate dataset: [Corn Leaf Disease Classification Dataset, version 1](https://data.mendeley.com/datasets/hmkd6nbngr/1), DOI `10.17632/hmkd6nbngr.1`, contributor Md Shajedur Rahman, declared CC BY 4.0. Its landing page lists common rust, corn leaf blight, gray leaf spot, healthy and insect damage. File inventory, original-source provenance, duplicates and class counts must be audited before training; page descriptions are not verified file counts.
- Ramkrishna Acharya's [Corn Leaf Infection Dataset](https://www.kaggle.com/datasets/qramkrishna/corn-leaf-infection-dataset) was considered first. Its healthy/infected labels do not identify multiple diseases or the insect species, so it cannot alone train the requested multiclass feature.
- Photo classification is separate from NDVI and the climate-dependent rotation scores. A photo may suggest one supported disease class or visible insect damage; it cannot identify an insect species from a generic damage label. The service must allow an uncertain result and disclose the limits of performance outside the training data.
- Treatment information requires a separately sourced, locally reviewed guidance catalogue. Image labels contain no treatment evidence. No pesticide product or dosage is inferred from the classifier output.
