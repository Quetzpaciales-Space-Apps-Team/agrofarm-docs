# Rotation strategy sheets for local review

AI-assisted documentation: OpenAI Codex (gpt-6.1-sol). Human review pending.

These sheets describe the four existing candidates for AGR-002. CEDA/USAC,
zone 12, is the selected site according to Jorge Villeda's confirmation with
`eldmark`. The leader's reported maize and bean choices do not establish the
actual parcel sequence. Cover species, seasonal calendar and parcel boundaries
remain unconfirmed. The sheets are decision support and do not replace farmers
or local agronomists.

| Engine candidate | Sheet |
|---|---|
| `maize_fallow` | [Maize followed by fallow](maize-fallow.md) |
| `maize_beans` | [Maize followed by black beans](maize-beans.md) |
| `maize_cover_crop` | [Maize followed by a cover crop](maize-cover-crop.md) |
| `maize_beans_cover_crop` | [Maize followed by black beans and a cover crop](maize-beans-cover-crop.md) |

The API marks whichever sequence the farm supplies as `current`; that is not a
fifth fixed candidate. For a current sequence matching one of these four, use its
sheet and mark it as the comparison baseline. For another or unknown sequence,
the engine output must disclose the gap; do not attach the maize/fallow sheet as
though it described that farm.

See the [trait evidence audit](../crop-trait-evidence.md) for reference checks,
provisional inputs and the score-evaluation decision. Each sheet includes why,
evidence, possible benefits, gaps and risks requiring local review. Evidence is
qualitative or historical and does not validate numeric score magnitudes.

For AGR-004, record the reviewer's identity, reviewed revision, comments and each
resolution before describing these sheets as locally reviewed. No local review
has been completed by this documentation work.
