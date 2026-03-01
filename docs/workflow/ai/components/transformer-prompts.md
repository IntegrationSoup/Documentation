# Transformer Prompts (`AITransformerPromptType`)

Transformer prompts define transformation vocabulary and output shape expectations for transformer-generation tasks.

---

## Enum values

- `Transformers`
- `MirthTransformers`
- `AllTransformers`

---

## Selector behavior (`GetTransformerPrompt(string filter)`)

- Always includes `Transformers`.
- Adds `MirthTransformers` when `filter` contains `mirth`.
- Appends system variable guidance to the final prompt text.

---

## Scenario coverage

- field mapping (`Map`)
- variable setting (`Set Variables`)
- literal updates (`Update`)
- formatting and encoding guidance
- code transformations (`Code`)
- Mirth transformer conversion patterns

Note:
- Current prompt builder uses broad transformer blocks rather than per-action micro-prompts.
