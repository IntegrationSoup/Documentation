# IMessage in Integration Soup
**Definitive API Guide**

`IMessage` is the common runtime contract for all message objects in Integration Soup (`IHL7Message`, `IXmlMessage`, `IJsonMessage`, `ICsvMessage`, `ITextMessage`, `IDicomMessage`).

If you are writing Code Transformers or Custom Activities, this is the lowest-level API that always exists.

For canonical workflow JSON enum mappings used by sender/receiver settings, see [Workflow Enum and Interface Reference](../reference/workflow-enums-and-interfaces.md).

---

## Interface contract

```csharp
public interface IMessage : IDisposable
{
    string Text { get; }
    string GetValueAtPath(string path);
    void SetValueAtPath(string toPath, string fromValue);
    void SetStructureAtPath(string toPath, string fromValue);
    void SetText(string text);
}
```

---

## What each method means

### `Text`
Returns the current full message text representation.

Important:
- representation depends on concrete message type
- may not match original input formatting exactly after parsing/rebuild

### `GetValueAtPath(path)`
Reads a value using that message type’s path syntax.

Important:
- path syntax is message-type specific
- missing paths usually return `""` (empty string), not exceptions

### `SetValueAtPath(path, value)`
Sets a value at path with type-specific encoding/normalization rules.

Important:
- this is usually the safe choice for business values
- behavior for missing paths varies by message type

### `SetStructureAtPath(path, value)`
Sets raw structure at path (nodes/segments/fragments), not just scalar values.

Important:
- this can replace full structural elements
- encoding rules differ from `SetValueAtPath`

### `SetText(text)`
Replaces entire message content.

Important:
- this resets the current parsed structure to the new payload

### `Dispose()`
Releases message resources if needed by implementation.

---

## Path behavior by message type

`IMessage` is polymorphic. The exact path engine depends on concrete type.

## `IHL7Message` (`HL7V2MessageType`)
- path examples: `PID-3.1`, `OBX[2]-5.2`
- `GetValueAtPath` returns decoded HL7 values
- `SetValueAtPath` HL7-encodes input first (safe for `| ^ & ~` etc)
- `SetStructureAtPath` writes raw HL7 structure text and can expand message as needed

## `IXmlMessage` (`XMLMessage`)
- default path style is slash segments (`Root/Node[1]/Child`)
- supports explicit xpath mode with `xpath:` prefix
- `GetValueAtPath` returns node `InnerText`
- `SetValueAtPath` sets node `InnerText`
- `SetStructureAtPath` can replace entire document node or replace a child node with raw XML structure

## `IJsonMessage` (`JSONMessage`)
- slash path style with optional indexes (`OrderItems[1]/Code`)
- alternative selector mode via `newtonsoft:` prefix
- `GetValueAtPath` returns scalar value text
- `SetValueAtPath` replaces token with scalar token
- `SetStructureAtPath` replaces token with raw JSON fragment

## `ICsvMessage` (`CSVMessage`)
- path is zero-based column index (`0`, `1`, `2`, ...)
- `GetValueAtPath` returns field value or `""`
- `SetValueAtPath` updates existing index only (does not auto-expand columns)
- `SetStructureAtPath` assigns raw field text at existing index only

## `ITextMessage` (`TextMessage`)
- path is effectively ignored
- `GetValueAtPath` returns full text
- `SetValueAtPath` replaces full text
- `SetStructureAtPath` behaves same as `SetValueAtPath`

## Binary message (`BinaryMessage`)
- same practical path behavior as text
- payload semantics are caller-defined (typically base64 text transport)

## `IDicomMessage` (`DicomMessage`)
- extends JSON behavior (`IJsonMessage`) for tag/content traversal
- also exposes DICOM-specific methods:
  - `GetXml()`
  - `GetJson()`
  - `GetBase64EncodedDicom()`

---

## How message objects are created at runtime

Message creation is mapped by `FunctionHelpers.GetFunctionMessage(...)`:

- `HL7V2` -> `HL7V2MessageType`
- `XML` -> `XMLMessage`
- `CSV` -> `CSVMessage`
- `JSON` -> `JSONMessage` (or `JSONMessageAsXMLMessage` if global setting enables it)
- `SQL` -> `TextMessage`
- `Text` -> `TextMessage`
- `Binary` -> `BinaryMessage`
- `DICOM` -> `DicomMessage`

Practical consequence:
- `MessageType` setting determines which path engine your `IMessage` instance will use.

---

## Usage patterns

### Safe generic usage (any message type)

```csharp
IMessage msg = activityInstance.Message;
string current = msg.Text;
msg.SetText(current);
```

### Type-safe usage (recommended)

```csharp
IHL7Message hl7 = CurrentHL7;
hl7.SetValueAtPath("PID-5.1", "John");
```

### Structure replacement usage

```csharp
IXmlMessage xml = CurrentXml;
xml.SetStructureAtPath("Order", "<Order><Id>123</Id></Order>");
```

---

## Non-obvious outcomes

- `IMessage` does not provide one universal path syntax.
- `SetValueAtPath` and `SetStructureAtPath` are intentionally different; mixing them incorrectly can corrupt structure.
- Some implementations silently no-op on missing paths/indexes instead of throwing.
- JSON may run through XML-backed behavior if `ProcessJsonAsXML` is enabled globally.
- For `Text` and `Binary`, path operations are effectively whole-message operations.

---

## When to cast beyond `IMessage`

Cast to specialized interfaces when you need:

- segment/field/component APIs (`IHL7Message`)
- child node/token traversal (`IXmlMessage`, `IJsonMessage`)
- text append semantics (`ITextMessage`)
- DICOM extraction helpers (`IDicomMessage`)

If you only need replace/read full payload, `IMessage` is enough.

---

## Related docs

- [IHL7Message Guide](./Ihl7message.md)
- [IWorkflowInstance & IActivityInstance Guide](./workflowinstance.md)
- [CodeContext Guide](./codingcontext.md)
