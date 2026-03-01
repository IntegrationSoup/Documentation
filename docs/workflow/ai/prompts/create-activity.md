# Prompt: CreateActivity (`AiFunctionType.CreateActivity`)

Activity-generation scenario for custom or direct activity creation requests.

---

## Input intent

- request to create a single activity definition from description

---

## Output contract

- activity-level definition suitable for follow-up serialization/mapping into workflow settings

---

## Notes

- this prompt is intentionally minimal
- practical workflow construction usually uses the broader workflow prompts first (`CreateWorkflow`, then materialization)
