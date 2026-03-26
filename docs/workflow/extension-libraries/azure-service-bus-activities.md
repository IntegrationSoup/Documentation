# Azure Activities: Azure Service Bus

This page covers the Azure Service Bus feature from the [Azure Activities](azure-activities.md) extension library.

The [IntegrationSoup.AzureActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.AzureActivities.msi) installer turns on two built-in workflow types:

- **Azure Service Bus** as a receiver
- **Azure Service Bus Sender** as an activity

Once the installer has been run, these appear in the Workflow Designer like any other Integration Soup feature.

## Download

- [IntegrationSoup.AzureActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.AzureActivities.msi)
- [Website tutorial page](https://www.integrationsoup.com/ExtensionLibraries/AzureServiceBusActivities.html)

## Turning the activities on

1. Run the Azure Activities MSI on the Integration Soup server.
2. Restart the Integration Soup service if it is not restarted automatically.
3. Close and reopen any open Workflow Designer windows so the activity list is refreshed.
4. Look for **Azure Service Bus** as a receiver type and **Azure Service Bus Sender** as an activity type.

## Using Azure Service Bus Sender

1. Add **Azure Service Bus Sender** after the step that prepares the message you want to send.
2. In the **Outbound Message** section, use **Insert Activity Message** so the current workflow content becomes the Service Bus message body.
3. Fill in the connection and destination fields below.
4. Use the advanced metadata fields only when the receiving system expects them.

## Sender parameters

### Connection String

Enter the Azure Service Bus connection string for the namespace.

### Target Type

Choose **Queue** or **Topic**.

### Queue or Topic

Enter the queue name or topic name to send to.

### Content Type

Usually leave this as `text/plain`, or change it to something like `application/json` when appropriate.

### Encoding

Usually leave this as `utf-8`.

### Advanced metadata

Use these fields only when needed by the receiving system:

- `Subject`
- `Message Id`
- `Correlation Id`
- `Session Id`
- `Reply To`
- `Reply To Session`
- `To`
- `Application Properties`

## Sender message body

The sender uses the current workflow message as the Service Bus message body. In most workflows this is text such as HL7, JSON, XML, or CSV.

If you choose a binary message type in the normal sender settings, Integration Soup sends the actual bytes rather than UTF-8 text.

## Sender response message

The sender returns a text response confirming that the Service Bus message was sent successfully.

## Using Azure Service Bus as a receiver

1. Create or edit a workflow and choose **Azure Service Bus** as the receiver.
2. Fill in the connection and destination fields below.
3. In the **Inbound Message** section, choose the message type that matches what you expect to receive, such as HL7, Text, Binary, or DICOM.
4. Optionally paste a sample message into the **Message Template** area to make bindings and later workflow design easier.

## Receiver parameters

### Connection String

Enter the Azure Service Bus connection string.

### Target Type

Choose **Queue** or **Topic Subscription**.

### Queue or Topic

Enter the queue name or topic name to receive from.

### Subscription

Required when **Topic Subscription** is selected.

### Receive Mode

Choose:

- **Peek Lock** to complete or abandon the message after workflow processing
- **Receive and Delete** to remove it immediately when received

### Prefetch Count

Leave this at `0` unless you have a reason to tune throughput.

### Encoding

Usually leave this as `utf-8` for text payloads.

### Dead-letter failed messages

When enabled in Peek Lock mode, failed workflow processing moves the message to the dead-letter queue instead of returning it to the queue.

### Expose application properties as variables

When enabled, Service Bus application properties become workflow variables using the prefix you provide.

The default prefix is `ServiceBusApp_`, so a property named `EventType` becomes `ServiceBusApp_EventType`.

## Receiver variables

The receiver makes Service Bus metadata available as workflow variables, including:

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

If application property exposure is enabled, individual application properties are also added as variables.

## Typical uses

- Receiving HL7 or FHIR work items from Azure Service Bus and routing them into Integration Soup workflows
- Publishing workflow output to Azure queues for downstream cloud processing
- Using topic subscriptions to separate partner, facility, or event-specific message streams
