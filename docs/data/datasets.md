# Dataset catalog for the crop and rotation simulator

English version of the team dataset review dated 2026-11-14.

**Verification status.** Resolutions and periods were collected from the source pages on that date. The resolutions of GRACE, GEDI L4B, TerraClimate and MODIS LST, and the ECOCROP table, were written from memory and are **unverified**. Planetary Computer collection ids came from the STAC API and external listings: **confirm every id against the API before coding**.

## Summary

Eight free datasets are enough to build the simulator: NASA POWER, CHIRPS, SMAP L4, MODIS NDVI, HLS or Sentinel-2, SoilGrids, a 30 m DEM and the NOAA ENSO index. Meteomatics adds the forecast and the series at the exact farm point.

The bottleneck is the label, not climate or soil. No free dataset has yield per parcel. The model trains on coarse-grid yield (GDHY, SPAM, GGCP10) or on a satellite proxy (NDVI, GPP), and is calibrated with what each farm uploads.

Two assumptions to confirm (issues DEC-002 and DEC-004):

- **Region:** global datasets that cover Guatemala and Central America were prioritized. Good US-only products were left out.
- **"Controlled environment":** read as a simulator where scenarios change (rainfall, temperature, ENSO phase). If it means a greenhouse, satellites cannot see inside and sensor data would be needed.

## Prioritized datasets

Core = enters the model from day one. Support = improves features or map layers. Context = only to explain or mask.

| Variable | Dataset | Resolution | Period | Access | Priority |
|---|---|---|---|---|---|
| Daily climate (temperature, humidity, wind, radiation) | NASA POWER | 0.5 x 0.625 degrees, daily and hourly | 1981 to near real time | REST API without key, community `ag` | Core |
| Historical rainfall | CHIRPS v3 | 0.05 degrees (about 5.5 km), pentad, monthly, daily | 1981 to today | Direct download or Earth Engine | Core |
| Soil moisture (surface 0-5 cm and root zone 0-100 cm) | SMAP L4 SPL4SMGP | 9 km, every 3 hours | 2015 to today | Earthdata (free login) or AppEEARS | Core |
| Vegetation vigor (NDVI, EVI) | MODIS MOD13Q1 | 250 m, 16 days | 2000 to today | Planetary Computer `modis-13Q1-061` | Core |
| Parcel-scale vegetation | HLS (Landsat + Sentinel-2) or Sentinel-2 L2A | 30 m and 10 m, every 2 to 5 days | 2013 and 2015 to today | Planetary Computer `sentinel-2-l2a`, `landsat-c2-l2` | Core |
| Soil (pH, organic carbon, texture, nitrogen, CEC, density) | SoilGrids 2.0 | 250 m, 6 depths | Static | ISRIC WCS or Earth Engine, CC BY 4.0 | Core |
| Terrain (slope, aspect, flow) | Copernicus DEM GLO-30 or NASADEM | 30 m | Static | Planetary Computer `cop-dem-glo-30`, `nasadem` | Core |
| El Nino and La Nina | RONI and ONI, NOAA CPC | One global value, monthly | 1950 to today | Plain text file | Core |
| Forecast and fine climate at the farm point | Meteomatics Weather API | Point, down to 1 km | Historical, current, forecast | 1,000 queries per day during the hackathon | Core for forecast |
| Sub-daily extreme rainfall | GPM IMERG | 0.1 degrees, 30 min | 2000 to today | Planetary Computer `gpm-imerg-hhr` or GES DISC | Support |
| Plant water stress (ESI, ET) | ECOSTRESS L4 ESI PT-JPL | 70 m, irregular passes | 2018 to today | LP DAAC or AppEEARS | Support |
| Surface temperature (heat, frost risk) | MODIS MOD11A2 | 1 km, 8 days | 2000 to today | Planetary Computer `modis-11A2-061` | Support |
| Productivity (LAI, GPP) | MODIS MOD15A2H and MOD17A2H | 500 m, 8 days | 2000 to today | Planetary Computer | Support |
| Crop mask | IO LULC annual or ESA WorldCover | 10 m | 2017 to today | Planetary Computer `io-lulc-annual-v02`, `esa-worldcover` | Support |
| Long monthly water balance | TerraClimate | About 4 km, monthly | 1958 to today | Planetary Computer `terraclimate` | Support |
| Long-term stored water | GRACE and GRACE-FO (JPL mascons) | 0.5 degree grid, real signal near 300 km, monthly | 2002 to today | PO.DAAC | Context |
| Forest to farmland change | Hansen GFC v1.13 | 30 m, annual | 2000 to 2025 | GeoTIFF in 10 x 10 degree tiles, CC BY 4.0 | Context |
| Above-ground biomass | GEDI L4B | 1 km | 2019 to 2023 | ORNL DAAC | Context |

