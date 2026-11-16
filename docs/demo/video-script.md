# 30-Second Demo Video Script (`DEMO-001` / `DEMO-002`)

- **Language:** English
- **Max Duration:** 30 seconds
- **Compliance:** No NASA logos/branding, no photographs of minors (`< 18`), and record in an incognito window on `https://frontend-staging-7l2bzjrqpq-uc.a.run.app` (`useMocks: false`).

| Time | Section (Submission Guide) | On-Screen Shot (`https://frontend-staging-7l2bzjrqpq-uc.a.run.app`) | Voiceover (English) |
|---|---|---|---|
| **0:00 – 0:05** | **Intro & Challenge** | Landing page of the staging URL in incognito; cursor hovers **"Try the demo"**. | "Hi, we're Team Quetzpaciales for the *Adapting Farms with NASA Data* challenge." |
| **0:05 – 0:11** | **Project Name & Entry** | Click **"Try the demo"** -> Dashboard loads provisional farm + 7 priority sliders (`POST /v1/auth/demo`). | "This is **AgroFarm**: with one click and no login, farmers and agronomists set their parcel priorities and validate local CSV or GeoJSON data." |
| **0:11 – 0:19** | **Core Idea (NASA + ENSO + Simulation)** | Scroll to **Climate Panel** (NASA POWER 1995–2025 chart + NOAA ENSO) and move **Scenario Sliders** (`-15%` rain, `+1.2 °C`, El Niño). | "AgroFarm pairs NASA POWER agroclimatology and NOAA ENSO phases with scenario controls to explore yield-anomaly ranges under fixed, transparent rules." |
| **0:19 – 0:26** | **Explainable Comparison** | Scroll to **Rotation Comparison** showing the strategies, with the current rotation marked as the baseline (example farm rotation: see note below), open strategy drawer (`why`, `evidence`, `gaps`, `risks`, `disclaimer`). | "It compares four rotation strategies against the current baseline, always showing evidence, data gaps, risks, and a local-review disclaimer." |
| **0:26 – 0:30** | **Future** | Show footer disclaimer + clean overview. | "Next, we'll calibrate with local parcel yields and agronomist-reviewed traits—supporting farmers without replacing them." |

**Note on the example farm:** the guest farm from `POST /v1/auth/demo` is created with the current rotation `maize, beans` in the API code, while the offline snapshot and the frontend test stub use `maize, fallow`. Which baseline staging displays is not confirmed. Do not say a specific rotation in the voiceover until the rehearsal (`DEMO-002`) confirms it on screen.
