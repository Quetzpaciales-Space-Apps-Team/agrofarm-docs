# Clean datasets and how to build them

Status on 2026-11-15. Every dataset below is built by a command of `data-service` (`agrofarm-analytic`, `services/data`) from the raw files that `scripts/download_open_datasets.sh` puts in `data/raw/`. Raw files are never edited and never committed. Every output has a manifest JSON next to it with the source, license, checksums, units and limitations. Read the manifest before using a dataset.

Run from `agrofarm-analytic/services/data`. `RAW` is the `data/raw` folder of this repository's local checkout.

| Dataset | Command | Output | What it is |
|---|---|---|---|
| `climate_insivumeh_daily` | `uv run python -m agrofarm_data insivumeh --input <xlsx> --out <dir>` | Parquet | INSIVUMEH station, 1995-2025, 11,323 days, preliminary |
| `enso_monthly` | `... enso --oni $RAW/enso/oni.ascii.txt --roni $RAW/enso/roni.ascii.txt --out <dir>` | Parquet | ONI and RONI by month since 1950, with El Nino, La Nina or neutral |
| `climate_nasa_power_daily` | `... nasa-power --input $RAW/nasa_power/daily_*.csv --out <dir>` | Parquet | NASA POWER daily at one point, 1995-2025, with minimum and maximum temperature and radiation |
| `soil_soilgrids_static` | `... soilgrids --input $RAW/soilgrids --out <dir> --bbox W S E N --area-name <name>` | Parquet and a GeoTIFF per layer | 8 soil properties at 6 depths, 250 m prediction |
| `terrain_copernicus_glo30` | `... terrain --input $RAW/copernicus_dem --out <dir> --bbox W S E N --area-name <name>` | Parquet and a GeoTIFF per layer | Elevation, slope, aspect, flow accumulation, erosion and waterlogging zones |
| `landcover_worldcover_cropland_mask` | `... worldcover --input $RAW/esa_worldcover --out <dir> --bbox W S E N --area-name <name>` | Parquet and a GeoTIFF | Class shares on the 0.05 degree grid and a cropland mask |
| Farm land cover | `... worldcover-polygon --input $RAW/esa_worldcover --polygon <farm.geojson> --out <report.json> [--declared-cropland]` | JSON | Class shares inside a farm polygon from 10 m pixels |
| `ndvi_planetary_computer` | `... planetary-ndvi --collection sentinel-2-l2a\|modis-13Q1-061 --bbox W S E N --start YYYY-MM-DD --end YYYY-MM-DD --out <dir> --area-name <name>` | Parquet and a GeoTIFF per scene | NDVI with a cloud mask from Sentinel-2 (10 m) or NASA MODIS (250 m, 16 days). Needs network, no account |
| `climate_chirps_daily` | `... chirps --bbox W S E N --start YYYY-MM-DD --end YYYY-MM-DD --raw <dir> --out <dir>` | Parquet and a GeoTIFF per day | CHIRPS v3 daily rainfall on the 0.05 degree grid. Needs network |
| `forecast_meteomatics_point_daily` | `... meteomatics-forecast --lat <lat> --lon <lon> --days 7 --cache <dir> --out <dir>` | Parquet | Daily point forecast, up to 14 days. Needs `METEOMATICS_USERNAME` and `METEOMATICS_PASSWORD` in the environment |

The `CHIRPS` monthly files already downloaded (372 months, 1995-2025) are a different product from the daily one and have no connector yet.

## Things to know before using the data

- **NASA POWER is the NASA data in the project.** It is a reanalysis cell of about 50 km, not a station. Against the INSIVUMEH station it correlates 0.82 on monthly rainfall and 0.36 on daily rainfall, 0.74 on mean temperature. It adds minimum and maximum temperature and radiation, which the station file lacks. Nothing in the app shows it yet.
- **SoilGrids stores 0 for no data.** The connector reads 0 as null. Around the INSIVUMEH station about 80 % of the cells have no data because Guatemala City is masked as built-up. SoilGrids is a prediction: a soil analysis of the farm overrides it.
- **The cropland mask can be empty.** In the capital valley no 0.05 degree cell reaches 50 % cropland (the largest is 17 %), and a cell is about 5 km wide. The manifest warns about it. Use the cropland fraction, or the cover inside the farm polygon, not the mask alone. WorldCover under-counts small mixed fields.
- **Terrain zones are provisional heuristics.** The thresholds are team assumptions, not reviewed by an agronomist, and the erosion zone marks 39.5 % of the valley box as high. Do not present them as a diagnosis.
- **The areas used so far are provisional boxes** (the valley around INSIVUMEH, `-90.65 14.45 -90.40 14.75`). CEDA/USAC, zone 12, is now the selected site ([ADR 0006](../adr/0006-ceda-usac-pilot-site.md)); its exact parcel polygon and current crops remain pending (DEC-003). Existing extracts must not be relabeled as parcel observations. Never copy a published yield to every pixel of a box (see [CEDA evidence](ceda-evidence.md)).
- **CHIRPS daily is heavy.** The connector downloads one global file of about 18 MB per day and keeps it whole in the raw store: a year is about 6.7 GB. Run it for short periods until it reads only the area. Daily values are disaggregated from pentads and are not valid for one-day extremes.
- **NDVI is mostly cloud in the rainy season.** In a 12-scene sample for 2025 near the INSIVUMEH station, half of the Sentinel-2 scenes had too few valid pixels and stay in the table with a null NDVI. A null is not a zero. MODIS is the second NASA dataset in the project.
- **Meteomatics is a forecast and a temporary account.** It is a model output, not an observation; the hackathon account allows 1,000 queries per day and ends with the event. The connector caches every answer and stops at 500 requests per day. Nothing in the product may depend on it, and its data stays out of public repositories until the terms are checked.
- **Licenses.** NASA POWER, SoilGrids (CC BY 4.0), WorldCover (CC BY 4.0) and CHIRPS (CC BY 4.0) carry attribution in their manifests. The license wording for Sentinel-2, MODIS and Meteomatics in their manifests is not verified. The Copernicus DEM license text in the manifest is not verified. INSIVUMEH has no stated license and the file is not in git.
- **Nothing is in Cloud Storage and no service reads these tables yet.** `core-api` serves demo snapshots. Connecting a dataset to the app needs an endpoint in `core-api` and a screen in `frontend`.
