# Prompt: CreateRecieverResponseTransfomerInstructions (`AiFunctionType.CreateRecieverResponseTransfomerInstructions`)

Expands final response transformation instructions executed after sender processing.

---

## Use when

- custom response content is required
- receiver must return transformed sender/variable data to caller

---

## Output contract

- plain instruction text for `AiReceiverActivity.ReturnedMessageTransformers[i].Instruction`

---

## Prompt template (copy/paste)

```text
Create receiver response-transformer instruction text.

Receiver type/message type:
- ...

Returned message template (exact if provided):
- ...

Data sources available for response:
- Receiver inbound
- Sender outputs
- Variables

Constraints:
- do not modify templates
- provide explicit map/update/format steps
- state source activity when not receiver inbound

Return only instruction text.
```

---

## Example 1 (custom JSON response)

## Input

```text
Return HTTP 200 JSON body with patientId from inbound and status from sender "WriteInbound".
```

## Output

```text
From Receiver:
Map patient/id to response/patientId
From 'WriteInbound':
Map status to response/status
Update response/result to 'ok'
```

## Example 2 (custom HL7 ACK variant)

## Input

```text
Return custom ACK with MSA-1='AA' and MSA-2 from inbound MSH-10.
```

## Output

```text
From Receiver:
Map MSH-10 to MSA-2
Update MSA-1 to 'AA'
```

---

## Protocol note

For standard HL7 over TCP/MLLP, auto-generated response is usually preferred unless custom behavior is explicitly requested.
