# CEDA historical reference evidence

Prepared with OpenAI Codex (`gpt-6.1-sol`). Human review is pending.

## Scope and available files

Use the published CEDA studies as historical agronomic references while the
information request form is unavailable. These records do not establish a
georeferenced satellite yield training set.

- [Source catalog](../../data/references/ceda/sources.json): official URLs,
  publication years, local download locations, rights notes and PDF SHA-256 hashes.
- [Yield references](../../data/references/ceda/yield-references.csv): 20 maize
  treatment means and two bean cultivar summaries, with units and page references.
- [Manifest](../../data/references/ceda/manifest.json): version, provenance,
  checksums and restrictions on spatial training use.
- Local source PDFs and text extractions: `data/raw/ceda-literature/` (ignored by Git).

Publication year and experiment date are separate fields. No confirmed 2002 or
2022 experiment has been found; neither year is inferred from bibliographic
citations. The records are not a continuous annual yield series.

## Evidence register

| Source ID | Publication | Field period | Contents and permitted analytical role |
|---|---|---|---|
| USAC-CEDA-MAIZE-2008 | Luis Arturo Segura Galindo, 2008 | Exact dates unresolved; Table 1 identifies materials under CEDA conditions in 2006 | 19 white maize hybrids plus a local control, three blocks. Table 3 contains treatment means; annexes contain plot results. Use the extracted means for historical comparisons. Do not assign them to satellite pixels. |
| USAC-CEDA-BEAN-2011 | Carlos Alberto Monterroso Gonzalez, 2011 | Sowing on 2010-07-02, Table 9, printed page 82 | Purple-pod common bean and the concurrently planted ICTA OSTUA comparator. Printed page 78 and Annex A15 report 3,204.29 and 2,878.57 kg/ha. These are reported cultivar summaries, not independently mapped field yields. |
| USAC-CEDA-POTATO-2011 | Walter Silvino Herrera Orozco, 2011 | November 2010 to April 2011 | Two varieties under protected cultivation. Yield table on printed page 80. Cataloged; numeric yield records have not been transcribed. Protective structures complicate interpretation of overhead imagery. |
| USAC-CEDA-LIPPIA-2017 | USAC chemical and biological sciences journal, volume 26(2), 2017 | Collection date unresolved | Larvicidal essential-oil study. Table 1, printed page 40, identifies CEDA collection of Lippia alba. Supports historical plant presence only; essential-oil extraction yield is not crop grain yield. |

The 2017 journal's front matter permits reproduction with attribution. This is a
document-specific statement, not a standardized open license. No reuse license
has been confirmed for the theses. Keep PDFs local and preserve attribution and
source links. Review redistribution terms before publishing complete tables or
source documents. The extracted numeric reference file remains provisional.

## Extraction and interpretation

Maize yields were transcribed from Table 3 (printed page 34), not recalculated
from rounded annex values. Preserve treatment identifiers: repeated cultivar
names elsewhere in the thesis must not silently change treatment identity.
Bean yields were cross-checked against Annex A15. That annex scales seed mass
per plant by planting density; do not describe these as measured whole-hectare
harvests. No exact harvest date was established for either extracted source.

Do not pool treatment means and their underlying plot measurements as independent
observations. Do not duplicate one treatment yield across pixels or acquisition
dates to inflate the sample size. No field coordinates or crop boundaries have
been validated. The published Lippia longitude also needs geographic verification.

## Next processing steps

1. A team member still has to review the numeric transcriptions. Claude Code already compared all 22 values with the cited pages on 2026-11-14 and found no differences (see `machine_verification` in `data/references/ceda/manifest.json`). That is a second check, not human review.
2. Resolve field dates and georeference the actual experimental plots where
   source material supports it. A station point is not an experimental boundary.
3. Investigate historical Landsat availability only after dates are resolved.
   Sentinel-2 cannot cover the 2008 or 2010-2011 studies: Sentinel-2A launched
   on [23 June 2015](https://www.esa.int/Newsroom/Press_Releases/Second_Copernicus_environmental_satellite_safely_in_orbit).
   Landsat availability alone does not resolve mixed pixels or small plots.
4. Compare regional weather and soil context with the literature as context,
   preserving spatial resolution and the distinction between static and historical data.
5. Keep the model target decision and pilot boundary decision open until the
   evidence supports them. The existing Canalitos fixtures remain provisional;
   these CEDA records must not be attached to those geometries.

Source PDFs were downloaded from their official university URLs. The manifest
records their hashes so future extractions can identify the exact input files.