Three warnings:

- CHIRPS daily values are disaggregated from pentads, so they are not valid for one-day extremes. Use IMERG for those.
- NOAA now uses RONI (relative) as its official ENSO index and keeps the classic ONI in parallel. Download both and test which predicts better.
- GRACE and POWER are too coarse to tell one farm from its neighbor. They are regional context, not parcel layers.

## Notes per source

- **Planetary Computer** is the most useful source: imagery, MODIS, DEM, land cover and climate through one STAC API. It provides Sentinel-2, Landsat, HLS, the MODIS products above, IO LULC, WorldCover, Copernicus DEM, NASADEM, TerraClimate, ERA5 and IMERG. SMAP, ECOSTRESS, GRACE, SoilGrids and CHIRPS were not found there.
- **Hansen GFC v1.13** has six 30 m layers (`treecover2000`, `gain`, `lossyear`, `datamask`, `first`, `last`) for 2000 to 2025. It does not predict crops. It marks parcels that were forest recently and feeds the erosion risk layer.
- **ORNL DAAC GEDI** has canopy height and biomass only. GEDI L4B is useful only for systems with trees, such as shade coffee.
- **data.nasa.gov** is an index, not a store. Downloads of SMAP L4 and ECOSTRESS ESI go through Earthdata with a free login. To avoid HDF5, request point or polygon subsets in **AppEEARS**, which covers SMAP, ECOSTRESS and MODIS.
- **Meteomatics** is limited to 1,000 queries per day. Use it for what nobody else gives free: forecast and series at the exact farm point. Take bulk history from POWER and CHIRPS. Cache every response.

## Training labels

| Dataset | What it gives | Resolution | Period | Limit |
|---|---|---|---|---|
| GDHY | Annual yield of maize, rice, wheat and soybean | 0.5 degrees | 1981 to 2016 | Coarse and ends in 2016, but it is the longest series to cross with ENSO |
| GGCP10 | Annual production of the same four crops | 10 km | 2010 to 2020 | Only 11 years |
| SPAM 2010 | Area, yield and production of 42 crops, irrigated and rainfed | 5 arcmin (about 10 km) | One year (around 2010) | A snapshot: says what is grown where |
| ESA WorldCereal | Temporary crops, maize, cereals and irrigation map | 10 m | 2021 | Crop type, not yield |
| FAOSTAT | Yield per country and crop | National | 1961 to today | No spatial detail |
| Farm data | What the user uploads | Parcel | What they have | Few records, but the only ground truth |

Recommended route: train the baseline against yield anomaly from GDHY and GGCP10 in the region, use seasonal maximum NDVI or GPP as a proxy where there is no yield, and adjust with each farm's data. The final choice is issue ML-005.

Rotation rules (nitrogen fixing, root depth, water demand, pest cycles) have no raster. They come from a crop traits table built by hand from FAO ECOCROP and the FAO-56 Kc coefficients (issue ML-038).

## How to join everything into features

Two grids: a regional 0.05 degree grid (the CHIRPS grid) for training, and 30 m sampling only inside the farm polygon for the map.

1. Define the pilot area and the crop mask with IO LULC or WorldCover.
2. Bring everything to 10-day or monthly steps. Sum rainfall, average temperature and soil moisture, take the maximum NDVI.
3. Average fine layers (NDVI, soil, slope) up to 0.05 degrees. Interpolate coarse layers (POWER, SMAP) without pretending they gain detail.
4. Compute anomalies against each cell's climatology. The model learns more from "30 % less rain than normal" than from raw millimeters.
5. Add the ENSO index with lags of 1 to 6 months, because its effect on local rain arrives late.
6. Derive the challenge indicators: water balance (rainfall minus reference ET), hot days over a threshold, nights below 2 degrees C, dry spells, weeks with low NDVI (bare soil), slope times intense rain (erosion).
7. Split training and test by whole years, holding out at least one El Nino year and one La Nina year.

Gradient boosting (LightGBM or XGBoost) on this table is enough for the hackathon and is explained with SHAP. Quantile regression gives the uncertainty range the challenge asks for.

## Gaps and risks

- **Local yield:** missing. Departmental or municipal statistics from the agriculture ministry are worth looking for. Not verified.
- **Current crop type:** WorldCereal covers only maize and cereals in 2021. For coffee, sugar cane, beans or vegetables it depends on what the farmer declares.
- **Clouds:** in the humid tropics Sentinel-2 and Landsat lose many scenes in the rainy season. Sentinel-1 radar is the backup.
- **Soil:** SoilGrids is a 250 m prediction, not a lab analysis. A farm soil analysis overrides it.
- **ECOSTRESS:** passes at different times with gaps. A map layer, not a continuous series.
- **Meteomatics:** access ends with the hackathon. Nothing critical in the baseline model may depend on it.

