# Prompt: CreateWorkflow (`AiFunctionType.CreateWorkflow`)

Builds `AiWorkflowStructure` from natural-language requirements.

This is the planning step for workflow generation.

---

## Use when

- you have user requirements but no workflow JSON yet
- you need one receiver + multiple sender activity plans
- you want an AI-readable structure before creating concrete settings

---

## Output contract

- return exactly one JSON object matching `AiWorkflowStructure`
- include `ReceiverActivity`, `SenderActivities`, and optional `GlobalVariables`
- do not output prose outside JSON

---

## Prompt template (copy/paste)

```text
Create an Integration Soup workflow structure from the requirements below.

Requirements:
- Receiver/source:
  - Type:
  - Connection details:
  - Inbound message type:
  - Inbound message template (if provided, keep exact):
- Sender activities (ordered):
  - Sender 1 type:
  - Sender 1 connection details:
  - Sender 1 message type:
  - Sender 1 message template (if provided, keep exact):
  - Sender 2 ...
- Filters:
- Transformations:
- Variables to create/reuse:
- Response behavior:

Constraints:
- One receiver only.
- Keep templates unchanged.
- Put mapping/filter logic in transformer/filter instructions.
- Use positive filter phrasing ("Continue only when...").

Return only AiWorkflowStructure JSON.
```

---

## Example 1 (HL7 TCP -> HTTP + Database)

## Input

```text
Receive HL7 ADT on TCP port 2575. Forward ADT messages to an HTTP endpoint and insert demographics into SQL.
Map PID-3.1 to externalId and PID-5.1/PID-5.2 to last/first.
```

## Output (shape example)

```json
{
  "ReceiverActivity": {
    "MessageSource": "TCP",
    "MessageType": "HL7",
    "Instructions": "Listen on TCP port 2575 with MLLP framing. Auto Generate the Response.",
    "Filters": [],
    "VariableTransformers": [
      {
        "Instruction": "Set Variables:\n  ${MessageCode} from MSH-9.1\n  ${PatientID} from PID-3.1\n  ${LastName} from PID-5.1\n  ${FirstName} from PID-5.2"
      }
    ],
    "MessageTemplate": "",
    "ReturnedMessageTransformers": [],
    "ReturnedMessageTemplate": ""
  },
  "SenderActivities": [
    {
      "SenderAction": "HTTP",
      "Name": "Forward ADT to API",
      "MessageType": "JSON",
      "Instructions": "POST to https://api.example/patient",
      "Filters": [
        {
          "Instruction": "Continue only when ${MessageCode} equals 'ADT'"
        }
      ],
      "Transformers": [
        {
          "Instruction": "Map PID-3.1 to externalId. Map PID-5.1 to lastName. Map PID-5.2 to firstName."
        }
      ],
      "MessageTemplate": "{ \"externalId\": \"\", \"lastName\": \"\", \"firstName\": \"\" }",
      "ReturnedMessageTemplate": ""
    },
    {
      "SenderAction": "Database",
      "Name": "Insert demographics",
      "MessageType": "SQL",
      "Instructions": "Insert into PatientDemographics using SQL parameters",
      "Filters": [],
      "Transformers": [
        {
          "Instruction": "Map PID-3.1 to @PatientID. Map PID-5.1 to @LastName. Map PID-5.2 to @FirstName."
        }
      ],
      "MessageTemplate": "INSERT INTO PatientDemographics (PatientID, LastName, FirstName) VALUES (@PatientID, @LastName, @FirstName)",
      "ReturnedMessageTemplate": ""
    }
  ],
  "GlobalVariables": []
}
```

---

## Example 2 (CSV file -> SOAP)

## Input

```text
Watch c:\inbound\*.csv and send SOAP requests to register patients.
CSV columns: [0]=MRN, [1]=LastName, [2]=FirstName, [3]=DOB.
```

## Output focus

- `ReceiverActivity.MessageSource = "File"`
- `ReceiverActivity.MessageType = "CSV"`
- sender `SenderAction = "SOAP"`
- mapping instructions use CSV paths (`[0]`, `[1]`, ...)

---

## Common failure modes

- receiver count greater than one
- templates rewritten by the model
- mapping logic dumped into `Instructions` instead of transformer instructions
- filter language written as "exclude/filter out" rather than pass criteria

---

## Next pipeline step

1. [ValidateWorkflowStructure](validate-workflow-structure.md)
2. [RefineWorkflowStructure](refine-workflow-structure.md) if needed
3. [CreateWorkflowFileFromWorkflowStructure](create-workflow-file-from-workflow-structure.md)
