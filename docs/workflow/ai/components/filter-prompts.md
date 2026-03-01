# Filter Prompts (`AIFilterPromptType`)

Filter prompts define filter semantics, condition phrasing, and filter-object conversion guidance.

---

## Enum values

- `Filters`
- `MirthFilters`
- `AllFilters`

---

## Selector behavior (`GetFilterPrompt(string filter)`)

- Always includes `Filters`.
- Adds `MirthFilters` when `filter` contains `mirth`.

---

## Scenario coverage

- receiver filter semantics (false stops workflow)
- sender filter semantics (false skips sender)
- positive/opt-in wording patterns
- Mirth filter conversion examples to HL7 Soup filter objects
