# Integration Soup Paths (Concise)

Paths are how you **locate values inside messages** so you can use them in **variables, transformers, filters, bindings, database parameters, HTTP arguments**, and other workflow settings.

Each **MessageType** has its own path syntax. The most important rule is: **always be explicit about where the data comes from**.

---

## HL7 Paths (HL7 v2.x)

### Syntax
**Format:** `Segment[index]-FieldNumber[repetition].ComponentNumber.SubComponentNumber`

- Segment: `PID`, `OBX`, `PV1`, etc.
- `index` is **1-based** and optional (first occurrence assumed if omitted)
- Field repetition `[repetition]` is optional (first repetition assumed if omitted)
- Component/subcomponent are strongly preferred

### Examples
- `PID-5.1`  
  First component of field 5 in PID

- `OBX[2]-5.2`  
  Second OBX segment, field 5, component 2

- Prefer: `PID-8.1` over `PID-8`  
  Even if there’s only one component, including it is preferred.

### Receiver vs Sender access
- Receiver value:  
  `PID-3.1`
- Sender value:  
  `'Sender Name' PID-3.1`  
  `'Sender ID' PID-3.1`

---

## XML Paths

### Syntax
- Nodes separated by `/`
- Attributes use `@`
- Always include the full path from the root

### Examples
- Element path:  
  `Patient/Demographics/Name/First`

- Attribute path:  
  `Patient/Demographics/Name/@type`

### Receiver vs Sender access
- Receiver value:  
  `Patient/ID`
- Sender value:  
  `'Sender Name' Patient/ID`  
  `'Sender ID' Patient/ID`

---

## JSON Paths

### Syntax
Integration Soup uses the same style as XML here:
- Nodes separated by `/`
- Attributes use `@`
- Always include the full path from the root

### Examples
- Value path:  
  `Patient/Demographics/Name/First`

- Attribute-style path:  
  `Patient/Demographics/Name/@type`

### Receiver vs Sender access
- Receiver value:  
  `Patient/ID`
- Sender value:  
  `'Sender Name' Patient/ID`  
  `'Sender ID' Patient/ID`

---

## CSV Paths

### Syntax
- Use **column ordinals (0-based)** in brackets
- Row selection is **not supported**
- If the column order isn’t obvious, instructions must list the presumed column order

### Examples
- Valid:  
  `[5]`
- Invalid:  
  `[Name]`

### Receiver vs Sender access
- Receiver value:  
  `[2]`
- Sender value:  
  `'Sender Name' [1]`  
  `'Sender ID' [1]`

---

## SQL Paths (Query Results)

### Syntax
For query results, paths behave like CSV, but:
- Use **column positions (1-based)** in brackets
- Multiple rows / multiple result sets are **not supported**
  - If needed, the instructions should explicitly say the action must be coded.

### Examples
- Valid:  
  `[5]`
- Invalid:  
  `[Name]`

### Receiver vs Sender access
- Receiver value:  
  `[2]`
- Sender value:  
  `'Sender Name' [1]`  
  `'Sender ID' [1]`

---

## Practical Patterns You’ll Use Often

### Pattern A — Receiver → Variable → Message
1) Set variable from receiver path  
   `Set ${PatientID} from PID-3.1`
2) Insert `${PatientID}` into the current activity’s message via mapping transformer

### Pattern B — DB Sender result → TCP Sender message
1) DB sender returns columns (SQL paths like `[1]`, `[2]`, …)  
2) TCP sender transformer references DB sender explicitly:  
   `Map the value from 'DB Insert Patient Encounter' [1] to replace PID-3.1`

---

