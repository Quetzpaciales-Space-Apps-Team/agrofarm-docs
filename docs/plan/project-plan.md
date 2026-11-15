# Project plan: crop and rotation simulator

English version of the team work plan dated 2026-11-14.

**Hackathon delivery date: 2026-11-15.** The demo time is still pending. **Pilot region: Guatemala** (see [ADR 0002](../adr/0002-pilot-region-and-controlled-environment.md)). The tasks are tracked as GitHub issues in the four repositories. This document explains how they fit together.

## 1. Summary

We are building a simulator that uses climate, soil and phenomena such as El Nino and La Nina to estimate how crops would grow on a farm. It compares at least three crop rotation strategies, including the one the farm uses today. Everything is shown on interactive maps, and the farm can upload its own data to receive recommendations.

The tool supports the farmer's decision and does not replace it. Every recommendation shows the reason, the evidence, what we do not know, and the risks a local expert must review.

## 2. Pipeline

| Step | What it does | Service |
|---|---|---|
| 1. Data | Climate, rainfall, soil moisture, vegetation, soil, terrain, ENSO | `data-service` |
| 2. Cleaning and joining | Same grid and same time steps for everything | `data-service` |
| 3. Machine learning model | Estimates growth or yield and says how sure it is | `ml-service` |
| 4. Rotation engine | Compares at least three strategies with agronomic rules and farmer priorities | `ml-service` |
| 5. Maps and screens | Layers, timeline, scenario sliders, strategy comparison | `frontend` |
| 6. Upload and demo | The farm uploads a file and gets explained recommendations | `core-api`, `frontend` |

## 3. What we already have

### 3.1 INSIVUMEH daily climate, 1995 to 2025

One station (INSIVUMEH, Guatemala City). Daily data from 1995-01-01 to 2025-12-31: 11,323 days, no duplicate dates and no missing rows. Two sheets (1995 to 2022 and 2023 to 2025). The file is marked "preliminary data".

| Variable | Unit | Observed range | Missing |
|---|---|---|---|
| Mean temperature | degrees C | 10.5 to 25.9 | 0.1 % |
| Rainfall | mm per day | 0 to 232.5 | 0.4 % |
| Relative humidity | % | 44 to 100 | 0.2 % |
| Sunshine | hours | 0 to 11.8 | 3.3 % |
| Cloud cover | oktas | 0 to 8 | 2.9 % |
| Wind speed | km/h | 0 to 60.7 | 4.5 % |

What to know before using it:

- Missing values are written as `-99.9`. They must become null before any mean or sum.
- Missing values cluster in a few years: cloud cover 1995 to 1998 (12 to 29 % per year), wind in 1995, 1996 and 2003 (20 to 30 %), sunshine in 2020 and 2021 (10 to 16 %). Rainfall and temperature are almost complete.
- Rainfall averages about 1,280 mm per year and about 93 % falls from May to October. From November to April less than 40 mm falls per month.
- Driest year 2009 (940 mm). Wettest year 2010 (2,081 mm).
- 90 days have 50 mm or more. The one-day maximum is 232.5 mm.
- Mean daily temperature is 20.1 degrees C, from 18.5 in January to 21.4 in April and May.
- **Limit:** the file has only mean temperature. Minimum and maximum come from NASA POWER or Meteomatics.
- **Limit:** it is a single point. It is valid for the farm in the capital. Other areas need CHIRPS, POWER or Meteomatics.

### 3.2 Rio Contreras micro-watershed rainfall

Reviewed for DS-015; see the [Rio Contreras rainfall review](../data/rio-contreras-rainfall-review.md). Ingestion is accepted with separate source series, incomplete-row omission, and exclusion of Zona 16 in May-June 2025. FUNCAGUA provided the data and use is permitted with attribution (DEC-008, confirmed by the data owner on 2026-11-15).

### 3.3 Free datasets

See the [dataset catalog](../data/datasets.md). No source has crop yield per parcel. Labels come from GDHY, GGCP10 or SPAM (coarse grid), from seasonal maximum NDVI as a proxy, and from what the farm uploads.

## 4. Technical agreements for everyone

| Topic | Agreement |
|---|---|
| Coordinates | Latitude and longitude in EPSG:4326 |
| Dates | `YYYY-MM-DD` in every table |
| Missing values | Null (`NaN`). Never `-99.9` and never `0` in its place |
| Units | Rainfall mm per day, temperature degrees C, humidity %, wind km/h, radiation MJ/m2 per day. POWER gives wind in m/s and it must be converted |
| Grid | Training at 0.05 degrees (same as CHIRPS). Farm map at 10 to 30 m |
| Names | English, lowercase with underscores, for example `climate_insivumeh_daily`. Raw data in `raw/` is never edited. Clean data in `clean/` |
| Code | Rules in `AGENTS.md` of each repository: branch from `develop`, pull request into `develop` |
| Cache | Store every API response. Meteomatics allows only 1,000 queries per day and ends with the hackathon |

## 5. Team roles

Roles agreed on 2026-11-14. The "Person 1 to 6" labels used in the issues map to these owners.

