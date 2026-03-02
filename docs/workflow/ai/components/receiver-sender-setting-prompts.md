# Receiver/Sender Prompt Blocks

These prompt blocks control two critical phases:

1. choosing the concrete activity type
2. producing serialized JSON settings for that type

Use this layer after planning (`AiWorkflowStructure`) and before filter/transformer attachment.

---

## Type selection prompts

- `DefaultDetermineReceiverType`
- `DefaultDetermineSenderType`

### Expected behavior

- choose exactly one option from provided type candidates
- return only the selected type name/value
- map intent aliases:
  - `TCP` -> MLLP family
  - `REST`/`HTTP` -> HTTP family
  - `SOAP`/`WCF` -> WebService family
- choose `Code` sender when no native equivalent exists

### Failure modes to avoid

- returning prose instead of a single type selection
- returning a type not present in the provided result options
- selecting multiple candidates

---

## Setting generation prompts

- `DefaultCreateReceiverSetting`
- `DefaultCreateSenderSetting`
- `CreateReceiverSetting(Type type)` (base prompt + type-specific description)
- `CreateSenderSetting(Type type)` (base prompt + type-specific description)

### Output contract

- emit one serialized setting object
- include only known serialized properties for the chosen class
- omit unknown values rather than inventing defaults
- do not generate filters or transformers at this stage
- if a message template is supplied, preserve it exactly

### Failure modes to avoid

- adding non-serialized/internal-only properties
- embedding transformation logic into generic activity instructions
- modifying provided message templates

---

## Embedded scenario blocks used by system prompts

Used by `ImportWorkflow` and `CreateWorkflowFileFromWorkflowStructure` system prompts:

- `CreateReceiverActivities`
- `CreateSendersActivities`

These blocks provide:

- activity-family intent mapping
- one-receiver-only workflow rule
- multi-sender guidance
- message type guidance
- qualified type naming expectations for generated setting objects

---

## Recommended generation sequence

1. determine receiver type
2. generate receiver setting JSON
3. determine each sender type
4. generate each sender setting JSON
5. attach filter host/transformer host references in assembly stage

Do not collapse these into a single unconstrained prompt if deterministic output is required.
