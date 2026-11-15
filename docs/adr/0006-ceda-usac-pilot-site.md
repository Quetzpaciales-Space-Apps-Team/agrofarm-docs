# 0006. CEDA USAC pilot site confirmation

- Status: accepted
- Date: 2026-11-15
- Deciders: Jorge Villeda (`JorgeVilledaS`), reporting confirmation with `eldmark`
- AI assistance: OpenAI Codex (gpt-6.1-sol), documentation; human review of this text pending

## Context

DEC-003 previously had a provisional shaded-coffee parcel near Canalitos and an
INSIVUMEH reference area. On 2026-11-15, Jorge Villeda confirmed in the project
working session that he had checked with `eldmark`: the selected pilot parcel is
CEDA/USAC in zone 12, Guatemala City. This confirms the site identity. The working
session did not supply an exact boundary, a current crop inventory or a seasonal
management history.

The [CEDA evidence register](../data/ceda-evidence.md) describes historical crop
studies. Their publication dates and experimental results do not establish the
selected parcel's current crops, rotation or yield.

## Options

1. Continue treating the Canalitos coffee fixture as the selected pilot. This
   conflicts with the site confirmation.
2. Record CEDA/USAC as the selected site and keep boundary and current-management
   questions explicit until the team supplies those details.

## Decision

Choose option 2. CEDA/USAC, zone 12, is the selected pilot site. This supersedes
the site-selection uncertainty in ADR 0002 and the area row in ADR 0004. Their
other decisions remain applicable unless superseded separately.

The Canalitos coffee system is not evidence of production at CEDA. Keep
`data/fixtures/farm.geojson` and `data/fixtures/training_area.geojson` identified
as provisional Canalitos examples; do not rename their coordinates as CEDA.
The demo seed's separate example geometry and maize/fallow sequence are also
not a verified CEDA boundary or current rotation.

## Consequences

- DEC-003 is partially resolved: site selected; exact parcel boundary and current
  crops and management still need confirmation from the team.
- Person 2 supplies or confirms the actual EPSG:4326 parcel polygon and its source.
  A point marking CEDA or its institutional grounds does not define the parcel.
- Person 4 records current crops, seasonal order, fallow or cover management and
  farmer priorities before accepting a CEDA-specific recommendation baseline.
- AGR-001 remains open. The existing maize, black bean and unspecified cover crop
  candidates remain provisional demo choices, pending confirmation for this site.
- Historical CEDA yields remain literature references. Do not assign them to the
  selected parcel, use them as current harvests or claim calibration from them.
- No new crop traits, score constants, model targets or public contracts are
  authorized by this location confirmation. Any needed changes are reviewed
  separately with Jorge Villeda before implementation.