| Area | Owner (GitHub user) | Covers | Repository |
|---|---|---|---|
| Backend | `MarceloDetlefsen` | Person 6: API, auth, farms, uploads, search | `agrofarm-api` |
| Frontend | `MagicBag-tab` | Person 5: maps, timeline, scenarios, comparison | `agrofarm-frontend` |
| Recommendation algorithm | `JorgeVilledaS` | Person 4: crop traits, rotation rules, strategy sheets | `agrofarm-analytic` (`ml-service`), `agrofarm-docs` |
| Data analysis | `eldmark` (Person 2, first), then `jdivass` (Person 1 after Person 2's phase) | Person 2: satellite, soil and terrain; Person 1: climate, rainfall and ENSO | `agrofarm-analytic` (`data-service`) |
| Infrastructure and DevOps | `angcoder-c` | CI/CD, Docker, GCP, branch settings | all four |

**Open point:** nobody owns the machine learning model yet (Person 3: label decision, feature pipeline, baseline model, uncertainty). It must be assigned to the data analysis pair or to the recommendation owner (issue DEC-007).

## 6. Handoffs that block other people

If one of these is late, say so the same day.

| From | To | What | Format |
|---|---|---|---|
| Person 1 | Person 3 | Clean climate, indicators and ENSO | Parquet with manifest |
| Person 2 | Person 3 | Satellite, soil and terrain series | Parquet and GeoTIFF |
| Persons 1 and 2 | Person 5 | Map layers | GeoTIFF and GeoJSON |
| Person 3 | Person 6 | Model and scenario function | `ml-service` contract |
| Person 4 | Person 6 | Rule engine and crop table | `ml-service` contract and versioned table |
| Person 4 | Person 5 | Copy, glossary and strategy sheets | Markdown |
| Person 6 | Person 5 | API with example data first, real data later | OpenAPI contract |

## 7. Phases and checkpoints

The delivery date is 2026-11-15, one day after this plan was written. The phases below are an order of work, not calendar blocks: with one day left, only `priority:core` work is realistic and the team must pick the subset it will actually build (issue DEC-001). Each phase is a GitHub milestone with the same name in every repository.

| Phase | What is achieved | Leads | Checkpoint |
|---|---|---|---|
| 0. Kickoff | Pilot area, crops and strategies chosen. Repositories and technical agreements ready | Persons 4 and 6 | Everyone has a task list and access to the accounts |
| 1. Data | Data downloaded and clean. Label decided. Wireframes | Persons 1 and 2 | One clean dataset per source following the team conventions |
| 2. Baseline model and map | First trained model. Map with example layers. Minimal API | Persons 3, 5 and 6 | One prediction runs end to end, even a bad one |
| 3. Integration | Scenarios, uncertainty, three strategies compared, data upload | Persons 4 and 6 | The farm uploads a file and sees the comparison |
| 4. Polish and demo | Calibration, agronomist review, plain language, deployment, presentation | Everyone | Full demo rehearsal without errors |
| 5. Spanish port | Spanish catalog through i18n | Person 5 | Only if phase 4 is done |

**Minimum if time is short:** a map with the main layers, three strategies compared with their reasons, one El Nino or La Nina scenario, and the farm data upload. ECOSTRESS, GRACE and GEDI are optional. In the issues, the minimum is labeled `priority:core` and the rest `priority:stretch`.

## 8. Risks

| Risk | What we do |
|---|---|
| No yield per parcel | Use GDHY, GGCP10 and NDVI as a proxy, ask the farm for data, and say it clearly in the app |
| INSIVUMEH is one point and the data is preliminary | Do not extrapolate to other regions. Say it in the app. Compare with POWER and CHIRPS |
| No minimum or maximum temperature in the file | Take them from NASA POWER or Meteomatics for frost and heat |
| Clouds in the rainy season | Use MODIS and Sentinel-1 radar as backup |
| Meteomatics has 1,000 queries per day and ends with the hackathon | Use it only for the point forecast, cache everything, and keep the baseline model independent of it |
| The model looks better than it is | Validate by whole years, never by a random split |
| Planetary Computer collection ids are not confirmed | Confirm them against the API before coding |
| Little time | Follow the minimum above and leave the rest as optional |

## 9. Open decisions

| Decision | Issue |
|---|---|
| Hackathon delivery date and demo time | DEC-001. Decided: submit before 2026-11-15 23:59, local time of the team's Local Event (section 10). The one-day scope is pending |
| Pilot region, and what to do with US-only challenge datasets | DEC-002. Decided: Guatemala, ADR 0002 |
| Exact farm polygon and the crops grown today | DEC-003. CEDA/USAC, zone 12, selected by team confirmation reported by `JorgeVilledaS`; see [ADR 0006](../adr/0006-ceda-usac-pilot-site.md). Exact parcel boundary (Person 2), current crops and seasonal management remain pending. The Canalitos fixtures are not the selected pilot geometry. |
| "Controlled environment": scenario simulation or greenhouse | DEC-004. Decided: scenario simulation for Guatemala, ADR 0002 |
| What data the farm uploads | DEC-005 |
| Agronomist contact who reviews the recommendations | DEC-006 |
| Team roster | DEC-007. Roles in section 5. Owner of the machine learning model pending |
| Permission to use the Rio Contreras data | DEC-008 — resolved 2026-11-15; attribute to FUNCAGUA |

**DEC-003 site confirmation, 2026-11-15:** Jorge Villeda (`JorgeVilledaS`) reports confirmation with `eldmark` that the selected parcel is CEDA/USAC, zone 12. The earlier Canalitos report of shaded Arabica coffee with black beans during renovation does not describe confirmed crops at CEDA. Current crops and seasonal management still need confirmation; historical CEDA studies do not supply the current inventory.

## 10. Submission requirements (NASA Space Apps)

Source: the official [Project Submission Guide](https://www.spaceappschallenge.org/resources/project-submission-guide/), read on 2026-11-14. The form copy lives in [`docs/demo/submission-form.md`](../demo/submission-form.md).

### 10.1 Deadline

- Submission opened on Saturday 2026-11-14 at 09:00. It closes on **Sunday 2026-11-15 at 23:59**, in the time zone of the team's Local Event.
- Someone must click **"Submit for Judging"** before the deadline. A project that is only saved, or saved after the deadline, is not judged and gives no participant certificate.
- The project can be edited and resubmitted until the deadline. Only the last saved submission is judged. Submit early, then improve.
- The Local Event may have its own judging times. Ask the Local Lead (not verified yet).

### 10.2 Conditions to be judged

| Requirement | Our status |
|---|---|
| Every team member is a confirmed participant of the same Local Event | Not verified |
| Every required field of the project form is filled | Draft in `submission-form.md`. The SI field was missing (section 10.4) |
| Everything in the form and in linked material is in English | Rule G1 already asks for this |
| The "Terms and Conditions" and "Confirm All Work is Original" boxes are checked | At submission |
| No image, video, audio or likeness of a person under 18 | To check on the slides and screenshots |
| No NASA logo, flag or mission identifier in generated content | To check on the slides |

### 10.3 Form fields

| Field | What it asks |
|---|---|
| Project Name | The name |
| High-Level Project Summary | What we built, how it answers the challenge, why it matters |
| Link to Project Demo | A slide deck of **at most 7 slides** (title and intro slides count) **or** a video of **at most 30 seconds**. Over the limit means not eligible for Global Judging |
| Link to Final Project | A public link to the project: site, repository or hosting service |
| Detailed Project Description | What it does, how it works, benefits, goals, tools, languages, hardware and software |
| Use of Super Intelligence (SI) | Whether SI (AI) tools were used and how (section 10.4) |
| NASA Data | Which NASA data and resources we used, in detail. **At least one is required for a Global Award** |
| Space Agency Partner Data and Other References | Every dataset, resource and tool used, including code, text and images, even when open source |

Rules for the demo:

- Slides must be in English. A video may be spoken in another language only with English subtitles.
- The slides must show the team name, the names of the team members and the challenge we selected. They should show an image of the project, the user experience, and how NASA and partner agency data make the solution possible.
- The demo is hosted outside the Space Apps site. Images (JPG, PNG, GIF up to 10 MB) can be uploaded to the project page. Videos and documents cannot.

Rules for every link:

- **No password, no permission request and no registration.** If the judges cannot open a link, the project is not evaluated.
- Test every link in a private browser window before submitting.
- For a new website, the guide recommends (does not require) asking for a FortiGuard Web Filter Classification so the judges' network does not block it.

### 10.4 Use of AI ("Super Intelligence")

"SI" in the form means AI tools (machine learning, chatbots, image generation, large language models). It does not mean the International System of Units.

- AI tools are allowed as a tool. They must not be the source of the idea for the solution.
- We must say where and how they were used:
  - Images and videos made with AI carry a visible watermark.
  - Audio, code and data made with AI are acknowledged in descriptive text and metadata.
- The answer in the form is not shown to the judges. The marks inside the project (watermarks, text, metadata) are.

### 10.5 Gaps found on 2026-11-14

| Gap | What to do | Owner |
|---|---|---|
| The four repositories are private, so the repository links fail for the judges | Make public the ones we link, or link only a public site. Check first that no secret and no data without a clear license is in the history (the INSIVUMEH file is marked preliminary and is not in git) | Infrastructure, with a team decision |
| The live app link is described with demo credentials. A link "should not require a password" | Give the judges a page that opens without login (public demo mode or a landing page with the demo), and keep login optional | Backend, frontend |
| NASA data is only named in fixture metadata. No connector reads NASA data yet | Build the NASA POWER connector on the series already downloaded (`data/raw/nasa_power`) and show it in the app. This is the fastest real use of NASA data | Data analysis |
| The SI field was read as SI units | Draft added to `submission-form.md`. Every member adds the AI tools they used | Everyone |
| AI-generated code is not acknowledged in the repositories | Add an "AI assistance" note to each README | Each repository owner |
| The slides do not list team name, member names and challenge name | Add them to slide 1 | Demo owner |
| Demo format not decided: slides, video, or both links in one | Pick one for the "Link to Project Demo" field | Demo owner |
