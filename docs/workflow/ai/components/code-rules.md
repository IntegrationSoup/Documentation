# Code Rules

This page defines constraints and API guidance for generating C# used by code-based transformations.

Use these with code-transformation generation tasks.

---

## Rule source ids

| Value | Purpose |
|---|---|
| `Code` | Base C# generation rules and runtime API guidance. |
| `MirthCode` | Mirth script conversion guidance into C#. |
| `AllCode` | Concatenates base + Mirth code guidance. |

---

## Rule selection behavior

- always includes `Code`
- adds `MirthCode` when `filter` contains `mirth`

### Non-obvious outcome

- selector is binary (base vs base+Mirth), not task-granular.
- if you need both transformer-shape guidance and code-style guidance, combine this with transformer rules in the same generation request.

---

## Code output contract

Generated output should follow these constraints:

- return plain C# only
- no markdown fences
- target .NET Framework 4.8 compatibility
- use runtime APIs exposed to workflow code context
- avoid inventing unsupported properties or helper classes

---

## Composition pattern

When generating a code transformer payload:

1. build/validate non-code transformer plan first
2. identify the exact step(s) requiring code
3. call `CreateCodeTransformers` with:
   - activity message type context
   - required input/output variable paths
   - strict expected result shape (`Code` body only or code action payload shape)

---

## Worked scenarios

### Example 1: expression too complex for map/update action

Intent:

```text
Normalize a patient surname with McNameCase, preserve original when empty.
```

Expected result:

- generated C# implementing normalization logic
- code can be embedded in a code transformer action

### Example 2: Mirth JavaScript conversion

Filter token includes `mirth`.

Expected result:

- JavaScript channel logic translated to C#
- variable access and message path access translated to HL7 Soup runtime patterns

---

## Failure modes to avoid

- returning mixed prose + code
- using language features or APIs not available to target runtime
- generating code that assumes unavailable sender/receiver instances without context binding
