# Filter Rules

This page defines pass/fail semantics and object-shape expectations when converting intent into concrete message filters.

Use these with message-filter generation and instruction-generation tasks that describe filter intent.

---

## Rule source ids

| Value | Purpose |
|---|---|
| `Filters` | Base filter semantics and filter-object guidance. |
| `MirthFilters` | Mirth filter conversion guidance. |
| `AllFilters` | Concatenates base + Mirth filter guidance. |

---

## Rule selection behavior

- always includes `Filters`
- adds `MirthFilters` when `filter` contains `mirth`

### Non-obvious outcome

- like other string selectors, this is coarse-grained; it does not pick by data type or comparer verb.
- comparison/operator specificity must come from instruction text and message type context.

---

## Receiver vs sender semantics

- Receiver filter `false`: workflow execution is filtered and sender processing does not proceed.
- Sender filter `false`: only that sender is skipped; other sender activities may still run.

This is critical when authoring multi-sender workflows.

---

## Instruction patterns

Preferred phrasing:

```text
Continue only when PID-8.1 equals 'M'
Continue only when MSH-9.1 equals 'ADT' AND MSH-9.2 equals 'A04'
```

Avoid:

```text
Exclude female messages
Filter out non-ADT messages
```

Positive pass criteria are more stable for conversion into filter objects.

---

## Worked scenarios

### Example 1: receiver gate

Intent:

```text
Continue only when MSH-9.1 equals 'ADT'
```

Result shape:

- one string-based filter object
- source points to receiver message context

### Example 2: sender-only condition

Intent:

```text
Continue only when ${RouteToApi} equals 'true'
```

Result shape:

- sender filter object reading variable source
- no impact on sibling senders

### Example 3: Mirth import

Filter token includes `mirth`; conversion guidance should map source rules into supported HL7 Soup filter object types.

---

## Failure modes to avoid

- filter instructions that target transformation behavior
- contradictory conjunction logic in one instruction block
- path syntax mismatch for message type (HL7 path used in JSON payload, etc.)
