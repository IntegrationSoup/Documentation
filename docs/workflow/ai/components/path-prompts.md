# Path Prompts (`AIPathPromptType`)

Path prompts define how AIs should reference data locations across message formats and activities.

---

## Enum values

- `Paths`
- `HL7Paths`
- `XMLPaths`
- `JSONPaths`
- `CSVPaths`
- `SQLPaths`
- `MirthPaths`
- `MirthHL7Paths`
- `MirthXMLPaths`
- `MirthJSONPaths`
- `MirthCSVPaths`
- `MirthSQLPaths`
- `AllPaths`
- `AllMirth`
- `AllHL7Paths`
- `AllXMLPaths`
- `AllJSONPaths`
- `AllCSVPaths`

---

## Selector behavior (`GetPathPrompt(string filter)`)

- Always includes base `Paths`.
- Adds format-specific blocks when `filter` mentions `hl7`, `xml`, `json`, or `csv`.
- Adds Mirth conversion blocks when `filter` mentions `mirth`.
- Mirth subtype blocks are only added when both `mirth` and the relevant format token are present.

Practical use:
- build filter text from message types + import source
- call `GetPathPrompt(filter)` to pull only relevant path guidance

---

## Scenario coverage

- Native HL7/XML/JSON/CSV/SQL paths
- Cross-activity path references (`'Activity Name' Path`)
- Mirth path conversion scenarios for each supported format
