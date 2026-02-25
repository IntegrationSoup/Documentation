# Paths in Integration Soup Workflows

## Why paths matter

A **path** is the way you point to a specific value inside a message in a workflow. Anywhere the product needs to *read* data from a message, *write* data into a message, or *bind* a value to a setting/parameter, you’ll see paths (or UI fields that store a path behind the scenes). The message type determines the path syntax: HL7 uses segment/field/component style; XML/JSON use a simplified XPath-like style; CSV uses column ordinals.

Paths are used across the whole product—not just in code—especially in:

* **Bindings and Message Templates** (dragging values into templates creates bindings/variables driven by paths).
* **Transformers** (mapping, set-variable, conditions, loops).
* **Filters / conditional logic** (criteria commonly references paths like `MSH-9.2`).
* **Database work** (query parameters are bound to incoming message values; query can also return results to include in workflow processing).
* **HTTP work** (REST hosting/calling; values can come from message content *and* from URL segments/query string).

The foundational point: a “path” is not a vague instruction like “get the patient name.” It must be a locator that resolves to a precise element in the actual message structure.

## Mental model of a path in Integration Soup

In Integration Soup workflows, a usable “path reference” is really two things:

**A. Which activity’s message is the source of data**
**B. The message-type-specific locator string**

In the Workflow Designer, the **Source Path** field includes an **anchor control** that lets you select *which activity* the path is acquiring data from. That selection is part of the binding: the same locator string means something different depending on which activity/message is the source.

### Path vs literal text (and why “paths showing up in output” happens)

Many workflow fields can be treated either as:

* **A path bound to an activity** (UI indicated as green; red if invalid), or
* **Literal text + variables** (“Text and variables”, UI indicated as blue, variables shown in purple).

A classic failure mode is: you intended to bind a field to a message value, but the field is set to **Text and variables**, so the text you typed (which looks like a path) is inserted literally. The Workflow Designer tutorial explicitly calls this out: if you start seeing paths in outbound output, check that the source is actually an activity (via the anchor button) rather than “Text and variables.”

### Where mappings are allowed to write

Transformers run **inside an activity**, just before the activity executes, and are intended to manipulate that activity’s outbound message (its message template instance at runtime) and/or workflow variables.

This is why the practical rule is:

* You can map/set **variables**, and you can map/set **the current activity’s message**.
* You do not “edit another activity’s message directly”; instead you select that other activity as a *source*, and write into *your* activity’s message (or into variables) as the *destination*. This aligns with how the transformers model is described: mapping from a source tree to a destination tree, executed in the context of the current activity.

### A note on “default source”

By default, many workflows start with a receiving activity, and downstream activities often begin life **bound to the received message** unless you deliberately replace/rebuild the outgoing message template.

Operationally: if you’re referencing “the inbound message,” you are usually referencing the receiver’s message unless you’ve explicitly chosen another source via the anchor selector.

## Path syntax by message type

### HL7 paths

**Integration Soup’s HL7 path grammar** is described as:

```
Segment[RepeatSegmentIndex]-Field[RepeatFieldIndex].Component[RepeatComponentIndex].SubComponent
```

This aligns with the way HL7 v2 messages are structured: each message has segments (3-character IDs like `OBX`), segments contain fields (e.g., `OBX-5`), and fields can be composite with components (e.g., `OBX-5.2`).

**Examples (HL7):**

* `PID-5.2` → patient given name (component 2 of field 5 in PID).
* `PID-3.1` → first component of patient identifier list field (commonly used as “patient ID” by receiving systems).
* `MSH-9.2` → message trigger event is commonly referenced in filters (example shown filtering `MSH-9.2` equals `S12`).
* `OBX[2]-5.2` → component 2 of field 5 in the **second** OBX segment (segment repeats are indexed).

**Indexes for repeating segments/fields/components**
HL7 paths can include indexes for repeated segments or repeated fields; if indexes are omitted, the workflow designer documentation states that the first instance is assumed.

**How to discover HL7 paths quickly**
In the HL7 Soup editor, you can right-click on text inside an HL7 message and use **Copy Path** to copy its HL7 path.

