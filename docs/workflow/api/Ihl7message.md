# IHL7Message and the HL7 Message Object Model in Integration Soup  
**The Definitive Guide**  
*Version 1.0 • February 2026*

This is the **complete reference** for working with HL7 v2 messages using the `IHL7Message` interface and its component hierarchy (`IHL7Segment`, `IHL7Field`, `IHL7Component`, `IHL7SubComponent`).

Everything you need to **read**, **modify**, **add**, **remove**, **loop**, and **validate** HL7 messages in Code Transformers or Custom Activities is here.

---

## Table of Contents
- [1. Overview of the HL7 Object Model](#1-overview-of-the-hl7-object-model)
- [2. IHL7Message – The Main Interface](#2-ihl7message--the-main-interface)
- [3. Path Navigation System](#3-path-navigation-system)
- [4. IHL7Segment – Working with Segments](#4-ihl7segment--working-with-segments)
- [5. IHL7Field – Working with Fields & Repeats](#5-ihl7field--working-with-fields--repeats)
- [6. IHL7Component & IHL7SubComponent](#6-ihl7component--ihl7subcomponent)
- [7. BeginUpdate / EndUpdate – Performance Critical](#7-beginupdate--endupdate--performance-critical)
- [8. Looping Through Messages](#8-looping-through-messages)
- [9. Adding & Removing Segments](#9-adding--removing-segments)
- [10. Reading & Writing Values](#10-reading--writing-values)
- [11. Real-World Code Examples](#11-real-world-code-examples)
- [12. Best Practices & Gotchas](#12-best-practices--gotchas)
- [13. Quick Cheat Sheet](#13-quick-cheat-sheet)

---

## 1. Overview of the HL7 Object Model

Integration Soup represents every HL7 message as a **tree** of parts:

```
IHL7Message
  └─ IHL7Segment (PID, OBX[1], OBX[2], ...)
      └─ IHL7Field (PID-5, OBX-5, ...)
          └─ IHL7Component (PID-5.1, OBX-5.2, ...)
              └─ IHL7SubComponent (PID-5.1.1, ...)
```

All interfaces inherit from `IHL7Part` (which has `Text` and `SetText`).

**Strongly-typed access** in Code Transformers:
```csharp
IHL7Message hl7 = CurrentHL7;   // throws clear exception if not HL7
```

---

## 2. IHL7Message – The Main Interface

```csharp
public interface IHL7Message : IHL7Part, IMessage
{
    IHL7Segments GetSegments();
    IHL7Segments GetSegments(string header);        // e.g. "OBX"
    IHL7Segment GetSegment(string locationCode);    // "PID", "OBX[2]"
    void AddSegment(IHL7Segment segment);
    void AddSegment(string segmentText);            // supports \r separated
    IHL7Part GetPart(string path);                  // "OBX-5.2"
    void RemoveSegment(IHL7Segment segment);
    void BeginUpdate();
    void EndUpdate();
    string ValidateWithHighlighters(string profileName);
    bool ValidatesWithHighlighters(string profileName);
}
```

**Key implementation notes** (from `HL7V2MessageType`):
- Internally uses a high-performance `Message` parser with lazy loading
- `BeginUpdate()` / `EndUpdate()` suspends reloads for bulk changes
- `SetValueAtPath` automatically calls `HL7Encode`
- `SetStructureAtPath` injects raw text (no encoding)

---

## 3. Path Navigation System

All HL7 access uses **path strings** parsed by `PathSplitter`:

**Examples**
- `"PID"` → segment
- `"PID-5"` → field
- `"PID-5.1"` → component
- `"PID-5.2.1"` → subcomponent
- `"OBX[2]-5.1"` → second OBX, first component of field 5
- `"MSH-9.1"` → message type

**Supported syntax**
- Segment: `PID`, `OBX[3]`
- Field: `PID-3`, `OBX[2]-5[1]`
- Component: `PID-5.1`
- Subcomponent: `PID-5.1.2`

**Tip**: Always use the full path when possible — faster than navigating step-by-step.

---

## 4. IHL7Segment – Working with Segments

```csharp
public interface IHL7Segment : IHL7Part
{
    IHL7Fields GetFields();
    IHL7Field GetField(int fieldLocation);
    IHL7Field GetField(int fieldLocation, int repeatIndex);
    IHL7Field GetField(string locationCode);
    string Header { get; }           // "PID", "OBX"
    string LocationCode { get; }     // "PID", "OBX[2]"
    string GetPath();                // same as LocationCode for segments
}
```

**Implementation behaviour**:
- `Header` is always the first 3 characters
- `LocationCode` includes repeat index for repeating segments
- Fields are lazily loaded

---

## 5. IHL7Field – Working with Fields & Repeats

```csharp
public interface IHL7Field : IHL7Part
{
    IHL7Components GetComponents();
    IHL7Component GetComponent(int componentLocation);
    IHL7Component GetComponent(int componentLocation, int repeatIndex);
    IHL7Component GetComponent(string locationCode);
    ICollection<IHL7Field> GetRelatedRepeatFields();
    ICollection<IHL7Field> GetRelatedRepeatFields(bool excludeCurrent);
    bool IsFieldRepeated { get; }
    string LocationCode { get; }     // "5" or "5[2]"
    void SetTextEncoded(string text);   // RECOMMENDED for fields
}
```

**Repeat fields**:
- Repeating fields share the same `LocationCode` without index (e.g. `"PID-3"`)
- Use `GetRelatedRepeatFields()` to get all repeats including/excluding current
- `IsFieldRepeated` tells you if siblings exist

---

## 6. IHL7Component & IHL7SubComponent

```csharp
public interface IHL7Component : IHL7Part
{
    IHL7SubComponents GetSubComponents();
    IHL7SubComponent GetSubComponent(int subComponentLocation);
    IHL7SubComponent GetSubComponent(string locationCode);
    string GetSubComponentValue(int subComponentLocation);
    void SetTextEncoded(string text);
}

public interface IHL7SubComponent : IHL7Part
{
    string LocationCode { get; }
    string GetPath();
    void SetTextEncoded(string text);
}
```

**Note**: Most real-world work stops at `Component`. Subcomponents are rarely needed.

---

## 7. BeginUpdate / EndUpdate – Performance Critical

**Always** use this pattern for multiple changes:

```csharp
hl7.BeginUpdate();

hl7.SetValueAtPath("PID-3.1", "NEWID");
hl7.SetValueAtPath("PID-5.1", "John");
hl7.SetValueAtPath("PID-5.2", "Doe");
hl7.AddSegment("OBX|1|ST|...");

hl7.EndUpdate();   // triggers single reload
```

Without `BeginUpdate`/`EndUpdate`, every `Set*` call triggers a full message rebuild — **very slow** for large messages.

---

## 8. Looping Through Messages

```csharp
IHL7Message hl7 = CurrentHL7;

// All segments
foreach (IHL7Segment seg in hl7.GetSegments())
{
    if (seg.Header == "OBX")
    {
        string value = seg.GetFieldValue(5);
        // ...
    }
}

// Specific header
foreach (IHL7Segment obx in hl7.GetSegments("OBX"))
{
    string observation = obx.GetFieldValue(5);
}
```

**Looping fields in a segment**:
```csharp
IHL7Segment pid = hl7.GetSegment("PID");
foreach (IHL7Field field in pid.GetFields())
{
    Console.WriteLine($"{field.LocationCode}: {field.Text}");
}
```

---

## 9. Adding & Removing Segments

```csharp
// Add from string (most common)
hl7.AddSegment("OBX|1|ST|TEST^Result||123||");

// Add from existing segment object
IHL7Segment newObx = ...;
hl7.AddSegment(newObx);

// Remove
IHL7Segment badObx = hl7.GetSegment("OBX[3]");
hl7.RemoveSegment(badObx);
```

---

## 10. Reading & Writing Values

### Safe writing (auto-encoding)
```csharp
hl7.SetValueAtPath("PID-5.1", "Smith&Jones");   // becomes Smith\T\Jones
```

### Raw structure injection
```csharp
hl7.SetStructureAtPath("OBX[2]", "OBX|2|ST|...|raw text with | ^ &");
```

### Field-level encoded set (recommended)
```csharp
IHL7Field nameField = pid.GetField(5);
nameField.SetTextEncoded("O'Connor^John");
```

---

## 11. Real-World Code Examples

### Example 1: Update Patient Name with Proper Encoding
```csharp
IHL7Message hl7 = CurrentHL7;
IHL7Segment pid = hl7.GetSegment("PID");

pid.GetField(5).SetTextEncoded(GetVariable("LastName"));
pid.GetField(5, 1).SetTextEncoded(GetVariable("FirstName"));  // repeat 1
```

### Example 2: Add Multiple OBX Segments
```csharp
hl7.BeginUpdate();
hl7.AddSegment("OBX|1|ST|HEIGHT^Height||180|cm");
hl7.AddSegment("OBX|2|ST|WEIGHT^Weight||75|kg");
hl7.EndUpdate();
```

### Example 3: Remove All OBX Segments Except First
```csharp
var obxs = hl7.GetSegments("OBX").ToList();
for (int i = 1; i < obxs.Count; i++)
{
    hl7.RemoveSegment(obxs[i]);
}
```

### Example 4: Loop and Transform All OBX-5 Values
```csharp
foreach (IHL7Segment obx in hl7.GetSegments("OBX"))
{
    string value = obx.GetFieldValue(5);
    obx.GetField(5).SetTextEncoded(value.ToUpper());
}
```

---

## 12. Best Practices & Gotchas

1. **Always** use `BeginUpdate()` / `EndUpdate()` for 2+ changes.
2. Prefer `SetValueAtPath` or `SetTextEncoded` — they handle HL7 escaping automatically.
3. Use `GetSegment("OBX[2]")` instead of looping when you know the repeat index.
4. `GetRelatedRepeatFields()` is the correct way to handle repeating fields.
5. `SetStructureAtPath` bypasses encoding — use only when you know what you're doing.
6. `GetValueAtPath` returns decoded text (HL7 escapes removed).
7. `GetStructureAtPath` returns raw text (with escapes preserved).
8. Never modify `.Text` directly — always use the Set* methods.
9. `LocationCode` for repeating segments/fields includes `[n]`.

---

## 13. Quick Cheat Sheet

```csharp
IHL7Message hl7 = CurrentHL7;

// Read
string pid = hl7.GetValueAtPath("PID-3.1");
string obx = hl7.GetSegment("OBX[1]").GetFieldValue(5);

// Write safely
hl7.SetValueAtPath("PID-5.1", "Smith&Jones");

// Add
hl7.AddSegment("OBX|1|ST|...");

// Loop
foreach (var seg in hl7.GetSegments("OBX")) { ... }

// Bulk
hl7.BeginUpdate(); ... hl7.EndUpdate();

// Field-level
pid.GetField(5).SetTextEncoded("O'Connor");

// Part
IHL7Part part = hl7.GetPart("OBX-5.2");
```
