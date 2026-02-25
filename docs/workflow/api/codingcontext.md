```markdown
# C# Code Transformers in Integration Soup  
**The Definitive Guide**  
*Version 1.0 • February 2026*

This is the **complete reference** for writing C# code inside Integration Soup workflows using the **Code Transformer**.

Everything you need to know — the `CodeContext`, helpers, message handling, variables, notifications, data tables, HL7-specific functions, extensions, and real-world patterns — is here.

---

## Table of Contents
- [1. Introduction](#1-introduction)
- [2. The Code Transformer](#2-the-code-transformer)
- [3. The CodeContext Object](#3-the-codecontext-object)
- [4. Available Helpers & Extensions](#4-available-helpers--extensions)
- [5. Working with Messages](#5-working-with-messages)
- [6. Variables](#6-variables)
- [7. Notifications](#7-notifications)
- [8. Data Tables](#8-data-tables)
- [9. HL7-Specific Helpers](#9-hl7-specific-helpers)
- [10. String Extensions](#10-string-extensions)
- [11. Full Working Examples](#11-full-working-examples)
- [12. Best Practices & Gotchas](#12-best-practices--gotchas)
- [13. Quick Cheat Sheet](#13-quick-cheat-sheet)

---

## 1. Introduction

The **Code Transformer** lets you write arbitrary C# code that runs at any point in your workflow.  
It is the most powerful transformer in Integration Soup and gives you full access to:

- The current workflow state (`workflowInstance`)
- The current activity (`activityInstance`)
- All previous activities
- Messages (HL7, XML, JSON, CSV, etc.)
- Variables
- Data tables
- Notifications
- Lookup tables
- And every helper function built into the platform

---

## 2. The Code Transformer

**Location in designer:**  
Transformers → Add → **Code**

**Key properties:**

- `Comment` – one-line description (shown in the UI)
- `Code` – the actual C# script (default template provided)

The code is compiled at **Prepare** time using Roslyn.  
Any compilation error is shown immediately.

The script runs inside a `CodeContext` instance.

---

## 3. The CodeContext Object

You have **two** ways to access the context:

```csharp
// 1. Direct property (always available)
workflowInstance.SetVariable("MyVar", "hello");

// 2. Strongly-typed shortcuts (recommended – cleaner intellisense)
SetVariable("MyVar", "hello");
GetVariable("PatientID");
```

### Core Properties & Methods (from `CodeContext` and `ICodeContext`)

| Member                        | Type                  | Description |
|-------------------------------|-----------------------|-----------|
| `workflowInstance`            | `IWorkflowInstance`   | Full workflow state |
| `activityInstance`            | `IActivityInstance`   | Current activity |
| `CurrentActivity`             | `IActivityInstance`   | Shortcut to current |
| `Receiver()`                  | `IActivityInstance`   | First activity (receiver) |
| `GetActivity(Guid)`           | `IActivityInstance`   | By GUID |
| `GetActivity(int)`            | `IActivityInstance`   | By index (0 = receiver) |
| `GetActivity(string)`         | `IActivityInstance`   | By name / GUID / index |
| `GetActivities()`             | `List<IActivityInstance>` | All executed activities |
| `CreateMessage(...)`          | `IMessage`            | New message (HL7, XML, etc.) |
| `GetVariable(string)`         | `string`              | Read variable |
| `SetVariable(string, string)` | `void`                | Write variable |
| `Lookup(string, string)`      | `string`              | Lookup table |
| `Notification`                | `INotificationProxy`  | Dashboard notifications |
| `DataTable`                   | `IDataTableProxy`     | Data table operations |
| `Default(value, default)`     | `string`              | Null/empty coalescing |
| `TitleCase(string)`           | `string`              | Title case |
| `McNameCase(string)`          | `string`              | McDonald / LeBlanc casing |

---

## 4. Available Helpers & Extensions

All helpers are in the `HL7Soup.Integrations.CodeTemplates` namespace (already imported).

### 4.1 Helpers class

- `TitleCase(string)`
- `McNameCase(string)`
- `CamelCaseToText(string)`
- `Base64Encode(string)` / `Base64Decode(string)`
- `CSVEncode(string)`
- `XMLEncode(string)` / `XMLDecode(string)`
- `HL7Encode(string)` / `HL7Decode(string)`
- `HL7QuotesEncode(string)` / `HL7QuotesDecode(string)`

### 4.2 HL7Helpers class

- `GetDateFromHL7Date(string)` → `DateTime`
- `GetHL7Date(string)` / `GetHL7Date(DateTime)` / `GetHL7Date(DateTime, format)`
- `HL7Encode(...)` / `HL7Decode(...)` (duplicates of Helpers for convenience)

### 4.3 StringExtensions (extension methods – **most useful**)

```csharp
"john doe".Title();           // "John Doe"
"john doe".McName();          // "John Doe" (uses McNameCase)
"".Default("N/A");            // "N/A"
"McDonald".McName();          // "McDonald"
```

---

## 5. Working with Messages

```csharp
// Strongly-typed access (throws helpful exception if wrong type)
IHL7Message hl7 = CurrentHL7;
IXmlMessage xml = CurrentXml;
IJsonMessage json = CurrentJson;
ICsvMessage csv = ReceivedCsv;

// Generic access
IMessage msg = activityInstance.Message;

