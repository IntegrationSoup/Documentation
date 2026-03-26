# **Azure Service Bus Sender (AzureServiceBusSenderSetting)**

This is an **Azure Activities Extension Library** activity.

It is available only when the Azure extension library is installed on the workflow host. For the extension package and install notes, see [Azure Activities](../extension-libraries/azure-activities.md).

## What this setting controls

`AzureServiceBusSenderSetting` sends the current activity message to an Azure Service Bus queue or topic.

It controls:

- the Service Bus connection string
- whether the target is a queue or topic
- the queue or topic name
- message body encoding
- standard Service Bus headers such as `MessageId`, `Subject`, and `CorrelationId`
- custom application properties

## Typical JSON shape

```json
{
  "$type": "HL7Soup.Functions.Settings.Senders.AzureServiceBusSenderSetting, HL7SoupWorkflow",
  "Id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "Name": "Send to Azure Service Bus Queue Admissions",
  "Version": 1,
  "MessageType": 13,
  "MessageTemplate": "${SourceMessage}",
  "ConnectionString": "${AzureServiceBusConnection}",
  "TargetType": 0,
  "EntityName": "admissions",
  "ContentType": "application/json",
  "Subject": "ADT_A01",
  "MessageId": "${UUID}",
  "CorrelationId": "${WorkflowInstanceId}",
  "SessionId": "",
  "ReplyTo": "",
  "ReplyToSessionId": "",
  "To": "",
  "Encoding": "utf-8",
  "ApplicationProperties": [
    {
      "Name": "EventType",
      "Value": "ADT",
      "FromType": 7,
      "FromDirection": 2
    }
  ]
}
```

## Core fields

### `ConnectionString`

Azure Service Bus connection string.

This field supports workflow variable processing at send time, so values such as `${AzureServiceBusConnection}` are resolved when the activity runs.

### `TargetType`

JSON enum values:

- `0` = `Queue`
- `1` = `Topic`

### `EntityName`

Queue or topic name. Supports workflow variable processing at send time.

## Message body behavior

The outbound Service Bus message body is built from the current activity message.

Behavior by message type:

- text-based message types use `Encoding`
- `Binary` and `DICOM` first try to base64-decode the activity text
- if base64 decoding fails, `Binary` and `DICOM` fall back to encoding the text directly
- if the workflow message is already a DICOM message with raw DICOM bytes, those bytes are sent directly

### `Encoding`

Text encoding used when converting message text to bytes.

If the encoding name is empty or invalid, UTF-8 is used.

## Standard Service Bus properties

The following fields support workflow variable processing at send time:

- `ContentType`
- `Subject`
- `MessageId`
- `CorrelationId`
- `SessionId`
- `ReplyTo`
- `ReplyToSessionId`
- `To`

These fields map to the equivalent Azure Service Bus message properties.

## `ApplicationProperties`

Custom Service Bus application properties.

Each entry supplies:

- `Name`: application property name
- `Value`: source expression
- binding fields such as `FromType`, `FromDirection`, and `FromSetting`

Runtime behavior:

- each property name becomes an entry in the outgoing Service Bus application properties bag
- property values are resolved from the configured binding source
- blank property names are ignored
- null values are sent as empty strings

## Response message

On success, the sender returns a Text response message similar to:

```text
Sent Azure Service Bus message to Queue 'admissions'.
```

## Defaults

New `AzureServiceBusSenderSetting` defaults:

- `TargetType = 0` (`Queue`)
- `ContentType = "text/plain"`
- `Encoding = "utf-8"`
- `ApplicationProperties = []`

## Pitfalls and hidden outcomes

- `TargetType` changes only the description and intent. The actual sender still requires a valid `EntityName`.
- `ConnectionString` and `EntityName` are required.
- The sender supports workflow variables in connection and header fields, unlike the receiver startup settings.
- `Binary` and `DICOM` message bodies are safest when the activity message text contains base64.

## Example

```json
{
  "$type": "HL7Soup.Functions.Settings.Senders.AzureServiceBusSenderSetting, HL7SoupWorkflow",
  "Name": "Publish Admission Event",
  "ConnectionString": "${AzureServiceBusConnection}",
  "TargetType": 1,
  "EntityName": "adt-events",
  "ContentType": "application/hl7-v2",
  "Subject": "ADT_A01",
  "CorrelationId": "${WorkflowInstanceId}",
  "Encoding": "utf-8",
  "ApplicationProperties": [
    {
      "Name": "FacilityCode",
      "Value": "${SendingFacility}",
      "FromType": 7,
      "FromDirection": 2
    }
  ]
}
```
