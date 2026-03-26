# Azure Activities

The Azure Activities Extension Library adds Azure-specific workflow activities to Integration Soup.

## Activities included

- **Send Blob**
- **Azure Service Bus Sender**
- **Azure Service Bus Receiver**

Use this extension library to archive workflow output in Azure Blob Storage, publish messages to Azure Service Bus, or receive messages from Azure Service Bus.

## Download

- [IntegrationSoup.AzureActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.AzureActivities.msi)
- [Website tutorial page](https://www.integrationsoup.com/ExtensionLibraries/AzureActivities.html)

## Included features

- [Azure Blob Storage](azure-blob-storage.md)
- [Azure Service Bus](azure-service-bus-activities.md)

## Installing the Azure feature pack

1. Install the MSI on the Integration Soup server.
2. Restart the Integration Soup service if needed.
3. Restart the workflow host service if needed.
4. Open the Workflow Designer. The Azure activities appear only after the extension is installed on the server you are connected to.
5. Add the Azure activity you want to use.

## Activity references

- [Azure Service Bus Sender](../sender-activities/azure-service-bus-sender.md)
- [Azure Service Bus Receiver](../receiver-activities/azure-service-bus-receiver.md)

## Send Blob

Add **Send Blob** after the step that produces the text you want to upload.

In the activity message template, use **Insert Activity Message** to bring in the text from the receiver or earlier activity.

## What the installer adds

- **Blob Storage** support through the **Azure Blob Upload** activity
- **Azure Service Bus** support through the built-in receiver and sender workflow types

## Typical uses

- Archiving inbound or outbound messages to Azure
- Publishing CSV, XML, JSON, or other text output to Blob Storage
- Dropping workflow output where other Azure services will pick it up
- Sending workflow messages to Azure Service Bus queues or topics
- Receiving inbound Azure Service Bus messages into a workflow
