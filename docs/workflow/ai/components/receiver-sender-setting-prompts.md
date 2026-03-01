# Receiver/Sender Prompt Blocks

These prompt blocks drive type selection and setting-property generation for concrete activities.

---

## Type selection prompts

- `DefaultDetermineReceiverType`
- `DefaultDetermineSenderType`

Purpose:
- select exactly one concrete receiver/sender class from supplied result options
- return only the selected type string

Expected behavior:
- map intent terms (`TCP`, `REST`, `SOAP`) to product activity families
- fallback to `Code` sender where there is no native equivalent

---

## Setting generation prompts

- `DefaultCreateReceiverSetting`
- `DefaultCreateSenderSetting`
- `CreateReceiverSetting(Type type)` -> merges base prompt + type description
- `CreateSenderSetting(Type type)` -> merges base prompt + type description

Purpose:
- generate one serialized setting object for the selected type
- include only relevant properties
- avoid generating filters/transformers in this step

---

## Embedded scenario blocks

Used inside `ImportWorkflow` and `CreateWorkflowFileFromWorkflowStructure` system prompts:

- `CreateReceiverActivities` (one receiver only)
- `CreateSendersActivities` (multiple senders supported)

These include:
- type-specific property guidance
- examples
- message type value guidance
- full type naming expectations
