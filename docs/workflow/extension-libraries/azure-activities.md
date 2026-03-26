# Azure Activities

The Azure Activities Extension Library is the Azure feature pack for Integration Soup.

One installer adds the **Azure Blob Upload** activity and turns on the built-in Azure Service Bus workflow activities in the Workflow Designer.

## Download

- [IntegrationSoup.AzureActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.AzureActivities.msi)
- [Website tutorial page](https://www.integrationsoup.com/ExtensionLibraries/AzureActivities.html)

## Included features

- [Azure Blob Storage](azure-blob-storage.md)
- [Azure Service Bus](azure-service-bus-activities.md)

## Installing the Azure feature pack

1. Install the MSI on the Integration Soup server.
2. Restart the Integration Soup service if needed.
3. Close and reopen any open Workflow Designer windows.
4. Use the linked feature pages above for the exact workflow steps you want.

## What the installer adds

- **Blob Storage** support through the **Azure Blob Upload** activity
- **Azure Service Bus** support through the built-in receiver and sender workflow types

## Typical uses

- Archiving workflow output in Azure Blob Storage
- Sending messages to Azure queue or topic consumers
- Receiving workloads from Azure Service Bus and routing them through Integration Soup
