# Integration Soup Paths For AI

## Executive summary

I use **paths** to locate or set values inside messages across workflows (bindings, mappings, variables, database parameters, and HTTP arguments). Paths are always **(source activity) + (message-type locator string)**. 

This document is intentionally **AI-targeted**: it is compact, canonical, and formatted so an AI can reliably generate correct path strings and examples without inventing syntax. 

## Purpose and scope

This is my **definitive, AI-ingestion-oriented** reference for Integration Soup workflow path structure. It is not a UI walkthrough or code tutorial; it exists so an AI (or developer) can produce correct, unambiguous path expressions and mapping instructions that work consistently across the product. 

Scope includes:
- Reading values (bindings, filters, conditions, variable creation). 
- Writing values (mapping transformers, append/construct message templates, SetValueAtPath behavior). 
- Cross-activity sourcing (select a different activity as the “source” for a path). 
- Variables as the bridge between “path world” and “text/template world.” 
- DB parameters and HTTP query/path arguments (where values ultimately come from paths/variables).

## Mental model

A **path reference** is two-part:

1) **Source activity**: which activity’s message (or variables) I’m reading from. The designer supports this via the **anchor button** on Source Path (and a source selector in trees), defaulting to the receiver’s inbound message.  
2) **Locator**: the message-type-specific string that identifies the value within that activity’s message. 

When I write cross-activity references in text (for AI prompts/specs), I use this canonical shorthand:

- `'Activity Name' <Locator>`

This corresponds to selecting that activity in the Source Path anchor dropdown (I’m expressing the same choice in text form).

## Path grammars by message type

### HL7 locator grammar

HL7 locators follow this structure:

```text
<hl7-path> :=
  SEGMENT [ "[" segmentIndex "]" ]
  "-" FIELD [ "[" fieldRepetition "]" ]
  [ "." COMPONENT [ "[" componentRepetition "]" ] [ "." SUBCOMPONENT ] ]
```

Integration Soup documents HL7 paths as:  
`Segment[RepeatSegmentIndex]-Field[RepeatFieldIndex].Component[RepeatComponentIndex].SubComponent`.

Notes I treat as canonical:
- Segment, field, component, and subcomponent levels exist; indexes can appear for repeats.
- If indexes are omitted, the **first instance is assumed**.
- Examples that show explicit segment indexing: `OBX[2]` and `OBX[2]-5.2`. 

### XML/JSON locator grammar

Integration Soup uses a **simplified XPath-like** locator for XML and JSON:

```text
<xmljson-path> := node ( "/" node )*
node := NAME [ "[" n "]" ] | "@" ATTRNAME
```

Canonical traits:
- Hierarchy uses `/` separators; repeating nodes use `[n]`; attributes use a final node beginning with `@`.
- Integration Soup explicitly calls this “a simplified XPath expression.”
- If strict .NET XPath is required, prefix with `xpath:` (usually unnecessary).

XPath grounding (why `@attr` and `[n]` mean what they mean):
- W3C XPath defines `@` as the attribute abbreviation. citeturn7view1
- W3C XPath examples interpret `[5]` as selecting the fifth matching node (positional predicate).
- W3C XPath positions are 1-based in the data model (“position of the first item … is always 1”).

### CSV locator grammar

CSV locators are column ordinals:

```text
<csv-path> := "[" zeroBasedColumnIndex "]"
```

Integration Soup explicitly documents CSV paths as **0-based** indices: `[0]` is first, `[1]` is second.

### SQL locator grammar and ambiguity note

For SQL query **results** (single-row conceptual output), I describe locators as **column ordinals**:

```text
<sql-result-path> := "[" columnOrdinal "]"
```

However, there is a real index-base ambiguity I flag explicitly:

- In SQL Server syntax, an integer like `ORDER BY 2` refers to the **position of the column in the select list**, which is effectively **1-based** (“non-negative integer representing the position of the column in the select list”). 
- In .NET data readers, column ordinals passed to `GetValue(ordinal)` are **zero-based** (“The zero-based column ordinal”).  

So: I treat SQL result ordinals as **1-based in this spec for human-facing workflow references**, but I require verification in the Binding Tree / activity output structure before assuming. 

## Indexing conventions, quoting, and escaping

### Index bases and defaults

- HL7: indexes exist for repeated segments/fields/components; if omitted, the first instance is assumed. Integration Soup examples show `OBX[2]`, which strongly suggests a 1-based “second segment” convention, but the product docs do not spell out the base in one line—so I rely on examples + workflow behavior (validate in the binding tree). 
- XML/JSON simplified XPath: I treat `[n]` as **1-based**, matching W3C XPath’s positional predicate model.
- CSV: **0-based** by definition in Integration Soup.
- SQL results: **declared 1-based in this reference** but explicitly ambiguous vs underlying APIs; confirm.

### Escaping / structure safety

By default, Integration Soup mappings and SetValueAtPath-style writes **encode/escape reserved structure characters** so inserted data does not corrupt the destination message format.

