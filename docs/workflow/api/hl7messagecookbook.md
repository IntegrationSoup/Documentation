# HL7 Message Cookbook  
**30 Real-World Patterns for Integration Soup**  
*Version 1.0 • February 2026*

This companion cookbook gives you **copy-paste-ready** code patterns for the most common (and some advanced) HL7 v2 tasks using `IHL7Message` and the full object model.

All examples use the **strongly-typed interfaces** (`CurrentHL7`, `GetValueAtPath`, `SetValueAtPath`, etc.) shown in the main `IHL7Message` guide.

---

## Table of Contents
1–5. Basic Reading & Writing  
6–10. Repeating Segments & Fields  
11–15. Building & Handling ACKs  
16–20. Transforming & Mapping  
21–25. Adding / Removing / Reordering  
26–30. Advanced & Performance Patterns  

---

### 1. Read a Single Field (Safest Pattern)
```csharp
IHL7Message hl7 = CurrentHL7;
string mrn = hl7.GetValueAtPath("PID-3.1");
string lastName = hl7.GetValueAtPath("PID-5.1");
```

### 2. Write a Single Field (Auto-Encoding)
```csharp
hl7.SetValueAtPath("PID-5.1", GetVariable("LastName"));
hl7.SetValueAtPath("PID-5.2", GetVariable("FirstName").Title());
```

### 3. Write with Encoding (Business Names)
```csharp
IHL7Segment pid = hl7.GetSegment("PID");
pid.GetField(5).SetTextEncoded("O'Connor^John^J");
```

### 4. Read with Fallback (Default Value)
```csharp
string dob = hl7.GetValueAtPath("PID-7").Default("");
DateTime birthDate = HL7Helpers.GetDateFromHL7Date(dob);
```

### 5. Full Message Text (for Logging / Debugging)
```csharp
string rawHl7 = hl7.Text;                    // current state
string structure = hl7.GetStructureAtPath("PID"); // raw with escapes
```

---

### 6. Loop All OBX Segments
```csharp
foreach (IHL7Segment obx in hl7.GetSegments("OBX"))
{
    string obsId = obx.GetFieldValue(3);      // OBX-3
    string value = obx.GetFieldValue(5);      // OBX-5
    // process...
}
```

### 7. Handle Repeating Fields (e.g. PID-3)
```csharp
IHL7Segment pid = hl7.GetSegment("PID");
var allMrns = pid.GetField(3).GetRelatedRepeatFields();

foreach (IHL7Field mrnField in allMrns)
{
    string mrn = mrnField.Text;
}
```

### 8. Add a Repeating Field
```csharp
IHL7Segment pid = hl7.GetSegment("PID");
pid.GetField(3).SetTextEncoded("NEWMRN");   // adds as new repeat
```

### 9. Get Specific Repeat (e.g. second OBX)
```csharp
IHL7Segment secondObx = hl7.GetSegment("OBX[2]");
string result = secondObx.GetFieldValue(5);
```

### 10. Count Repeating Segments
```csharp
int obxCount = hl7.GetSegments("OBX").Count;
```

---

### 11. Generate Standard ACK (AA)
```csharp
IHL7Message ack = hl7.GenerateAcceptMessage(null);  // uses built-in helper
workflowInstance.SetReponseMessage(ack);
```

### 12. Generate Application Error ACK (AE)
```csharp
IHL7Message ack = hl7.GenerateErrorMessage("Patient not found");
workflowInstance.SetReponseMessage(ack);
```

### 13. Generate Reject ACK (AR)
```csharp
IHL7Message ack = hl7.GenerateRejectMessage("Unsupported message type");
workflowInstance.SetReponseMessage(ack);
```

### 14. Custom ACK with Extra Fields
```csharp
hl7.BeginUpdate();
IHL7Message ack = hl7.GenerateAcceptMessage(null);
ack.SetValueAtPath("MSA-3", "Custom text");
ack.SetValueAtPath("MSA-6", "IntegrationSoup");
hl7.EndUpdate();
workflowInstance.SetReponseMessage(ack);
```

### 15. MSA-1 Dynamic Status
```csharp
string status = GetVariable("AckStatus").Default("AA");
IHL7Message ack = (IHL7Message)CreateMessage(MessageTypes.HL7V2, "MSH|^~\\&|...");
ack.SetValueAtPath("MSA-1", status);
```

---

