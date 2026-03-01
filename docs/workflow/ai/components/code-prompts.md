# Code Prompts (`AICodePromptType`)

Code prompts define rules for generating C# code used in Code Transformer actions.

---

## Enum values

- `Code`
- `MirthCode`
- `AllCode`

---

## Selector behavior (`GetCodePrompt(string filter)`)

- Always includes `Code`.
- Adds `MirthCode` when `filter` contains `mirth`.

---

## Scenario coverage

- base C# generation rules (plain code output, no markdown wrappers)
- available code-context APIs and interfaces
- message access patterns
- variable access patterns
- Mirth code conversion patterns