Key canonical rules:
- In the Workflow Designer, leaving “Allow message structure to change” **unchecked** means reserved characters (e.g., `&` in XML, HL7 structure chars) are automatically escaped; checking it allows raw structure-altering text.
- Integration Soup’s API-level distinction is:
  - `SetValueAtPath`: sets a value and automatically encodes for the message type (example given: `<` becomes `&lt;` in XML).
  - `SetStructureAtPath`: writes raw text and can change message structure. 

HL7-specific escaping (canonical):
- Integration Soup defines helper behavior mapping HL7 escapes: `\F\ ↔ |`, `\S\ ↔ ^`, `\R\ ↔ ~`, `\T\ ↔ &`, `\E\ ↔ \`. 
- HL7 v2 references describe delimiter characters and that MSH defines them for the message. 

CSV-specific escaping (canonical):
- If a value contains commas, it will corrupt CSV unless encoded/quoted; Integration Soup tutorials call out using CSV Encode to wrap such values safely in quotes. 

## Cross-activity references, variables, and write constraints

### Referencing other activities

In the designer, the **Source Path** field has an anchor selector that lets me pick which activity the locator is reading from (and there is a source selector above the binding tree). It defaults to the receiver’s inbound message, but can be changed to any previous activity or “Text and variables.” 

For AI instructions or written specs, I represent this choice as:

- `'Activity Name' <Locator>`

This is my textual, compact equivalent of choosing the activity via the anchor dropdown.

### Variable syntax

Variables are the core mechanism for reusing values across bindings, mappings, filenames, payloads, parameters, and other settings. 

Canonical variable placeholder:
- `${VarName}` is explicitly documented as the “insert into text/settings” syntax in Integration Soup’s coding reference (and is widely used in templates). 

Important compatibility note I keep in mind:
- Some UI fields (notably file-path related examples) also document `$(VariableName)` as an insertion format.

### Writing/mapping constraints I enforce

Transformers run **before** the activity executes and exist to manipulate:
- the **current activity’s outbound message** (its Message Template instance), and/or
- workflow variables.

Transformers cannot manipulate an activity response message that does not exist yet at transformer execution time.

Therefore, my hard rule for AI-generated mapping instructions is:

- **Write targets may be only** (a) workflow variables, or (b) **the current activity’s message**. I do not claim to “update another activity’s message”; instead I read from that activity as a source and write into the current activity’s destination message/variables.

## Canonical compact examples

These are deliberately compact and canonical. When I say “from X to Y,” it implies: **choose source activity (if needed) + locator**, then map into **current activity destination locator** or variable.

1) **HL7 read (receiver default source)**  
Read patient ID component: `PID-3.1`.

2) **HL7 cross-activity read (text shorthand)**  
Read from a prior activity named `Normalize`: `'Normalize' PID-3.1`. (Equivalent to selecting `Normalize` in the Source Path anchor.) 

3) **HL7 write (mapping transformer into current message)**  
Map `PID-2.1` → `PID-3.1` (current activity message), e.g., “If PID-3 missing, map PID-2 to Patient ID.”

4) **HL7 filter**  
Execute only if `MSH-9.2 == "S12"`.

5) **Set variables from message paths**  
Set `${PatientID}` from `PID-3.1`; set `${Sex}` from `PID-8`.

6) **XML/JSON read**  
Read `Patient/Demographics/Name/First`.

7) **XML/JSON attribute read**  
Read `Patient/ID/@type` (attribute form).

8) **CSV read/write**  
Read column 0: `[0]`; write to column 2: `[2]`. (0-based columns.) 

9) **DB parameter binding**  
SQL: `INSERT INTO Studies (PatientID) VALUES (@PatientID)` and bind `@PatientID` from a path (drag from bindings). 

10) **HTTP argument / query string**  
Use message data + URL structure/query string; e.g., append `?PatientID=${PatientID}` to an HTTP call/endpoint configuration.

## Syntax comparison table and source→transformer→destination flowchart

I include this table so an AI can quickly choose the correct syntax without inventing new separators.

| Message type | Canonical locator shape | Key tokens | Index base (canonical) |
|---|---|---|---|
| HL7 | `SEG[idx]-FIELD[rep].COMP.SUB` | `-` field, `.` components, `[...]` repeats | Treat as 1-based, first implied when omitted (validate) |
| XML/JSON | `A/B/C[n]/@attr` | `/` hierarchy, `[n]` position, `@` attribute | 1-based (XPath model) |
| CSV | `[col]` | `[...]` column ordinal | 0-based |
| SQL result | `[col]` | `[...]` column ordinal | Declared 1-based here, but ambiguous—confirm |

Supporting references for the table’s rules: HL7/XML/JSON/CSV path definitions in Integration Soup docs, XPath attribute shorthand and position semantics, plus SQL Server ordinal-in-ORDER-BY vs .NET zero-based ordinals.

```mermaid
flowchart LR
  A[Source Activity\n(Receiver default or selected via anchor)] --> B[Locator\n(HL7 / XML-JSON / CSV / SQL)]
  B --> C[Transformer\n(Map / Set Variable / Filter)]
  C --> D[Destination\n(Current activity message path\nor workflow variable)]
```

The “Source Activity” selection is the anchor/button behavior described in the Workflow Designer tutorial; transformers execute before the activity and operate on the current activity message and variables.