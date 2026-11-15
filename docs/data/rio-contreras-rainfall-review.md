# Rio Contreras rainfall data review

**Status:** Ingestion decision recorded; human review and DEC-008 permission are required before implementation. Reviewed 2026-11-15 for DS-015. This AI-assisted note must be reviewed by the data owner. Source files remain outside Git.

## Files and findings

| Source | Coverage and step | Location and units | Missing data and caveats |
|---|---|---|---|
| `Serie_mensual_Rio_Contreras.xlsx` | 540 monthly records, 1981-01 through 2025-12. Each month is an independent record; values are not monthly accumulations and must not be summed into annual rainfall. | The data owner reports that FUNCAGUA produced the series as a mean over the micro-watershed. `precip_media` is inferred to be in mm, as requested by the data owner; the exact averaging method and watershed polygon/version are not documented in the workbook. | No blank monthly values or duplicate months. Zero values are present and are not identified as missing. |
| `CIT_UVG_Cayala_serie_completa.xlsx` | Daily rainfall, 2024-12-01 through 2026-09-02; monthly totals are also provided. | CIT UVG Cayalá, station ID `234424211`, `14.6044722, -90.4930659` (coordinates supplied by the data owner). Rainfall is labeled mm. | 17 blank daily values among 641 dates; omit these records from cleaned output rather than storing nulls. Dec 2024 and Sep 2026 are partial months. The temperature sheet covers only 2026-08-04 through 2026-09-03 and is outside this rainfall review. |
| `Zona16_CHIRPS_analisis.xlsx` | Daily rainfall, 2022-06-01 through 2026-09-02, with monthly comparisons. | Zona 16 station ID `234423901`, approximate coordinates `14.62, -90.48`; the workbook identifies its CHIRPS pixel as `14.625, -90.475`. Rainfall is labeled mm. | Omit records with blank rainfall values from cleaned output rather than storing nulls. Exclude all Zona 16 observations from 2025-05-01 through 2025-06-30 due to the suspected gauge problem; the diagnostic window reports 217.4 mm at Cayalá and 16.3 mm at Zona 16. |
| `chirps3_precip_monthly_14.604_-90.490_serie.csv` | 67 monthly records, 2021-01 through 2026-07. | Extraction coordinate in filename: `14.604, -90.490`, close to Cayalá. The data owner considers the CHIRPS points in the files to represent the same local area and confirms the values are in mm. CSV fields are `date`, `value_center`, `mean`, `min`, and `max`. | No empty cells. The `[1]` CSV is byte-identical and is a duplicate. Use `value_center`, which matches the CHIRPS comparison values in both workbooks; exclude `mean`, `min`, and `max` until their statistic and spatial support are documented. |

The package labels the Cayalá and Zona 16 workbooks as courtesy of Meteo Tech / FUNCAGUA. The data owner reports that the 1981-2025 series came from FUNCAGUA and is a micro-watershed mean. All reported periods and counts above were checked against the local files. In both comparison workbooks, every CHIRPS monthly value matches the CSV `value_center` exactly (20 Cayalá months and 50 Zona 16 months). The CSV's `mean`, `min`, and `max` are additional values; their precise spatial/statistical definitions are not supplied, and they do not match the workbook comparison series.

## Ingestion decision

**Decision: ingest the eligible records as separate source series, after DEC-008 confirms reuse permission.** The data owner accepts mm as the inferred unit for the 1981-2025 FUNCAGUA micro-watershed mean. Treat each monthly value as an independent area-mean record; do not treat it as a monthly accumulation or sum it into annual totals. Keep the CIT UVG gauge, Zona 16 gauge, CHIRPS `value_center`, and FUNCAGUA area-mean series separate.

For cleaned output, omit records with blank rainfall rather than persisting nulls. Exclude Zona 16 records from 2025-05-01 through 2025-06-30. Do not treat observed zeros in other periods as missing. The original source files remain unchanged; these rules apply only to ingested/cleaned records. Do not ingest the undefined CHIRPS `mean`, `min`, or `max` fields until their meanings are documented.

Build the connector only after DEC-008 permission is confirmed and the monthly area-mean field is mapped explicitly to the data-service contract.
