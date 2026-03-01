# Prompt: CreateFilters (`AiFunctionType.CreateFilters`)

Generates structured message filter objects.

---

## Input intent

- filter instruction text
- source activity IDs and message path context
- filter semantics (receiver vs sender behavior)

---

## Output contract

- JSON array of filter objects compatible with `FilterHostSetting.Filters`

---

## Supporting components

- [Filter Prompts](../components/filter-prompts.md)
- [Path Prompts](../components/path-prompts.md)

---

## Usage note

Filters are generated per target activity and attached through a dedicated `FilterHostSetting` referenced by the activity `Filters` GUID.
