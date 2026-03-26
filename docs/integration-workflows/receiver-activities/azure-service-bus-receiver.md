# **Azure Service Bus Receiver (AzureServiceBusReceiverSetting)**

This is an **Azure Activities Extension Library** activity.

It is available only when the Azure extension library is installed on the workflow host. For the extension package and install notes, see [Azure Activities](../extension-libraries/azure-activities.md).

## What this setting controls

`AzureServiceBusReceiverSetting` receives messages from an Azure Service Bus queue or topic subscription.

It controls:

- the Service Bus connection string
- whether the source is a queue or topic subscription
- the entity and subscription names
- receive mode
- prefetch count
- inbound message decoding
- whether failed messages are abandoned or dead-lettered

## Typical JSON shape

```json
{
  "$type": "HL7Soup.Functions.Settings.Receivers.AzureServiceBusReceiverSetting, HL7SoupWorkflow",
  "Id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "Name": "Receive from Service Bus queue Admissions",
  "Version": 1,
  "MessageType": 1,
  "ConnectionString": "${AzureServiceBusConnection}",
  "TargetType": 0,
  "EntityName": "admissions",
  "SubscriptionName": "",
  "ReceiveMode": 0,
  "PrefetchCount": 0,
  "Encoding": "utf-8",
  "DeadLetterOnError": false
}
```

## Connection fields

### `ConnectionString`

Azure Service Bus connection string.

Important runtime behavior:

- this field supports **Global Variable** replacement
- it does **not** support per-message workflow variable processing
- the receiver resolves it when the receiver starts, not once per message

### `TargetType`

JSON enum values:

- `0` = `Queue`
- `1` = `TopicSubscription`

### `EntityName`

Queue name or topic name. Supports Global Variable replacement at receiver startup.

### `SubscriptionName`

Required when `TargetType = 1` (`TopicSubscription`).

Supports Global Variable replacement at receiver startup.

## Receive behavior

### `ReceiveMode`

JSON enum values:

- `0` = `PeekLock`
- `1` = `ReceiveAndDelete`

Behavior:

- `PeekLock`: message is completed after successful workflow processing
- `ReceiveAndDelete`: message is removed as soon as it is received

### `DeadLetterOnError`

Used only when `ReceiveMode = PeekLock`.

Behavior after workflow failure:

- `false`: abandon the message
- `true`: dead-letter the message

### `PrefetchCount`

Azure Service Bus prefetch count. Negative values are treated as `0`.

## Message body behavior

### `MessageType`

Controls how the inbound bytes are converted into the workflow message.

Behavior:

- text-based message types are decoded using `Encoding`
- `Binary` and `DICOM` are surfaced as base64 text

### `Encoding`

Text encoding used for inbound text decoding.

If the encoding name is empty or invalid, UTF-8 is used.

## Workflow variables created by the receiver

### Fixed Service Bus variables

These are always created when a message is received:

- `ServiceBusMessageId`
- `ServiceBusCorrelationId`
- `ServiceBusSubject`
- `ServiceBusSessionId`
- `ServiceBusReplyTo`
- `ServiceBusReplyToSessionId`
- `ServiceBusTo`
- `ServiceBusContentType`
- `ServiceBusDeliveryCount`
- `ServiceBusEnqueuedTimeUtc`
- `ServiceBusScheduledEnqueueTimeUtc`
- `ServiceBusSequenceNumber`
- `ServiceBusPartitionKey`
- `ServiceBusDeadLetterSource`
- `ServiceBusApplicationPropertiesJson`

`ServiceBusApplicationPropertiesJson` contains all application properties as a JSON object.

### Dynamic application-property variables

At runtime, each incoming Service Bus application property is also exposed as a workflow variable:

```text
ServiceBusApp<PropertyName>
```

Examples:

- `EventType` -> `ServiceBusAppEventType`
- `FacilityCode` -> `ServiceBusAppFacilityCode`
- `Order-Type` -> `ServiceBusAppOrder_Type`

Variable-name behavior:

- letters, digits, and `_` are preserved
- other characters are converted to `_`

Important design-time behavior:

- these dynamic variables are **not** listed in the binding tree, because their names depend on the message that actually arrives
- only the fixed Service Bus variables are listed in the binding tree

## Message settlement

### `PeekLock`

- success: complete the message
- workflow error with `DeadLetterOnError = false`: abandon the message
- workflow error with `DeadLetterOnError = true`: dead-letter the message

### `ReceiveAndDelete`

- the message is removed immediately on receive
- there is no later complete, abandon, or dead-letter step

## Defaults

New `AzureServiceBusReceiverSetting` defaults:

- `TargetType = 0` (`Queue`)
- `ReceiveMode = 0` (`PeekLock`)
- `MessageType = 1` (`HL7`)
- `Encoding = "utf-8"`
- `PrefetchCount = 0`
- `DeadLetterOnError = false`

## Pitfalls and hidden outcomes

- `ConnectionString`, `EntityName`, and sometimes `SubscriptionName` are startup settings, not per-message values.
- Dynamic Service Bus application-property variable names are only known when a message arrives.
- Most real business data should come from the inbound message body. Service Bus application properties are best treated as transport metadata.
- `ReceiveAndDelete` removes the safety net of retry, abandon, and dead-letter handling.

## Example

```json
{
  "$type": "HL7Soup.Functions.Settings.Receivers.AzureServiceBusReceiverSetting, HL7SoupWorkflow",
  "Name": "Receive from Service Bus topic admissions/inbound",
  "ConnectionString": "${AzureServiceBusConnection}",
  "TargetType": 1,
  "EntityName": "admissions",
  "SubscriptionName": "inbound",
  "ReceiveMode": 0,
  "PrefetchCount": 20,
  "Encoding": "utf-8",
  "DeadLetterOnError": true
}
```
