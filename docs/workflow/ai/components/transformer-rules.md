# Transformer Rules

This page defines the action vocabulary and conversion rules used when generating structured transformer actions.

Use these with transformer-action and sender-instruction generation tasks.

---

## Rule source ids

| Value | Purpose |
|---|---|
| `Transformers` | Base transformer creation rules and action patterns. |
| `MirthTransformers` | Mirth transformation conversion guidance. |
| `AllTransformers` | Concatenates both blocks. |

---

## Rule selection behavior

- always includes `Transformers`
- adds `MirthTransformers` when `filter` contains `mirth`
- always appends `SystemVariables` guidance to the selected rule text

### Non-obvious outcome

- The current string selector does not do per-action token routing (`map`, `set`, `code`, etc.).
- It returns broad guidance blocks, not a narrow action-specific rule.

Practical implication:
- your user instruction must carry action intent clearly (mapping vs variables vs code), because selector granularity is intentionally coarse.

---

## Composition pattern

For transformer authoring, compose guidance in this order:

1. path rules for message types involved
2. transformer rules
3. optional code rules if a code action is needed
4. concrete user instruction for the specific activity

---

## Worked examples

### Example 1: standard mapping set

Instruction intent:

```text
Map PID-3.1 to externalId and PID-5.1 to lastName in the current sender message.
```

Expected action family:

- one or more mapping/update transformer actions
- explicit `FromPath` values
- explicit destination paths in current activity message

### Example 2: variable extraction then reuse

Instruction intent:

```text
Set ${PatientID} from PID-3.1 and then map ${PatientID} to request/id.
```

Expected action family:

- variable transformer action for `${PatientID}`
- mapping action reading variable source into destination path

### Example 3: Mirth conversion

Filter token includes `mirth`, so conversion guidance is included automatically.

Expected action family:

- equivalent HL7 Soup transformer objects
- Mirth-specific constructs translated into supported transformer/code actions

---

## Failure modes to avoid

- ambiguous action verbs that do not imply a concrete transformer object
- path references without source context in cross-activity mappings
- mixing filter semantics into transformer instructions
- placing large procedural logic in non-code transformer actions