## Extra challenge resources: what works for Guatemala

New and useful for Guatemala:

| Dataset | What it gives | Priority |
|---|---|---|
| ERA5-Land | Hourly climate and soil on a 0.1 degree grid (about 9 km) since 1950: temperature, soil moisture, evaporation, rainfall. The daily version gives minimum and maximum | Strong support |
| FAO GAEZ v5 | Suitability and attainable yield per crop at about 1 km, 52 crops. Checks whether a crop in the rotation fits the climate and soil | Core for rotations |
| GLDAS-2.1 Noah | Soil moisture in 4 layers and root zone, every 3 hours, 0.25 degrees, since 2000 | Support |
| VIIRS VNP13A1 | NDVI, EVI and EVI2 at 500 m every 16 days since 2012. Continues the MODIS series | Support |
| ERA5 | Same as ERA5-Land at 31 km. Only if a variable is missing | Context |

ECOSTRESS covers Guatemala only with the global ESI PT-JPL product (70 m, between 52 N and 52 S). The disALEXI product covers only the continental United States.

US-only resources and their alternative for Guatemala:

| Challenge resource | Alternative for Guatemala |
|---|---|
| Web Soil Survey, SSURGO, STATSGO2 | SoilGrids |
| Cropland Data Layer, NLCD | IO LULC, WorldCover, WorldCereal |
| PRISM | CHIRPS, ERA5-Land, INSIVUMEH |
| NAIP | Sentinel-2 at 10 m |
| NLDAS | GLDAS |
| CoCoRaHS (US, Canada and Bahamas only) | INSIVUMEH and the ICC stations |
| OpenET (western US) | Global ECOSTRESS ESI and ERA5-Land evaporation |
| NASS QuickStats, AMS Market News | FAOSTAT (yield and prices per country). Agriculture ministry sources still to be found |
| NWIS, LANDFIRE, Ag Data Commons | No direct equivalent. Ag Data Commons is mostly US and was not reviewed dataset by dataset |

A local source worth requesting: the Private Institute for Climate Change Research (ICC) operates automatic weather stations on the Pacific slope of Guatemala. Its pages mention 38 stations and 48, depending on the date. Whether they share the data, and under which license, is not confirmed (issue OPS-003).

## Dataset owners

For the current handoff, `eldmark` takes the Person 2 dataset tasks first. GitHub issues DS-030, DS-031, DS-040, DS-041, DS-042 and DS-080 are assigned to `eldmark`. After that phase is complete, assign the Person 1 climate tasks to `jdivass`.

| Dataset | Owner | Issue |
|---|---|---|
| INSIVUMEH 1995 to 2025 | `jdivass` (Person 1, after Person 2 phase) | DS-010 |
| Rio Contreras rainfall | `jdivass` (Person 1, after Person 2 phase) | DS-015 |
| NASA POWER | `jdivass` (Person 1, after Person 2 phase) | DS-020 |
| CHIRPS v3 | `jdivass` (Person 1, after Person 2 phase) | DS-021 |
| ERA5-Land | `jdivass` (Person 1, after Person 2 phase) | DS-022 |
| RONI and ONI | `jdivass` (Person 1, after Person 2 phase) | DS-023 |
| Meteomatics | `jdivass` (Person 1, after Person 2 phase) | DS-070 |
| GPM IMERG, GLDAS-2.1 | Person 1 | No issue yet (support) |
| SMAP L4, MODIS, VIIRS | `eldmark` (Person 2, first phase) | DS-030 |
| Sentinel-2 or HLS | `eldmark` (Person 2, first phase) | DS-031 |
| SoilGrids 2.0 | `eldmark` (Person 2, first phase) | DS-040 |
| 30 m DEM | `eldmark` (Person 2, first phase) | DS-041 |
| IO LULC or WorldCover | `eldmark` (Person 2, first phase) | DS-042 |
| ECOSTRESS ESI | `eldmark` (Person 2, first phase) | DS-080 |
| Hansen GFC | `eldmark` (Person 2, first phase) | No issue yet (context) |
| GDHY, GGCP10, SPAM 2010 | Person 3 | DS-045 |
| FAO GAEZ v5 | Person 4 | DS-046 |
| FAO ECOCROP and FAO-56 Kc | Person 4 | ML-038 |
| FAOSTAT, WorldCereal | Persons 3 and 4 | No issue yet (context) |
