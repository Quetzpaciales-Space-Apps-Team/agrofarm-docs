# Annex: experimental NDVI model

Status: **experimental, supporting result**. It is not used by the application. The scenario
simulation in the app runs on fixed rules that are declared as such.

Accepted as an annex result by `eldmark` on 2026-11-15, knowing that it did not pass the rule the
team set before training (see "Result").

Written with Claude Code (`claude-fable-5-2`), reviewed by: pending.

## What was asked

Can a model tell how green the cropland of an area gets in the rainy season from the rainfall,
the temperature and the ENSO state (El Nino, La Nina) of that season, better than assuming a
normal year?

## What was measured

- **Label:** the highest NDVI of the season (May to October) on cropland, per cell of 0.05 degrees
  (about 5.5 km), as a percentage of that cell's own normal. NDVI says how green the vegetation
  is. **It is not yield.**
- **Area:** longitude -92.5 to -88.0, latitude 13.5 to 18.0 (Guatemala and parts of its
  neighbours). 969 cells with at least 5 % cropland.
- **Period:** 2000 to 2024, 25 rainy seasons, 24,225 rows.
- **Inputs:** seasonal rainfall (CHIRPS v3), mean temperature (NASA POWER, a grid of about 50 km),
  ENSO state (NOAA CPC RONI), cropland fraction (ESA WorldCover 2021).
- **NASA data:** MODIS MOD13Q1 NDVI (Terra, 16-day composites) and NASA POWER.
- **Model:** gradient boosting (LightGBM) that gives a low, middle and high value (p10, p50, p90).

## How it was tested

Each year was predicted by a model that never saw that year. The normal of each cell was also
computed without that year. The comparison is against climatology, which means "expect a normal
year, with the usual spread".

The rule was written before any model was trained. The model "works" only if:

1. its error is at least 5 % lower than climatology, and
2. it is better than climatology in at least 60 % of the years, and
3. it is better in at least one El Nino year and one La Nina year.

## Result

| Condition | Needed | Got | Met |
|---|---|---|---|
| Error lower than climatology | 5 % or more | 4.4 % | no |
| Years better than climatology | 60 % or more | 84 % (21 of 25) | yes |
| El Nino years better | 1 or more | 3 | yes |
| La Nina years better | 1 or more | 7 | yes |

**Verdict by the rule: no skill over climatology.** It missed the first condition by a little.
The rule was not changed after seeing the result.

Two more numbers that matter:

- The low-to-high range contains the real value 76 % of the time. It should be 80 %.
- The yearly mean of the label moves by about 1 % between years, and the model follows it poorly
  (correlation 0.13 between the observed and the predicted yearly mean). The small gain comes
  mostly from differences between cells inside one year, not from telling a good year from a bad
  one.

## What this supports

- A small but consistent signal exists: the model was better than "a normal year" in 21 of 25
  years, in both El Nino and La Nina years.
- The pipeline works from end to end on real data: satellite label, climate inputs, whole-year
  validation and a model card.
- It is honest evidence for why the app asks each farm for its own data: public data alone does
  not carry enough signal.

## What this does not support

- It does not predict yield, income or what to sow.
- It says nothing about one parcel. A cell mixes many fields and crops.
- It is not a forecast: the rainfall of the same season is an input.
- It must not be shown as a validated model, and no recommendation in the app depends on it.

## Other labels tried the same day

| Label | Period | Error against climatology |
|---|---|---|
| GDHY maize yield (0.5 degrees) | 1995 to 2016 | 6.3 % higher (worse) |
| GGCP10 maize production (about 10 km) | 2010 to 2020 | 2.1 % higher (worse) |

Both are worse than climatology. NDVI is the best of the three.

## Limits

- NDVI was read at about 1 km from a reduced copy of the 250 m band, so the per-pixel quality
  flag was not applied. Cloudy dates are removed only by taking the seasonal maximum.
- The cropland map is from 2021 and is used for every year. It marks only 2.8 % of the area as
  cropland, which is low: small maize plots are often mapped as grass or shrub.
- Peak NDVI of dense vegetation saturates, so wet years are told apart poorly.
- Rows of one year share the weather. 25 years are few independent samples.
- One model family, no tuning.
- License wording of the MODIS collection on the Planetary Computer was not verified.

## Where the record is

`agrofarm-analytic`, folder `experiments/2026-11-15-label-search/` (rule as written before
training, per-year results, model card, how to reproduce) and the code under
`services/data/src/agrofarm_data/labels/` and `services/ml/src/agrofarm_ml/ndvi/`
(pull request 61 of that repository).
