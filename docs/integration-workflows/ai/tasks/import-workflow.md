# Task: Import Workflow Definition (`AiFunctionType.ImportWorkflow`)

Generates concrete activity settings from an external workflow description (for example Mirth).

---

## Use when

- migrating an existing integration channel/workflow into Integration Soup
- source details are mostly imported text/config, not greenfield design

---

## Output contract

- return JSON array of concrete `ISetting` objects
- receiver first, then senders
- use fully-qualified `$type` values

---

## Instruction input template (copy/paste)

```text
Import this workflow into Integration Soup setting objects.

Source platform:
- Name:
- Version:

Imported receiver details:
- Transport:
- Endpoint/port/path:
- Security/auth:
- Message type:

Imported sender/destination details (ordered):
- Sender 1 ...
- Sender 2 ...

Imported filters/transformers:
- ...

Constraints:
- one receiver only
- create as many senders as required
- use full type names in $type
- use GUID placeholders if unknown

Return only JSON array of setting objects.
```

---

## Example (Mirth-like import summary -> setting list)

## Input

```text
Source has one LLP Listener on port 22222 (HL7). Two destinations:
1) HTTP POST https://api.example/adt
2) database insert into PatientLog
```

## Output (shape example)

```json
[
  {
    "$type": "HL7Soup.Functions.Settings.Receivers.MLLPReceiverSetting, HL7SoupWorkflow",
    "Id": "11111111-1111-1111-1111-111111111111",
    "Name": "Imported TCP Receiver",
    "MessageType": 9,
    "Port": 22222,
    "Activities": [
      "22222222-2222-2222-2222-222222222222",
      "33333333-3333-3333-3333-333333333333"
    ]
  },
  {
    "$type": "HL7Soup.Functions.Settings.Senders.HttpSenderSetting, HL7SoupWorkflow",
    "Id": "22222222-2222-2222-2222-222222222222",
    "Name": "Imported HTTP Destination",
    "MessageType": 12,
    "Server": "https://api.example/adt"
  },
  {
    "$type": "HL7Soup.Functions.Settings.Senders.DatabaseSenderSetting, HL7SoupWorkflow",
    "Id": "33333333-3333-3333-3333-333333333333",
    "Name": "Imported DB Destination",
    "MessageType": 13,
    "MessageTemplate": "INSERT INTO PatientLog (...) VALUES (...)"
  }
]
```

---

## Message-type scenario notes

- HL7/TCP import -> MLLP receiver/sender families
- REST/HTTP import -> HTTP receiver/sender families
- SOAP/WCF import -> WebService receiver/sender families
- File polling import -> DirectoryScan receiver + optional FileWriter sender

---

## Common failure modes

- short or partial `$type` values
- sender/receiver order reversed
- GUID links missing between receiver `Activities` and sender IDs
- importing filters/transformers directly onto activities without host setting references
