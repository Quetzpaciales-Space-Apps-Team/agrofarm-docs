# AI usage in `agrofarm-docs`

This file is the public statement required by the NASA Space Apps Challenge 2026 submission rules: where and how AI tools were used. The rule that keeps it true is G11 in [`AGENTS.md`](AGENTS.md).

## Summary

AI coding assistants were used as tools to write and review code, tests, CI workflows, contracts and documentation. They did not choose the idea of the solution. A team member reviews every pull request before it is merged.

## Tools

| Tool | Model | Used by | Used for |
|---|---|---|---|
| OpenAI Codex | `gpt-6.1-sol` | `JorgeVilledaS` | AGR-002 strategy sheets, FAO-56 reference checks, crop-trait evidence audit and synthetic score-evaluation interpretation. Local expert review pending; no field calibration. |
| OpenAI Codex | `gpt-6.1-sol` | `JorgeVilledaS` | AGR-003 English app copy, units and glossary draft; consistency checks against the API and rotation engine. Human review pending. |
| OpenAI Codex | `gpt-6.1-sol` | `JorgeVilledaS` | AGR-001 pilot crop and rotation handoff, tracing the unspecified cover-crop entry, separating reported choices from current field production, and recording the sorghum demo inconsistency. Human review pending. |
| OpenAI Codex | `gpt-6.1-sol` | `JorgeVilledaS` | Correct demo rotation examples to match the engine, remove the unsupported sorghum sequence and identify the baseline as an example. Human review pending. |
| OpenAI Codex | `gpt-6.1-sol` | `JorgeVilledaS` | Record Jorge Villeda's CEDA/USAC pilot-site confirmation, distinguish it from provisional examples and historical studies, and check documentation consistency. Human review of the text pending. |
| Claude Code | `claude-fable-5-2` | `eldmark` | Repository rules, CI, scaffolds, connectors, tests, documentation, data analysis |
| OpenAI Codex | `gpt-6.1-sol` | `eldmark` | CEDA historical source research, provisional maize and bean yield transcription, provenance manifests and evidence documentation; numbers checked against the source pages by Claude Code and then reviewed by `eldmark` on 2026-11-14 |
| OpenAI Codex | `GPT-6` | `eldmark` | Dataset ownership handoff, provisional geometry formatting and area checks, demo credential removal, model-status corrections and submission documentation |
| OpenAI Codex | `GPT-6` | `jdivass` | Local review of Rio Contreras rainfall files and an AI-assisted draft of the DS-015 data review note |
| Antigravity | `Gemini 4 Hydrogen` | `MarceloDetlefsen` | Submission form updates, presentation alignment, challenge delivery checklist, 30s video script, and demo progress tracking (human-reviewed by `@MarceloDetlefsen`) |

Team members who used another tool add a row here in their next pull request (rule G11.3).

## How to trace each use

- **Commits.** From 2026-11-14, every AI-assisted commit ends with an `Assisted-by: <tool> (<model>)` trailer:
  `git log --grep="^Assisted-by:" --format="%h %an %s"`
- **Pull requests.** Every pull request has an "AI use" section that says what the tool did and who reviewed it.
- **Before the rule.** Commits authored by `eldmark` (Marco Diaz) on 2026-11-14 before this file existed were written with Claude Code and reviewed by the author. They do not carry the trailer because history is never rewritten (rule G8). Other authors: not recorded, each author states it here.

## Not generated with AI

- The project idea and the choice of challenge.
- Source datasets (INSIVUMEH, NOAA, NASA, CHIRPS, SoilGrids and the others in the dataset catalog).
