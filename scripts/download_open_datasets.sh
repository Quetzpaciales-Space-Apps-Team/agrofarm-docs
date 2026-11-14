#!/usr/bin/env bash
# Downloads the open datasets (no account needed) for Guatemala into
# $OUT/raw/<source>/. Safe to re-run: files that already exist are skipped.
#
# Usage:
#   scripts/download_open_datasets.sh [source ...]
#   sources: enso power chirps soilgrids dem worldcover hansen   (default: all)
#
# Environment:
#   OUT          output directory                      (default: ./data)
#   LAT, LON     reference point for NASA POWER        (default: INSIVUMEH station, Guatemala City)
#   START_YEAR   first year for POWER and CHIRPS       (default: 1995)
#   END_YEAR     last year for POWER and CHIRPS        (default: 2025)
#   GCS_BUCKET   if set (gs://bucket), sync $OUT/raw to it with gcloud at the end
#
# Raw files are never edited (rule: raw/ is immutable). Do not commit them to git.
set -euo pipefail

OUT="${OUT:-./data}"
LAT="${LAT:-14.59}"
LON="${LON:--90.53}"
START_YEAR="${START_YEAR:-1995}"
END_YEAR="${END_YEAR:-2025}"
# Guatemala bounding box (EPSG:4326)
W=-92.3; S=13.7; E=-88.2; N=17.9
UA="agrofarm-dataset-downloader/1.0"

fetch() { # fetch <url> <destination>
  local url="$1" dest="$2"
  if [ -s "$dest" ]; then echo "skip   $dest"; return 0; fi
  mkdir -p "$(dirname "$dest")"
  echo "get    $dest"
  if ! curl -fsSL --retry 3 --retry-delay 5 -A "$UA" -o "$dest.part" "$url"; then
    rm -f "$dest.part"; echo "FAILED $url" >&2; return 1
  fi
  mv "$dest.part" "$dest"
}

enso() { # NOAA CPC: classic ONI and relative RONI, monthly since 1950
  fetch "https://www.cpc.ncep.noaa.gov/data/indices/oni.ascii.txt"  "$OUT/raw/enso/oni.ascii.txt"
  fetch "https://www.cpc.ncep.noaa.gov/data/indices/RONI.ascii.txt" "$OUT/raw/enso/roni.ascii.txt"
}

power() { # NASA POWER daily point series. Wind (WS2M) is in m/s: convert to km/h when cleaning.
  local params="T2M,T2M_MIN,T2M_MAX,PRECTOTCORR,RH2M,ALLSKY_SFC_SW_DWN,WS2M"
  fetch "https://power.larc.nasa.gov/api/temporal/daily/point?parameters=${params}&community=AG&longitude=${LON}&latitude=${LAT}&start=${START_YEAR}0101&end=${END_YEAR}1231&format=CSV" \
        "$OUT/raw/nasa_power/daily_${LAT}_${LON}_${START_YEAR}_${END_YEAR}.csv"
}

chirps() { # CHIRPS v3 monthly rainfall, Latin America grid, 0.05 degrees
  local y m
  for y in $(seq "$START_YEAR" "$END_YEAR"); do
    for m in 01 02 03 04 05 06 07 08 09 10 11 12; do
      fetch "https://data.chc.ucsb.edu/products/CHIRPS/v3.0/monthly/latam/tifs/chirps-v3.0.${y}.${m}.tif" \
            "$OUT/raw/chirps_v3/monthly/chirps-v3.0.${y}.${m}.tif" || true
    done
  done
}

soilgrids() { # ISRIC SoilGrids 2.0 through WCS, cut to the Guatemala bounding box, 250 m
  local crs="http://www.opengis.net/def/crs/EPSG/0/4326" p d
  for p in phh2o soc clay sand silt nitrogen cec bdod; do
    for d in 0-5cm 5-15cm 15-30cm 30-60cm 60-100cm 100-200cm; do
      fetch "https://maps.isric.org/mapserv?map=/map/${p}.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=${p}_${d}_mean&FORMAT=GEOTIFF_INT16&SUBSET=X(${W},${E})&SUBSET=Y(${S},${N})&SUBSETTINGCRS=${crs}&OUTPUTCRS=${crs}" \
            "$OUT/raw/soilgrids/${p}_${d}_mean.tif" || true
    done
  done
}

dem() { # Copernicus DEM GLO-30, one tile per degree (tiles over the sea do not exist and are skipped)
  local lat lon t
  for lat in 13 14 15 16 17; do
    for lon in 089 090 091 092 093; do
      t="Copernicus_DSM_COG_10_N${lat}_00_W${lon}_00_DEM"
      fetch "https://copernicus-dem-30m.s3.amazonaws.com/${t}/${t}.tif" "$OUT/raw/copernicus_dem/${t}.tif" || true
    done
  done
}

worldcover() { # ESA WorldCover 2021 v200, 10 m, tiles of 3 degrees
  local t
  for t in N12W093 N12W090 N15W093 N15W090; do
    fetch "https://esa-worldcover.s3.eu-central-1.amazonaws.com/v200/2021/map/ESA_WorldCover_10m_2021_v200_${t}_Map.tif" \
          "$OUT/raw/esa_worldcover/ESA_WorldCover_10m_2021_v200_${t}_Map.tif" || true
  done
}

hansen() { # Hansen Global Forest Change v1.13 (2000-2025), 30 m, tiles of 10 degrees
  local layer t
  for layer in treecover2000 lossyear datamask; do
    for t in 20N_100W 20N_090W; do
      fetch "https://storage.googleapis.com/earthenginepartners-hansen/GFC-2025-v1.13/Hansen_GFC-2025-v1.13_${layer}_${t}.tif" \
            "$OUT/raw/hansen_gfc/Hansen_GFC-2025-v1.13_${layer}_${t}.tif" || true
    done
  done
}

sources=("$@")
[ ${#sources[@]} -eq 0 ] && sources=(enso power chirps soilgrids dem worldcover hansen)
for s in "${sources[@]}"; do
  case "$s" in
    enso|power|chirps|soilgrids|dem|worldcover|hansen) echo "== $s"; "$s" ;;
    *) echo "unknown source: $s" >&2; exit 2 ;;
  esac
done

if [ -n "${GCS_BUCKET:-}" ]; then
  echo "== upload to ${GCS_BUCKET}/raw"
  gcloud storage rsync --recursive "$OUT/raw" "${GCS_BUCKET}/raw"
fi
echo "done. Files are in $OUT/raw"
