# Pilot crops and rotation candidates

AI-assisted documentation: OpenAI Codex (gpt-6.1-sol), prepared for Jorge Villeda
(`JorgeVilledaS`). Human review of this text is pending.

AGR-001 records the pilot choices and the rotation candidates already implemented.
The selected site is CEDA/USAC, zone 12, as confirmed by Jorge Villeda after checking
with `eldmark`. Jorge subsequently reported that the leader retained maize and
beans, with a third entry whose name the leader did not recall. This confirms
those two pilot choices, rather than a field-verified inventory or seasonal history.

## Crop selection and its limits

The [accepted pilot decision](../adr/0004-submission-day-decisions.md) names maize,
black beans and a cover crop, with fallow as a bare-field option. The
[packaged manifest](../../../agrofarm-analytic/services/ml/src/agrofarm_ml/rotations/data/manifest.json)
and [crop table](../../../agrofarm-analytic/services/ml/src/agrofarm_ml/rotations/data/crop_traits.json)
use that same selection.

| Entry | ID in the engine | Reason for keeping it in the existing comparison | Confirmation status |
|---|---|---|---|
| Maize | `maize` | Retains the cereal in the current demo candidates and the leader's reported selection. Historical CEDA maize references are available. | Pilot choice reported by Jorge; current parcel management and variety pending. |
| Black beans | `black_beans` | Retains the legume candidate in the existing rules and the leader's reported bean selection. | The leader's reported selection says beans; the black-bean type used by the engine still needs confirmation for the parcel. |
| Cover crop | `cover_crop` | Retains the alternative used to explore soil protection in the existing provisional rules. | Documented third entry, but it is a management category: no species is selected. |
| Fallow | `fallow` | Retains the no-crop period used for comparison in the demo. | A management period, not an additional crop species or confirmed current practice at CEDA. |

The cover-crop row explicitly states that no species has been chosen. Its cycle
length, crop coefficient and rooting depth are null. Other scores remain provisional
assumptions, including an assumption of a mixture containing a legume. Do not infer
a species or a measured nitrogen benefit from those placeholder scores.

The [CEDA evidence register](../data/ceda-evidence.md) contains historical maize,
bean, potato and Lippia records. It does not establish those plants as the selected
parcel's current crops. In particular, a historical common-bean trial does not
confirm the current black-bean variety.

## Existing rotation candidates

These are the ordered steps in the
[rotation engine](../../../agrofarm-analytic/services/ml/src/agrofarm_ml/rotations/engine.py).
Each step represents a successive crop or fallow period. The engine does not assign
calendar dates or confirm how many cycles fit into one year. The periods below
must not be presented as a locally approved planting calendar.

| Candidate ID | First period | Second period | Third period | Intended comparison in the existing demo |
|---|---|---|---|---|
| `maize_fallow` | Maize | Fallow | Not specified | Example baseline retained from the demo. |
| `maize_beans` | Maize | Black beans | Not specified | Cereal and legume sequence. |
| `maize_cover_crop` | Maize | Cover crop, species pending | Not specified | Sequence containing a cover period. |
| `maize_beans_cover_crop` | Maize | Black beans | Cover crop, species pending | Sequence containing both the legume and cover entries. |

The engine also receives the farm's current rotation and marks that response
`current`. It omits a duplicate candidate when its sequence matches the supplied
current rotation. The seeded maize/fallow sequence is an example; neither the
leader's crop list nor the historical studies confirms it as CEDA's current rotation.

## Conflicting demo text

The [presentation](../demo/presentation.md) mentions a maize, bean and sorghum
sequence. Sorghum is absent from both the accepted crop decision and the packaged
crop table. Treat that presentation example as inconsistent with the implemented
comparison, not as evidence that sorghum is the third approved crop. Reconcile the
demo wording before presenting it; adding sorghum requires a separate crop decision
and source review.

## Remaining acceptance work

AGR-001 remains open until the team confirms the crop list and the actual current
rotation. The current artifacts provide two named crop types and an unspecified
cover category; they do not yet establish three to five named crop species.

- Confirm the bean type and the cover species or mixture with the team.
- Obtain the parcel's actual current sequence, including fallow or cover periods.
- Record planting and harvest windows, management constraints and farmer priorities.
- Confirm that the candidate sequences are feasible for that parcel and record team agreement.
- Prepare the strategy sheets under AGR-002 using this selection and its limitations.

All candidates retain local-review requirements. This document changes no crop
values, scoring rules, API contracts or model targets.
