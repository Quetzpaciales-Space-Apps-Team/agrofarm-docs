# How to download the datasets

Links were checked on 2026-11-14. Planetary Computer collection ids below were confirmed against the STAC API on that date.

## 1. Open datasets: one script, no account

```
scripts/download_open_datasets.sh                 # everything, into ./data/raw/<source>/
scripts/download_open_datasets.sh enso power      # only some sources
GCS_BUCKET=gs://<bucket> scripts/download_open_datasets.sh   # also sync data/raw to the bucket
```

The script skips files that already exist, so it can be re-run after a failure. Tested on 2026-11-14 for `enso`, `power`, `chirps` and `soilgrids`. For `dem`, `worldcover` and `hansen` only the URLs were checked, not a full download.

| Source key | Dataset | What is downloaded | Approx. size | URL pattern |
|---|---|---|---|---|
| `enso` | ONI and RONI, NOAA CPC | Two text files, monthly since 1950 | under 1 MB | `https://www.cpc.ncep.noaa.gov/data/indices/oni.ascii.txt`, `.../RONI.ascii.txt` |
| `power` | NASA POWER daily | One CSV for the reference point, 1995 to 2025: T2M, T2M_MIN, T2M_MAX, PRECTOTCORR, RH2M, ALLSKY_SFC_SW_DWN, WS2M | under 2 MB | `https://power.larc.nasa.gov/api/temporal/daily/point?...&community=AG&format=CSV` |
| `chirps` | CHIRPS v3 monthly, Latin America | One GeoTIFF per month, 1995 to 2025 | about 4 MB per month, 1.6 GB total | `https://data.chc.ucsb.edu/products/CHIRPS/v3.0/monthly/latam/tifs/chirps-v3.0.YYYY.MM.tif` |
| `soilgrids` | SoilGrids 2.0 | 8 properties x 6 depths, cut to Guatemala | about 3 MB per layer, 150 MB total. Slow: about 40 s per layer | ISRIC WCS, `https://maps.isric.org/mapserv?map=/map/<property>.map&SERVICE=WCS...` |
| `dem` | Copernicus DEM GLO-30 | 1 degree tiles, N13 to N17, W089 to W093 | about 50 MB per tile | `https://copernicus-dem-30m.s3.amazonaws.com/<tile>/<tile>.tif` |
| `worldcover` | ESA WorldCover 2021 v200 | Four 3 degree tiles | about 50 MB per tile | `https://esa-worldcover.s3.eu-central-1.amazonaws.com/v200/2021/map/ESA_WorldCover_10m_2021_v200_<tile>_Map.tif` |
| `hansen` | Hansen GFC v1.13 | `treecover2000`, `lossyear`, `datamask` for tiles 20N_100W and 20N_090W | up to 330 MB per file | `https://storage.googleapis.com/earthenginepartners-hansen/GFC-2025-v1.13/Hansen_GFC-2025-v1.13_<layer>_<tile>.tif` |

Notes:

- The default reference point is the INSIVUMEH station in Guatemala City (`LAT=14.59`, `LON=-90.53`, approximate). Set `LAT` and `LON` for another point.
- POWER wind is in m/s. Convert to km/h when cleaning. POWER missing values are `-999`: turn them into null.
- CHIRPS daily files also exist under `.../CHIRPS/v3.0/daily/final/`. They are disaggregated from pentads and are not valid for one-day extremes.
- SoilGrids values are scaled integers. Check the conversion factor of each property before using them.

## 2. Datasets that need a free account

These cannot be scripted until the account exists (issue OPS-003). Credentials go in Secret Manager, never in git.

| Dataset | Account | Where |
|---|---|---|
| SMAP L4, MODIS, VIIRS, ECOSTRESS point or polygon subsets | NASA Earthdata | AppEEARS API: `https://appeears.earthdatacloud.nasa.gov/api/` (product list at `/api/product`) |
| ERA5-Land daily statistics | Copernicus CDS | `https://cds.climate.copernicus.eu/datasets/derived-era5-land-daily-statistics` (use the `cdsapi` client) |
| GLDAS-2.1 Noah, GPM IMERG | NASA Earthdata | GES DISC: `https://disc.gsfc.nasa.gov/` |
| Meteomatics forecast | Meteomatics hackathon account | `https://api.meteomatics.com/`, 1,000 queries per day. Cache every response |

## 3. Planetary Computer (no account, but needs a small Python client)

STAC API: `https://planetarycomputer.microsoft.com/api/stac/v1`. Asset URLs must be signed with the `planetary-computer` Python package before download, so these are fetched by the `data-service` connectors, not by the shell script.

Confirmed collection ids: `sentinel-2-l2a`, `modis-13Q1-061`, `modis-11A2-061`, `cop-dem-glo-30`, `nasadem`, `io-lulc-annual-v02`, `esa-worldcover`, `terraclimate`, `gpm-imerg-hhr`.

## 4. Manual downloads

| Dataset | Where | Note |
|---|---|---|
| GDHY yield | PANGAEA, `https://doi.pangaea.de/10.1594/PANGAEA.909132` | Download from the page |
| GGCP10, SPAM 2010 | Their publication pages and `mapspam.info` | Links not verified |
| FAO GAEZ v5, FAOSTAT | FAO portals | Links not verified |
| INSIVUMEH 1995 to 2025 | Team Excel file | Upload it to `raw/insivumeh/` in the bucket |
| Rio Contreras rainfall | Team files | Permission pending (issue DEC-008) |
