# IWorkflowInstance & IActivityInstance in Integration Soup  
**The Definitive Guide – Message-Focused Edition**  
*Version 1.1 • February 2026*

This is the **complete reference** for the two core runtime interfaces, with **maximum emphasis on message handling**.

Everything you need to read, create, modify, and route messages using `IWorkflowInstance` and `IActivityInstance` is here.

---

## Table of Contents
- [1. Overview](#1-overview)
- [2. IWorkflowInstance – The Workflow Container](#2-iworkflowinstance--the-workflow-container)
- [3. IActivityInstance – One Executed Activity](#3-iactivityinstance--one-executed-activity)
- [4. Accessing Them in Code Transformers](#4-accessing-them-in-code-transformers)
- [5. Full Property & Method Reference – IWorkflowInstance](#5-full-property--method-reference--iworkflowinstance)
- [6. Full Property & Method Reference – IActivityInstance](#6-full-property--method-reference--iactivityinstance)
- [7. Working with Messages – The Core Focus](#7-working-with-messages--the-core-focus)
- [8. Variables (Message Manipulation Companion)](#8-variables-message-manipulation-companion)
- [9. Activity Lookup & Navigation](#9-activity-lookup--navigation)
- [10. Creating New Messages](#10-creating-new-messages)
- [11. Real-World Message Examples](#11-real-world-message-examples)
- [12. Best Practices & Gotchas](#12-best-practices--gotchas)
- [13. Quick Cheat Sheet](#13-quick-cheat-sheet)

---

## 1. Overview

- **`IWorkflowInstance`** – The single object that represents the entire running workflow for one message.  
  It holds all state, all executed activities, and is your primary way to **create and route messages**.

- **`IActivityInstance`** – A snapshot of one activity (Receiver, Transformer, Sender, etc.).  
  Every activity has its own `Message` (inbound) and `ResponseMessage` (outbound).

**All message operations flow through these two interfaces.**

---

## 2. IWorkflowInstance – The Workflow Container

One instance per workflow run.  
Created when a message enters the Receiver and destroyed when the workflow completes.

**Key roles for messages:**
- Create new messages (`CreateMessage`)
- Provide access to any activity’s messages
- Manage the current message context

---

## 3. IActivityInstance – One Executed Activity

Created automatically for every activity that runs.

**Key message properties:**
- `IMessage Message` – The message **received** by this activity
- `IMessage ResponseMessage` – The message **produced** by this activity (set by Senders)

---

## 4. Accessing Them in Code Transformers

```csharp
// Inside any Code Transformer you get these two automatically:

// Direct references
IWorkflowInstance workflow = workflowInstance;
IActivityInstance current = activityInstance;

// Strongly-typed shortcuts (recommended)
IActivityInstance currentAct = CurrentActivity;
IActivityInstance receiver = Receiver();
```

---

## 5. Full Property & Method Reference – IWorkflowInstance (Message-Focused)

### Identification
- `Guid Id` – Workflow definition ID (same as Receiver ID)
- `int InstanceId` – Unique run counter

### Activity & Message Access
- `List<IActivityInstance> Activities` – All activities executed so far (0 = Receiver)
- `IActivityInstance CurrentActivityInstance` – Currently executing activity
- `IActivityInstance ReceivingActivityInstance` – Always the Receiver
- `IActivityInstance GetActivityInstance(Guid settingId)` – Any activity by GUID

### Message Creation
- `IMessage CreateMessage(MessageTypes messageType, string text)`
- `IMessage CreateMessage(MessageTypes messageType, string text, IMessageTypeOptions options)`

---

## 6. Full Property & Method Reference – IActivityInstance

- `Guid Id` – Unique activity GUID (right-click in designer to copy)
- `string Name` – Activity name from designer
- `bool Filtered` – Set to `true` to filter this activity
- `IMessage Message` – **Inbound** message for this activity
- `IMessage ResponseMessage` – **Outbound** message (populated after Senders)

---

## 7. Working with Messages – The Core Focus

### 7.1 Strongly-Typed Message Interfaces

Integration Soup provides rich, type-safe interfaces for every message type:

| Interface          | Use Case                          | Key Methods |
|--------------------|-----------------------------------|-------------|
| `IMessage`         | Base for all                      | `Text`, `GetValueAtPath`, `SetValueAtPath`, `SetStructureAtPath`, `SetText` |
| `IHL7Message`      | HL7 v2 (most common)              | `GetSegments`, `GetSegment`, `GetField`, `AddSegment`, `GetPart`, `BeginUpdate`/`EndUpdate` |
| `IXmlMessage`      | XML                               | `GetStructureAtPath`, `GetChildStructuresAtPath`, `GetChildValuesAtPath`, `SetRootNode` |
| `IJsonMessage`     | JSON                              | `GetStructureAtPath`, `GetChildStructuresAtPath`, `GetChildValuesAtPath` |
| `ICsvMessage`      | CSV                               | Inherits `IMessage` |
| `ITextMessage`     | Plain text                        | `AppendLine`, `SetText` |
| `IDicomMessage`    | DICOM                             | `GetXml`, `GetJson`, `GetBase64EncodedDicom` |

### 7.2 Strongly-Typed Access in CodeContext

```csharp
IHL7Message  hl7   = CurrentHL7;      // throws clear exception if not HL7
IXmlMessage  xml   = CurrentXml;
IJsonMessage json  = CurrentJson;
IMessage     text  = CurrentCsv;      // or any ITextMessage
IDicomMessage dicom = CurrentDicom;
```

**Received** versions:
- `ReceivedHL7`, `ReceivedXml`, `ReceivedJson`, etc.

### 7.3 Core Message Operations (IMessage)

```csharp
string value = message.GetValueAtPath("PID-3.1");           // HL7 path
message.SetValueAtPath("PID-5.1", "John");                  // auto-encodes for message type
message.SetStructureAtPath("OBX[2]", fullObxSegmentText);   // replace entire structure
message.SetText(entireNewMessageText);                      // full replacement
string rawText = message.Text;
```

### 7.4 HL7-Specific Power (IHL7Message)

```csharp
IHL7Message hl7 = CurrentHL7;

// Navigation
IHL7Segment pid = hl7.GetSegment("PID");
IHL7Field nameField = pid.GetField(5);
IHL7Component givenName = nameField.GetComponent(2);

// Reading
string patientId = pid.GetFieldValue(3);
string fullName = hl7.GetValueAtPath("PID-5");

// Writing (safe)
nameField.SetTextEncoded("Smith^John^J");   // encodes | ^ ~ & automatically

// Adding segments
hl7.AddSegment("OBX|1|ST|...");

// Batch updates (performance)
hl7.BeginUpdate();
... many SetValueAtPath calls ...
hl7.EndUpdate();
```

### 7.5 XML & JSON

```csharp
IXmlMessage xml = CurrentXml;
string patientBlock = xml.GetStructureAtPath("Patient");
xml.SetValueAtPath("Patient/Name/Given", "John");

IJsonMessage json = CurrentJson;
string address = json.GetStructureAtPath("patient.address[0]");
```

---

## 8. Variables (Message Manipulation Companion)

```csharp
// Read from anywhere
string pid = GetVariable("PatientID");

// Write back to message via variable
SetVariable("NewPID", "PAT-999");
CurrentHL7.SetValueAtPath("PID-3.1", GetVariable("NewPID"));
```

---

## 9. Activity Lookup & Navigation

```csharp
IActivityInstance sender = GetActivity(1);           // index
IActivityInstance lab = GetActivity("Lab Sender");   // name
IActivityInstance any = GetActivity(guid);           // GUID

// Source message from another activity
IHL7Message sourceHL7 = (IHL7Message)GetActivity("Source").Message;
```

---

## 10. Creating New Messages

```csharp
IHL7Message ack = (IHL7Message)CreateMessage(
    MessageTypes.HL7V2,
    "MSH|^~\\&|Soup|..."
);

ack.SetValueAtPath("MSA-1", "AA");
ack.SetValueAtPath("MSA-2", GetVariable("MSH-10"));
```

---

## 11. Real-World Message Examples

### Example 1: Simple HL7 Field Copy
```csharp
IHL7Message source = (IHL7Message)Receiver().Message;
IHL7Message dest = CurrentHL7;

dest.SetValueAtPath("PID-3.1", source.GetValueAtPath("PID-3.1"));
dest.SetValueAtPath("PID-5", source.GetValueAtPath("PID-5"));
```

### Example 2: Build New HL7 Segment Dynamically
```csharp
string obx = $"OBX|1|ST|TEST^Test Result||{GetVariable("Result")}|";
CurrentHL7.AddSegment(obx);
```

### Example 3: XML Transformation
```csharp
IXmlMessage xml = CurrentXml;
xml.SetValueAtPath("Patient/Name/Given", GetVariable("FirstName").Title());
```

### Example 4: Replace Entire Message
```csharp
string newText = "MSH|^~\\&|...";
workflowInstance.CurrentActivityInstance.Message.SetText(newText);
```

### Example 5: Response Message (in Sender context)
```csharp
IHL7Message ack = (IHL7Message)CreateMessage(MessageTypes.HL7V2, "MSH|...|ACK|");
workflowInstance.SetReponseMessage(ack);
```

---

## 12. Best Practices & Gotchas

1. **Always** use strongly-typed properties (`CurrentHL7`, `CurrentXml`) – you get full intellisense and compile-time safety.
2. Use `SetValueAtPath` for normal values – it auto-encodes (`&` → `\T\` in HL7).
3. Use `SetStructureAtPath` or `AddSegment` when you want to inject raw structure.
4. Call `BeginUpdate()` / `EndUpdate()` on HL7 when doing many changes.
5. `ResponseMessage` is only available **after** a Sender has run.
6. `GetActivityInstance` throws a helpful exception listing all valid activities if the GUID is wrong.
7. Prefer `SetTextEncoded` on HL7 parts when setting business data that may contain delimiters.
8. `Message.Text` gives you the raw current text at any moment.

---

## 13. Quick Cheat Sheet

```csharp
// Access
IHL7Message hl7 = CurrentHL7;
IActivityInstance rec = Receiver();

// Read
string val = hl7.GetValueAtPath("PID-3.1");

// Write
hl7.SetValueAtPath("PID-5.1", "John");

// Create
var msg = CreateMessage(MessageTypes.HL7V2, "MSH|...");

// Full replace
CurrentActivity.Message.SetText(newText);

// From another activity
string other = GetActivity("Source").Message.GetValueAtPath("PID-3");
```
