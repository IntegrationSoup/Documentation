# Prompt: CreateWorkflowFileFromWorkflowStructure (`AiFunctionType.CreateWorkflowFileFromWorkflowStructure`)

Creates concrete setting objects from a prepared `AiWorkflowStructure`.

---

## Use when

- you already have a validated `AiWorkflowStructure`
- you need concrete receiver/sender settings for final `WorkflowFile`

---

## Output contract

- return JSON array of concrete `ISetting` objects
- first object is receiver
- subsequent objects are senders

---

## Prompt template (copy/paste)

```text
Using this AiWorkflowStructure JSON, generate concrete Integration Soup setting objects.

AiWorkflowStructure:
{ ... }

Constraints:
- receiver first, then senders in declared order
- full $type names only
- preserve templates exactly
- do not create explanatory text

Return only JSON array of settings.
```

---

## Example input

```json
{
  "ReceiverActivity": {
    "MessageSource": "HTTP",
    "MessageType": "JSON",
    "Instructions": "Listen on /api/inbound"
  },
  "SenderActivities": [
    {
      "SenderAction": "Database",
      "Name": "WriteInbound",
      "MessageType": "SQL",
      "Instructions": "Insert into AuditLog",
      "MessageTemplate": "INSERT INTO AuditLog (Payload) VALUES (@Payload)"
    }
  ]
}
```

## Example output (shape)

```json
[
  {
    "$type": "HL7Soup.Functions.Settings.Receivers.HttpReceiverSetting, HL7SoupWorkflow",
    "Id": "11111111-1111-1111-1111-111111111111",
    "Name": "HTTP Receiver",
    "MessageType": 12,
    "Port": 8080,
    "ServiceName": "api/inbound",
    "Activities": [
      "22222222-2222-2222-2222-222222222222"
    ]
  },
  {
    "$type": "HL7Soup.Functions.Settings.Senders.DatabaseSenderSetting, HL7SoupWorkflow",
    "Id": "22222222-2222-2222-2222-222222222222",
    "Name": "WriteInbound",
    "MessageType": 13,
    "MessageTemplate": "INSERT INTO AuditLog (Payload) VALUES (@Payload)"
  }
]
```

---

## Important assembly reminder

This function output is activity objects only.  
Final workflow-file composition still needs:

- filter host objects for activity `Filters` references
- transformer setting objects for activity `Transformers`/`VariableTransformers` references
- top-level `WorkflowFile` wrapper with `WorkflowPattern`