// Create new message
IHL7Message newHL7 = (IHL7Message)CreateMessage(MessageTypes.HL7, "MSH|^~\\&|...");

// Or with options
// CreateMessage(MessageTypes.HL7, text, options);
```

Common operations (available on all `IMessage` types):

- `GetValueAtPath(string path)`
- `SetValueAtPath(string path, string value)`
- `GetStructureAtPath(string path)` (XML only)
- `SetStructureAtPath(...)`

---

## 6. Variables

```csharp
// Read
string pid = GetVariable("PatientID");
string name = GetVariable("FirstName") + " " + GetVariable("LastName");

// Write
SetVariable("FullName", name);
SetVariable("WorkflowError", "true");   // forces error state

// With formatting (same as ${} syntax)
string formatted = GetVariable("Total:0.00");   // works because GetVariable parses ${}
```

**Note:** `GetVariable` and `SetVariable` are **case-insensitive** internally.

---

## 7. Notifications

```csharp
Notification.Create("Patient processed successfully");
Notification.Create("Order failed", true, "OrderError");   // critical
Notification.Create("Info message", "UniquenessKey");
```

---

## 8. Data Tables

```csharp
// Proxy (clean intellisense)
string name = DataTable.GetValue("Patients", "FirstName");
string key = DataTable.GetKeyValue("Patients");

DataTable.MoveToNextRow("Patients");
DataTable.MoveToRandomRow("Patients");

int count = DataTable.GetRowCount("Patients");
bool exists = DataTable.ContainsRow("Patients", "PAT123");

List<string> fields = DataTable.GetFieldNames("Patients");
```

---

## 9. HL7-Specific Helpers

```csharp
DateTime dob = HL7Helpers.GetDateFromHL7Date(GetVariable("DOB"));
string hl7Date = HL7Helpers.GetHL7Date(DateTime.Now);

string safeName = HL7Helpers.HL7Encode("Smith^John");
string plain = HL7Helpers.HL7Decode(safeName);
```

---

## 10. String Extensions (recommended)

```csharp
string clean = GetVariable("Name").Default("Unknown").Title();
string mc = GetVariable("LastName").McName();
```

---

## 11. Full Working Examples

### Example 1: Complex Patient Name Processing
```csharp
string first = GetVariable("FirstName").Default("Unknown").Title();
string last = GetVariable("LastName").McName();

string full = $"{first} {last}";
SetVariable("PatientFullName", full);

CurrentHL7.SetValueAtPath("PID-5.1", first);
CurrentHL7.SetValueAtPath("PID-5.2", last);
```

### Example 2: Date Conversion + Notification
```csharp
DateTime received = HL7Helpers.GetDateFromHL7Date(GetVariable("ReceivedDate"));
string niceDate = received.ToString("dddd, MMMM dd yyyy");

Notification.Create($"Message received on {niceDate}", "DailySummary");
```

### Example 3: Data Table Loop Simulation
```csharp
DataTable.MoveToNextRow("Pricing");
string price = DataTable.GetValue("Pricing", "Amount");
SetVariable("CurrentPrice", price);
```

### Example 4: Create New Message & Send It
```csharp
IHL7Message ack = (IHL7Message)CreateMessage(MessageTypes.HL7, "MSH|^~\\&|...");
ack.SetValueAtPath("MSA-1", "AA");
ack.SetValueAtPath("MSA-2", GetVariable("MSH-10"));

workflowInstance.SetReponseMessage(ack);   // if in response path
```

---

## 12. Best Practices & Gotchas

1. **Always** use the shortcut methods (`GetVariable`, `SetVariable`, `CurrentHL7`, etc.) — cleaner and safer.
2. Use `.Default("…")` for every variable read that might be empty.
3. Prefer `Title()` and `McName()` extensions over calling `TitleCase()` / `McNameCase()`.
4. Cast to strongly-typed interfaces (`CurrentHL7`, `CurrentXml`) — you get compile-time safety + full intellisense.
5. `GetVariable("NonExistent")` returns `null` — always use `.Default()`.
6. Setting `WORKFLOWERROR` to `"true"` immediately marks the workflow as errored.
7. Code runs **per activity iteration** — be careful with loops.
8. All string operations are culture-invariant unless you explicitly use `CultureInfo`.
9. Use `Notification.Create(..., uniquenessCode)` to avoid spam on the dashboard.

---

## 13. Quick Cheat Sheet

```csharp
// Variables
SetVariable("Name", "value");
string v = GetVariable("Name").Default("N/A");

// Messages
IHL7Message hl7 = CurrentHL7;
hl7.SetValueAtPath("PID-5.1", "John");

// Helpers
"john".Title();           // "John"
"o'connor".McName();      // "O'Connor"
HL7Helpers.GetHL7Date(DateTime.Now);

// Notification
Notification.Create("Done!");

// DataTable
DataTable.GetValue("Table", "Field");
DataTable.MoveToNextRow("Table");

// Create message
var msg = CreateMessage(MessageTypes.HL7, "MSH|...");
```

**You now have the complete C# coding reference for Integration Soup.**

Save this file as **`Code-Transformers-Guide-Integration-Soup.md`**

Happy coding! 🚀

If you want:
- More examples
- A version with a downloadable template code file
- A “Cookbook” of 30 real patterns

…just say the word.
```