### 16. Copy Entire Segment from Source
```csharp
IHL7Message source = (IHL7Message)Receiver().Message;
IHL7Segment srcPid = source.GetSegment("PID");
hl7.SetStructureAtPath("PID", srcPid.Text);
```

### 17. Map One Field to Another
```csharp
string value = hl7.GetValueAtPath("OBR-4.1");
hl7.SetValueAtPath("OBX-3.1", value);
```

### 18. Convert HL7 Date → ISO
```csharp
string hl7Date = hl7.GetValueAtPath("PID-7");
DateTime dt = HL7Helpers.GetDateFromHL7Date(hl7Date);
hl7.SetValueAtPath("PID-7", HL7Helpers.GetHL7Date(dt, "yyyy-MM-dd"));
```

### 19. Uppercase All OBX-5 Values
```csharp
hl7.BeginUpdate();
foreach (IHL7Segment obx in hl7.GetSegments("OBX"))
{
    string val = obx.GetFieldValue(5);
    obx.GetField(5).SetTextEncoded(val.ToUpper());
}
hl7.EndUpdate();
```

### 20. TitleCase Patient Name
```csharp
IHL7Segment pid = hl7.GetSegment("PID");
string name = pid.GetFieldValue(5);
pid.GetField(5).SetTextEncoded(name.Title());
```

---

### 21. Add New OBX Segment
```csharp
hl7.AddSegment($"OBX|1|ST|TEST^Test Result||{GetVariable("Result")}|{GetVariable("Units")}");
```

### 22. Insert Segment at Specific Position
```csharp
// Not directly supported — rebuild or use SetStructureAtPath on parent
string newMsg = hl7.Text.Insert(hl7.Text.IndexOf("\rOBX"), "\rNEWSEG|1|...");
hl7.SetText(newMsg);
```

### 23. Remove All DG1 Segments
```csharp
var dg1s = hl7.GetSegments("DG1").ToList();
foreach (var dg1 in dg1s)
{
    hl7.RemoveSegment(dg1);
}
```

### 24. Clear All OBX Segments
```csharp
hl7.BeginUpdate();
var obxs = hl7.GetSegments("OBX").ToList();
foreach (var obx in obxs)
{
    hl7.RemoveSegment(obx);
}
hl7.EndUpdate();
```

### 25. Reorder Segments (Move PID after MSH)
```csharp
IHL7Segment pid = hl7.GetSegment("PID");
hl7.RemoveSegment(pid);
hl7.AddSegment(pid.Text);   // adds at end — adjust as needed
```

---

### 26. Bulk Update Performance Pattern
```csharp
hl7.BeginUpdate();
for (int i = 1; i <= 50; i++)
{
    hl7.SetValueAtPath($"OBX[{i}]-5", $"Result {i}");
}
hl7.EndUpdate();
```

### 27. Validate Against Profile
```csharp
string jsonResults = hl7.ValidateWithHighlighters("MyHL7Profile");
bool isValid = hl7.ValidatesWithHighlighters("MyHL7Profile");
```

### 28. Get All Repeating Field Values as List
```csharp
var allNames = new List<string>();
foreach (IHL7Field nameField in hl7.GetSegment("PID").GetField(5).GetRelatedRepeatFields())
{
    allNames.Add(nameField.Text);
}
```

### 29. Dynamic Field by Variable
```csharp
string fieldPath = $"PID-{GetVariable("FieldNumber")}";
string value = hl7.GetValueAtPath(fieldPath);
```

### 30. Full Message Transformation Template
```csharp
IHL7Message hl7 = CurrentHL7;
hl7.BeginUpdate();

// Patient demographics
hl7.SetValueAtPath("PID-3.1", GetVariable("MRN"));
hl7.SetValueAtPath("PID-5.1", GetVariable("LastName").McName());
hl7.SetValueAtPath("PID-5.2", GetVariable("FirstName").Title());

// Add result OBX
hl7.AddSegment($"OBX|1|ST|RESULT^Result||{GetVariable("LabResult")}|");

// Finalise
hl7.EndUpdate();
```

---

## Bonus Tips from the Cookbook

- Always wrap bulk operations in `BeginUpdate()` / `EndUpdate()`.
- Use `SetTextEncoded()` on fields/components when the value may contain `| ^ ~ &`.
- Prefer `GetValueAtPath` for simple reads — it decodes automatically.
- Use `GetStructureAtPath` when you need raw HL7 escapes preserved.
- `GetRelatedRepeatFields()` is the correct way to handle repeats.
- Never modify `.Text` directly — always use the `Set*` methods.

