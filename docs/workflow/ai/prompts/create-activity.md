# Prompt: CreateActivity (`AiFunctionType.CreateActivity`)

Generates a single activity definition from a focused activity requirement.

---

## Use when

- the user explicitly requests one activity, not a full workflow
- prototyping a custom activity behavior before integrating into full pipeline

---

## Output contract

- one activity-level definition that can be embedded in later workflow assembly

---

## Prompt template (copy/paste)

```text
Create one Integration Soup activity from this requirement.

Activity role:
- Receiver or Sender:
- Purpose:
- Message type:
- Transport/storage details:
- Template (if applicable):

Return only the activity JSON definition.
```

---

## Example (Code sender fallback)

## Input

```text
Create a sender that emails ADT notifications. Use custom code because there is no native email sender.
```

## Output (shape)

```json
{
  "$type": "HL7Soup.Functions.Settings.Senders.CodeSenderSetting, HL7SoupWorkflow",
  "Id": "11111111-1111-1111-1111-111111111111",
  "Name": "Email Notification",
  "MessageType": 7,
  "Comment": "Send email for ADT events",
  "Code": "// Create and send email using SMTP client",
  "UseResponse": false
}
```

---

## Practical note

For production workflow authoring, prefer:

1. [CreateWorkflow](create-workflow.md)  
2. [CreateWorkflowFileFromWorkflowStructure](create-workflow-file-from-workflow-structure.md)
