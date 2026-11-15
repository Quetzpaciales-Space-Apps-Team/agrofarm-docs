# Evidence review of the pilot crop table

AI-assisted review: OpenAI Codex (gpt-6.1-sol), 2026-11-15. Human review pending.

This audit separates published reference values from assumptions used by the
rotation engine. The table has 44 trait entries: 38 cite provisional AI assumptions,
four cite recalled FAO-56 values and two cite qualitative general agronomy.
These counts include null physical fields and qualitative entries.

## Physical reference checks

The four recalled numbers match the official FAO-56 tables checked on 2026-11-15:

| Table entry | Packaged value | Published reference | Interpretation |
|---|---|---|---|
| Maize `kc_mid` | 1.20, unitless | [FAO-56 Table 12](https://www.fao.org/4/x0490e/x0490e0b.htm), field grain maize | Reference under standard conditions; local adjustment can be needed. |
| Black beans `kc_mid` | 1.15, unitless | [FAO-56 Table 12](https://www.fao.org/4/x0490e/x0490e0b.htm), dry beans and pulses | Crop-group reference, not a measured CEDA black-bean coefficient. |
| Maize `root_depth_m` | 1.0 m | [FAO-56 Table 22](https://www.fao.org/4/x0490e/x0490e0e.htm), range 1.0 to 1.7 m | A selected lower bound, not a measured parcel rooting depth. |
| Black beans `root_depth_m` | 0.6 m | [FAO-56 Table 22](https://www.fao.org/4/x0490e/x0490e0e.htm), range 0.6 to 0.9 m | A selected lower bound for dry beans, not local validation. |

These physical fields do not enter the current rotation score. Confirming their
published values cannot validate the normalized water-demand scores or bonuses.
This is a partial document check; the packaged manifest's whole-table provisional
status and incomplete human-review record remain appropriate.

## Scores and assumptions

| Fields or rules | Evidence status | Consequence |
|---|---|---|
| `cycle_days` | Maize and bean durations are assumptions; cover and fallow are null. | No parcel-specific planting calendar or annual crop count can be inferred. |
| `water_demand`, `soil_cover` | Relative scores are provisional. | Do not read them as measured water consumption or actual field cover. |
| `income`, `market_suitability`, `forage_value` | Relative scores without local budgets, prices or feed measurements. | They do not predict profit, sale prices or feed production. |
| `nitrogen_fixing` | Maize's zero and the bean's qualitative role use general agronomy; the bean magnitude is a placeholder. Cover assumes an unspecified legume mixture. | No fertilizer-rate advice or kg/ha estimate follows. |
| `soil_structure`, `erosion_reduction` | Provisional relative scores. | No soil or erosion measurement is predicted. |
| Rule bonuses and climate slopes | Chosen constants without CEDA outcome fitting. | Sensitivity checks assess consequences, not agronomic accuracy. |
| ENSO offsets | Fixed assumed rainfall equivalents. | Not a local forecast; rainfall sliders and offsets can represent overlapping assumptions. |
| Score intervals | Fixed heuristic widths. | Not calibrated confidence intervals or measured success probabilities. |

[FAO soil organic cover](https://www.fao.org/conservation-agriculture/in-practice/soil-organic-cover/en/)
supports the general reason to examine cover management. It does not supply
normalized scores, a locally selected species or calibration targets.
[CEDA historical studies](../data/ceda-evidence.md) supply references rather than
current field labels. No historical yield is copied onto the selected parcel.

## Numeric evaluation and decision

The [reproducible sensitivity report](../../../agrofarm-analytic/services/ml/experiments/rotation_scores/README.md)
compares four strengths of six existing adjustments across 450 cases each.
All pass numeric bounds. Each alternative changes the winning set in 45 cases
relative to the current settings. That is sensitivity, not evidence of improvement.

Retain the current provisional constants rather than fit them to invented target
scores. In the equal-priority neutral example, the leading three-step sequence
scores 51.4 points out of 100. Its range overlaps the alternatives, so it must not
be called a confidently superior field choice.

The implementation removes an unsupported equipment-savings claim and adds the
missing adjustment evidence and cover-species and interval limitations. It changes
no trait scores or mathematical formulas. Model training remains a separate role.
