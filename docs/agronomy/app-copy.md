# App copy and agronomy glossary

AI-assisted draft: OpenAI Codex (gpt-6.1-sol), prepared for Jorge Villeda
(`JorgeVilledaS`). Human review is pending.

This is the English copy handoff for AGR-003. It explains scenarios, rotation
comparisons and their limits. Frontend integration is a separate task. The existing
[English catalog](../../../agrofarm-frontend/src/i18n/en/common.json) provides the
current screen text; the wording below is proposed for review.

## Decision support disclaimer

> This tool supports decisions. It does not replace farmers or local agronomists.

Keep this disclaimer visible with simulation and recommendation results. It matches
the [public API disclaimer](../../../agrofarm-api/src/core_api/domain/recommendations.py).

## Scenarios and comparison

| Screen element | English copy |
|---|---|
| Scenario title | What if the weather changes? |
| Scenario help | Change rainfall, temperature or the El Nino or La Nina phase to compare possible conditions. This is a scenario, not a weather forecast. |
| Comparison title | Compare rotation strategies |
| Comparison help | Compare each option with the current rotation. Read the reasons, evidence, benefits, gaps and risks before choosing an action. |
| Current rotation marker | Your current rotation |
| Highest score marker | Highest score for your selected priorities |
| Review marker | Needs local expert review |
| Why block | Why this option is shown |
| Evidence block | Evidence behind this option |
| Benefits block | Possible benefits |
| Gaps block | Information we are missing |
| Risks block | Risks to review locally |
| Rule engine notice | These scores use fixed rules and provisional crop information. They have not been validated for decisions on your farm. |
| Uncertainty help | This range shows the spread assigned by the current method. For rule-based rotation scores, it is provisional and does not give a measured probability of success. |
| Priority help | Scores show how the rules rate each option against your priorities. A higher score means a better fit under those rules. It does not promise more harvest or income. |
| Missing crop information | This rotation contains a crop the rules do not know. Its neutral scores do not show that it performs as well as another option. |
| Upload help | Upload your farm records for storage and review. Uploads do not currently calibrate the simulation or change the rotation scores. |

These limitations follow the [rotation engine](../../../agrofarm-analytic/services/ml/src/agrofarm_ml/rotations/engine.py)
and the [farm calibration decision](../adr/0005-model-label-and-farm-calibration.md).
Keep them beside the results they qualify. Retain `needs_local_review` when handing
recommendation content to the frontend.

## Number labels and units

Always show a number with its unit, period and comparison reference where relevant.
Use the unit supplied by the data contract. Leave missing values as "No data".
Convert a unitless score from 0 to 1 into points out of 100 only for display;
label it as points, never as a probability or an expected percentage gain.

| Quantity | Label or display pattern | Meaning |
|---|---|---|
| Farm area | Area (ha) | Hectares inside the farm boundary. |
| Daily rainfall | Rainfall (mm per day) | Rainfall total for one day. |
| Monthly rainfall | Rainfall (mm per month) | Rainfall total for the named month. |
| Temperature | Temperature (°C) | State whether the value is mean, minimum or maximum. |
| Rainfall scenario | Rainfall change from baseline (%) | A relative change in the scenario input. |
| Temperature scenario | Temperature change from baseline (°C) | A difference from the baseline temperature. |
| Overall rotation score | Overall fit: {score} points out of 100 | A provisional fit score for the selected priorities. |
| Priority score | {priority}: {score} points out of 100 | A provisional fit score for one priority. |
| Rotation score range | Provisional fit range: {low} to {high} points out of 100 | The rule engine's range for that score. |
| Crop cycle | Crop cycle (days) | Days from sowing to harvest, when known. |
| Root depth | Root depth (m) | Root depth in metres, when known. |
| Evapotranspiration | Evapotranspiration (mm per day) | Water leaving the soil and plants during a day. |
| Water balance | Water balance (mm over {period}) | Water inputs minus the losses included in the calculation. |
| Vegetation index | NDVI (unitless) | An index of vegetation greenness. |
| Soil moisture anomaly | Soil moisture difference ({unit}) from {reference} | Name the source unit and reference period; do not infer a unit from the word anomaly. |
| Frost risk | Frost risk ({unit}, over {period}) | Only use a numeric risk with a defined method and unit. Otherwise show a named risk class. |
| Simulation result | {target} ({unit}, over {period}) | Use the response target and unit; a greenness estimate is not crop yield. |

For priority names, use "Water use", "Income", "Soil structure", "Animal feed",
"Nitrogen fixation", "Erosion reduction" and "Market suitability". Each displayed
priority score uses points out of 100. Income and market scores are relative fit
scores; they are not amounts of money or sale prices.

## Glossary

| Term | Plain English explanation |
|---|---|
| Evapotranspiration | Water that leaves the soil through evaporation and leaves plants through their leaves. It is often measured in millimetres per day. |
| NDVI | Normalized Difference Vegetation Index: a unitless index calculated from reflected light to describe vegetation greenness. Greener vegetation does not by itself tell us the harvest. |
| Soil moisture anomaly | How much wetter or drier the soil is than a stated reference for the same time of year. The source determines the unit and reference period. |
| Frost risk | The chance or risk class for freezing conditions that could harm a crop during a stated period. Crop sensitivity and the method used affect its meaning. |
| Water balance | Water coming in minus the water losses counted during a stated period. Check which inputs, losses and soil storage changes the method includes. |
| Rotation | A sequence of crops or fallow periods grown on the same land over time. |
| Fallow | A period when no crop is grown. Soil cover during that period depends on how the field is managed. |
| Cover crop | A crop grown mainly to protect or improve the soil. The species and management must be chosen for the farm. |
| Baseline | The starting conditions or current practice used for comparison. |
| Scenario | A set of conditions you choose to explore what could happen. |
| Evidence | The records or publications behind a statement. Provisional assumptions must be identified as assumptions. |
| Information gap | Something we do not know that could change the result or the decision. |
| Uncertainty | The limits of what a result tells us. Read the explanation of how a displayed range was made. |

## Loading and unavailable results

| State | English copy |
|---|---|
| Loading | Comparing rotation strategies... |
| Updating | Updating the comparison for your scenario... |
| Empty result | No rotation comparison is available for these inputs. |
| Service unavailable | The comparison service could not be reached. Try again. |
| Incomplete result | This option is missing required explanation or risk information and cannot be shown. |
| Missing measurement | No data |

## Review and delivery

Jorge Villeda reviews the wording and its agronomic meaning. The frontend owner
integrates accepted text into the English catalog and checks the rendered labels,
units and disclaimer. A local agronomist or farmer reviews strategy-specific
claims through AGR-004. This draft does not record that review as complete.