**Reserved HL7 characters and safe writing**
HL7 v2 messages use delimiter characters (commonly `|`, `^`, `&`, `~`, `\`) to separate fields/components/subcomponents/repetitions, and these characters must not appear “raw” in data unless properly escaped/encoded.

Integration Soup supports automatic encoding when setting values, and the platform also documents explicit encoding/decoding helpers (e.g., converting `|` to `\F\`, `^` to `\S\`, etc.).


### XML and JSON paths

Integration Soup supports a **simplified XPath-like path** for both XML and JSON messages:

* Hierarchy steps separated by `/`
* Item indexes in square brackets (for repeating nodes / arrays)
* A final node starting with `@` represents an attribute (or attribute-like node)

The Workflow Designer tutorial explicitly groups **FHIR, XML and JSON** into this simplified XPath model and also notes that if you require strict .NET XPath, you can prefix the expression with `xpath:`.

This matches core XPath conventions—`/` is the path separator, and `@name` is abbreviated syntax for selecting an attribute named `name`.

**Indexing note (XPath convention)**
Classic XPath is **1-based** for positional predicates (e.g., `para[1]` selects the first `para` child).
Integration Soup describes its XML/JSON addressing as “simplified XPath,” so you should treat `[1]` as “first” in XML/JSON unless the Binding Tree for your concrete message indicates otherwise.

**Examples (XML/JSON):**

* `Patient/Demographics/Name/First`
* `Patient/ID/@type`
* `breakfast/food[2]/name`

**Mapping between HL7 and XML demonstrates the dual syntax**
In the HL7→XML tutorial transcript, mapping `PID-5.2` into an XML “First Name” field is described as producing HL7 syntax on one side and XPath representing the destination XML on the other.

### CSV paths

CSV paths are column ordinals in square brackets.

* Workflow Designer description: “A CSV path is just the index of the field in square brackets.”
* Coding cheat sheet is explicit about the base: “Just use the **0 based index** in a square bracket. E.g. `[0]` is the 1st and `[1]` is the 2nd item in the CSV.”

**Examples (CSV):**

* `[0]` → first CSV column
* `[3]` → fourth CSV column

### SQL query result paths

Integration Soup includes built-in database activities:

* **Database Query** can run SQL, and if you use a `SELECT`, it can retrieve results that you can include in your messages.
* Database activities emphasize parameter usage (to help avoid SQL injection) and UI workflows that bind message values to `@Parameters`.

**Binding values into SQL parameters**
When writing a Database Query, parameters (like `@PatientID`) appear and you can drag corresponding fields from the binding tree onto parameters.

For locating values in a returned single-row result, apply the same “column ordinal” concept as CSV: treat the returned row as a column list and address columns by position using bracketed ordinals (for example `[1]`, `[2]`, etc.). This is consistent with how SQL engines commonly refer to select-list positions (e.g., in `ORDER BY` you can specify a non-negative integer representing the position of the column in the select list).

Because CSV ordinals are **explicitly 0-based** in Integration Soup, while SQL in general commonly treats “column position” references as **1-based** (“first column”, “second column”), the safest operational approach is:

* Use the **Binding Tree / logs** to confirm what ordinal Integration Soup exposes for your database result output when you need to reference it by index. (Workflow logs can highlight the path used by a binding/transformer when you click a faulty binding in logs.)

## Using paths in workflow features

### Bindings and message templates

A **Message Template** is an example of the message structure you expect to receive/send; it doesn’t need real data—its purpose is to drive mapping and binding. When you paste a template, the Bindings panel is populated with a tree representing that structure.

When you drag fields from the Binding Tree into a template, the product often creates a variable placeholder and the transformers needed to set that variable “behind the scenes.” This is described explicitly in the Workflow Designer tutorial: dropping a binding into a message template creates a Set Variable transformer and inserts a variable placeholder into the message.

### Mapping transformers

Mapping transformers connect a **Source Path** (read) to a **To** path (write). The Workflow Designer calls out that these fields are populated with syntax representing where in the message to get and set values—and you can either drag from the trees or type paths like `PID-5.1`.

Two powerful behaviors matter for “definitive path usage”:

* **Paths do not need to already exist in the message template.** The docs explicitly show typed HL7 paths beyond the template (e.g., `PID-50`) as valid.
* If the **destination (“To”) path** doesn’t exist in the message template, Integration Soup can automatically append the required structure to support it.

This is also consistent with the message API behavior described in the coding cheat sheet: writing to an HL7 location that doesn’t exist expands the message with empty segments/fields so the location exists.

### Filters, conditions, and loops

Filters and conditionals use paths as operands within logical criteria—for example filtering only appointment messages by `MSH-9.2 = S12`.

The Workflow Designer supports complex criteria with AND/OR groupings; the tutorial describes adding multiple criteria arguments and grouping “like brackets.”

For repeating content, Integration Soup supports **For Each / Next** transformers to loop over repeated values (e.g., OBX segments). When inside a loop, any binding/mapping that references something in the loop item uses the iterated item’s value.

## Paths in integration surfaces

### Variables as the bridge between “path world” and “string/template world”

Workflow variables are a core technique for using path-located values in places that aren’t themselves “a path field”—for example, filenames, HTTP payloads, or (in some cases) DB connection strings.

* Variables can be inserted into messages and text settings using `${VariableName}` syntax and are replaced at runtime.
* Many activity properties can use variables; a tutorial example uses variables to build a file name from patient identifiers and names, pulled from HL7 paths like `PID-3`, `PID-5.1`, `PID-5.2`.

A JSON REST payload example shows the pattern clearly:

```json
{
  "PatientIdentifier": "${PatientID}",
  "StudyUID": "${StudyInstanceUID}",
  "Accession": "${AccessionNumber}"
}
```

### Database parameters and database connection values

Database Query supports parameterized SQL and visually mapping fields from inbound messages to those parameters.
The “What’s new” notes emphasize database activities and parameter mechanisms in the platform narrative.

Separately, release notes document that database sender connection strings can accept **variables and binding values** (with the caveat that certain receiver-side execution happens before variables are populated).

### HTTP arguments, URL structure, query string, and headers

Integration Soup supports both hosting and calling HTTP endpoints:

* HTTP Receiver can host REST services / FHIR endpoints, using data passed in message content, plus URL structure and query string.
* Integration Host’s cloud deployment page also describes “flexible REST services where values are passed as URL sections or query string arguments.”

Example URL (as shown in product materials):

```text
https://Server:8080/HL7Soup/Urology?PatientID=1000
```

Headers are also part of the HTTP surface area; release notes indicate headers can be added to HTTP senders, and specifically note that only the Receivers version supports bound values for headers.

For practice, treat URL path segments, query string parameters, and headers like any other bindable field: if it can be bound, it will have a path/variable strategy. Where Integration Soup exposes those values in a binding tree, use that tree (and Workflow Designer log highlighting) to confirm the exact path syntax for your particular workflow.

## Reliability rules: precision, escaping, and troubleshooting

### Precision rules that prevent ambiguous or fragile mappings

HL7 integration guides consistently describe addressing down to the component level (e.g., `OBX-5.2` denoting the second component of field 5 of `OBX`).
In practical workflow design, prefer “as specific as necessary” paths:

* Use components where composite fields exist (`PID-3.1`, `PID-5.2`, etc.).
* Use segment indexes where segments repeat (`OBX[2]...`).
* Use XML/JSON indexes where arrays/repeating nodes exist (`food[2]`).

### Escaping and “structure-safe” writing

Multiple sources underline that message formats have reserved structure characters (HL7 delimiters; XML `<` etc).
Integration Soup defaults to **encoding/escaping reserved characters** when setting values so the message structure is not corrupted, and it provides a UI checkbox (“Allow message structure to change”) for cases where you intentionally need to inject structure.

At the message-API level, the same concept is exposed as:

* `SetValueAtPath` (structured, encoded write)
* `SetStructureAtPath` (raw structural write)

### Debugging paths

When troubleshooting “wrong value mapped” or “path not found,” use product features that surface path/location:

* Workflow logs can highlight the current path in Message Template, Binding Tree, and Transformers when you click a faulty binding value.
* In the HL7 Soup editor, right-click > Copy Path speeds up correct HL7 path acquisition.
* Watch the binding color conventions (green = valid path binding; red = invalid path; blue = literal text/variables).

### Canonical examples for workflow instructions

The patterns below reflect how the product’s workflow model expects you to think about paths (source → destination), and they align with transformer/filter behaviors described in tutorials and release notes.

**Mapping transformer examples**

```text
Map the value from PID-3.1 to replace PID-3.1
Map the value from OBX[2]-5.2 to replace OBX[2]-5.2
Map the value from Patient/Demographics/Name/First to replace Patient/Name/First
Map the value from [2] to replace [0]
```

**Filter examples**

```text
Filter messages where MSH-9.2 equals 'S12'
Filter messages where PID-8.1 equals 'M' AND OBX[1]-5.1 contains 'POSITIVE'
```

**Variable setting examples**

```text
Set ${PatientID} from PID-3.1, ${Gender} from PID-8.1
Set ${FirstName} from Patient/Demographics/Name/First
Set ${CsvPatientId} from [0]
```

(Variable insertion uses `${VariableName}` syntax and is replaced at runtime.)
