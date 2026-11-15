# 0002. Pilot region and the meaning of "controlled environment"

- Status: accepted
- Date: 2026-11-14
- Deciders: team lead

Site selection update: [ADR 0006](0006-ceda-usac-pilot-site.md) selects CEDA/USAC,
zone 12. Exact parcel boundaries and current crops remain pending. The original
site-selection context below is historical.

## Context

Most of the new challenge resources cover only the United States. The team's own data (INSIVUMEH, Rio Contreras) is from Guatemala. The challenge text also mentions a "controlled environment", which could mean scenario simulation or a greenhouse. The hackathon delivery date is 2026-11-15.

## Options

1. Pilot in Guatemala with global datasets and the team's own station data.
2. Pilot in the United States to use the challenge resources directly.

## Decision

- The pilot region is **Guatemala**.
- "Controlled environment" means the simulator itself: scenarios (rainfall, temperature, ENSO phase) are changed for a location in Guatemala. It does not mean a greenhouse. No sensor data is needed.
- The exact farm and its polygon are **not decided yet** (issue DEC-003). Until then, connectors and fixtures use the INSIVUMEH station location in Guatemala City as the reference point.

## Consequences

- US-only challenge resources are replaced by the alternatives listed in `docs/data/datasets.md` (SoilGrids, IO LULC and WorldCover, CHIRPS and ERA5-Land, Sentinel-2, GLDAS, FAOSTAT).
- Tasks that need a polygon (DS-021, DS-030, DS-031, DS-040, DS-041) stay blocked on DEC-003, or start with a bounding box around the reference point.
