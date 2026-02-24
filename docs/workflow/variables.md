# Variables in Integration Soup Workflows  
**The Definitive Guide**  
*Version 1.1 • February 2026*


---

## Table of Contents
- [1. What Are Variables?](#1-what-are-variables)
- [2. The `${}` Syntax](#2-the--syntax)
- [3. All Built-in System Variables](#3-all-built-in-system-variables)
- [4. Creating & Updating Variables](#4-creating--updating-variables)
- [5. Runtime Formatting & Modifiers](#5-runtime-formatting--modifiers)
- [6. Using Variables in C# Code Transformers](#6-using-variables-in-c-code-transformers)
- [7. The Special `DATATABLE` Variable](#7-the-special-datatable-variable)
- [8. JSON Serialization](#8-json-serialization)
- [9. Transformers That Use Variables](#9-transformers-that-use-variables)
- [10. Best Practices & Gotchas](#10-best-practices--gotchas)
- [Quick Cheat Sheet](#quick-cheat-sheet)

---

## 1. What Are Variables?

A **variable** is a named piece of data that lives for the entire lifetime of **one workflow instance**.


**Three kinds** (see `VariableTypes` enum):

| Type       | Scope                          | Persisted? |
|------------|--------------------------------|------------|
| **Workflow**   | Only this run                  | No         |
| **Global**     | All workflows on the server    | Yes        |
| **System**     | Built-in (read-only)           | N/A        |

---

## 2. The `${}` Syntax

Used **everywhere** — messages, paths, text fields, filters, etc.

```text
${VariableName}
${VariableName:Format}
${VariableName:Modifier1:Modifier2:Format}
```

**Real examples:**

```text
${PatientID}
${ReceivedDate:yyyy-MM-dd}
${TotalAmount:Truncate(8):Padding(10)}
${FullName:LowerCase:Replace( ,_)}
${UUID}
${CurrentDateTime:yyyyMMddHHmmss}
```


---

## 3. All Built-in System Variables

### A. Always available
| Variable Name              | Returns                          | Example Output          |
|---------------------------|----------------------------------|-------------------------|
| `CURRENTDATETIME`         | Server time now                  | `20260225113945`        |
| `RECEIVEDDATE`            | Time message arrived             | `20260225113800`        |
| `WORKFLOWINSTANCEID`      | Instance counter (int)           | `1423`                  |
| `UUID`                    | Fresh GUID                       | `a1b2c3d4-...`          |
| `WORKFLOWERROR`           | `"True"` / `"False"`             | `True`                  |
| `WORKFLOWERRORMESSAGE`    | Error text                       | `Invalid PID-3`         |
| `MLLPSTART`               | VT char                          | `\x0B`                  |
| `MLLPEND`                 | FS+CR                            | `\x1C\x0D`              |
| `CR` / `LF`               | Carriage return / Line feed      | `\r` / `\n`             |
| `DATATABLE`               | Special data table access        | (see section 7)         |
| `ForEachIterator`         | 1-based loop counter             | `5`                     |

### B. Directory Scanner provided
| Variable Name              | Returns                              | Example Output          |
|---------------------------|--------------------------------------|-------------------------|
| `DirectoryScannerFileName`| Name and extension of currently file | `SampleValue.txt`       |     

### C. HTTP Reciever provided
| Variable Name              | Returns                             | Example Output          |
|---------------------------|-------------------------------------|-------------------------|
| `HttpMethod`         | Method - GET,POST, PUT etc               | `POST`                  |   
| `ClientIP`           | IP address of the caller                 | `127.0.0.1`             | 

### D. Timer provided
| Variable Name              | Returns                              | Example Output          |
|---------------------------|--------------------------------------|-------------------------|
| `PostExecutionFilter     `| Hide from logs if set to true        | `false`                 |    
---

## 4. Creating & Updating Variables

### A. Visual Designer – “Set Variable Value” Transformer


**Key fields:**
- `VariableName`
- `SampleVariableValue` + `SampleValueIsDefaultValue`
- Source (`FromPath`, `FromSetting`, `FromDirection`, `FromType`)

### B. In Code Transformer

```csharp
workflowInstance.SetVariable("PatientFullName", "John Doe");
SetVariable("OrderStatus", "Completed");   // shortcut via CodeContext

string id = GetVariable("PatientID");
```

---

## 5. Runtime Formatting & Modifiers

**Order of processing** (every time the variable is **read**):

1. Custom .NET format  
2. Text case (`LowerCase`, `UpperCase`, `TitleCase`, `McNameCase`)  
3. Truncation / Trim  
4. Remove → Replace → Lookup  
5. Padding  
6. Encoding (`HL7Encode`, `JSONEncode`, `Base64Encode`, etc.)

**Full modifier list** is in the original guide (section 2.2).

---

## 6. Using Variables in C# Code Transformers

```csharp
// Full CodeContext access
string name = GetVariable("FirstName");
SetVariable("FullName", name + " Smith");

DataTable.GetValue("Patients", "DOB");
string gender = Lookup("GenderMap", "M");
```


---

## 7. The Special `DATATABLE` Variable

```text
${DATATABLE>Patients.FirstName}   // advance row then read
${DATATABLE?Patients.RandomField} // random row
```

Full methods also available on `DataTable` proxy in code.

---

## 8. JSON Serialization Example

```json
{
  "VariableName": "PatientFullName",
  "FromPath": "${FirstName} ${LastName}",
  "SampleVariableValue": "John Doe",
  "SampleValueIsDefaultValue": true,
  "TextFormat": "TitleCase",
  "Truncation": "Truncate",
  "TruncationLength": 30
}
```

---

## 9. Transformers That Use Variables

- `CreateVariableTransformerAction` → create/update
- `CreateMappingTransformerAction` → read from variables
- `CodeTransformerAction` → full C# power
- `ForEachTransformerAction` → auto-creates `ForEachIterator`
- **All** activities that accept text (senders, receivers, filters, etc.)

---

## 10. Best Practices & Gotchas

- Variable names are **case-insensitive** internally (`PatientId` = `PATIENTID`)
- Formatting is applied **on read**, not on write
- Always give good `SampleVariableValue`
- Use Code Transformer for complex logic
- Setting `WORKFLOWERROR` to `true` forces error state

---

## Quick Cheat Sheet

```text
Set:          Set Variable transformer or SetVariable("Name", value)
Read:         ${Name:UpperCase:Truncate(20)}
System date:  ${CurrentDateTime:yyyy-MM-dd}
New GUID:     ${UUID}
Force error:  SetVariable("WorkflowError", "true")
```


