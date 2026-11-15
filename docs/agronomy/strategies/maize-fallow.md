# Maize followed by fallow

AI-assisted draft: OpenAI Codex (gpt-6.1-sol). Local expert review pending.

Sequence: maize, then a fallow period. Engine candidate: `maize_fallow`.
It is the example baseline, not a confirmed seasonal history for CEDA/USAC.

## Why

This option provides a reference against which to compare the other sequences.
The engine assumes that the fallow period is mostly bare soil.

## Evidence

- [FAO soil organic cover](https://www.fao.org/conservation-agriculture/in-practice/soil-organic-cover/en/)
  supports keeping soil protected between crops; it does not validate this option's numeric penalty.
- [CEDA historical evidence](../../data/ceda-evidence.md) records maize experiments,
  not current yields or management of the selected parcel.

## Possible benefits

Provides a simple comparison reference. Equipment, labour and financial savings
have not been assessed and must not be promised.

## Gaps

The length of fallow, residue cover, weed management, soil and planting dates are
unknown. The engine uses equal weight per step, not duration. Scores and their
ranges are provisional; the range is not a probability of success.

## Risks and local review

Review soil exposure and rainfall timing with a local expert. Confirm whether the
field is actually left bare before applying the engine's fallow penalty. Do not
interpret a low crop-water-demand score as zero evaporation from bare soil.
