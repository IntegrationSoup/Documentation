# Azure Activities

The Azure Activities Extension Library adds Azure-specific workflow activities to Integration Soup.

## Activities included

- **Azure Blob Upload**
- **Azure Blob Download**
- **Azure Service Bus Sender**
- **Azure Service Bus Receiver**

Use this extension library to archive workflow output in Azure Blob Storage, publish messages to Azure Service Bus, or receive messages from Azure Service Bus.

## Download

- [IntegrationSoup.AzureActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.AzureActivities.msi)
- [Website tutorial page](https://www.integrationsoup.com/ExtensionLibraries/AzureActivities.html)

## Included features

- [Azure Blob Storage](../../workflow/extension-libraries/azure-blob-storage.md)
- [Azure Service Bus](../../workflow/extension-libraries/azure-service-bus-activities.md)

## Installing the Azure feature pack

1. Install the MSI on the Integration Soup server.
2. Restart the Integration Soup service if needed.
3. Restart the workflow host service if needed.
4. Open the Workflow Designer. The Azure activities appear only after the extension is installed on the server you are connected to.
5. Add the Azure activity you want to use.

## Activity references

- [Azure Service Bus Sender](../sender-activities/azure-service-bus-sender.md)
- [Azure Service Bus Receiver](../receiver-activities/azure-service-bus-receiver.md)

## Azure Blob Upload

Add **Azure Blob Upload** after the step that produces the content you want to upload.

In the activity message template, use **Insert Activity Message** to bring in the content from the receiver or earlier activity.

**New Container Access** is optional. Blank or `Private` requests private access when creating a container; `Blob` explicitly requests anonymous blob reads for a newly created container, without anonymous container listing. Azure account policy must permit public access. An account-policy rejection fails the activity without a permission fallback.

**Create Container If Missing** defaults to blank/`False`, writing to an existing container only. Select `True` to permit a creation request; New Container Access then applies. Public creation requires both explicit options. Separate provisioning lets the workflow use narrower write credentials.

Existing containers retain their ACLs, including public access. Existing saved workflows contain no creation or public/private setting and require an existing container when those options are omitted. Select Create Container If Missing=True to create future containers, and select `Blob` explicitly if they must support anonymous reads. This does not migrate saved settings or existing Azure permissions. Azure's `$web` static website endpoint has separate public-serving semantics.

**Overwrite Existing Blob** defaults to blank/`False`, using `If-None-Match: *` to fail on an existing blob. Select `True` to replace content; optional **Expected ETag** then requires an atomic content/properties match. Expected ETag without explicit replacement is rejected. Saved workflows with no replacement setting fail on duplicate names; set True explicitly where replacement is intended.

Uploads accept up to 8 MiB and use one known-length PUT. Larger input is rejected before an Azure request. The activity does not delete the blob or snapshots first; Azure retains snapshots on replacement. **AzureBlobETag** and **AzureBlobVersionId** return the write result. Replacement uses default content properties and empty metadata rather than merging the old metadata, properties or tags. ETags do not guard tag-only changes; no tag-preservation guarantee is made.

Upload SDK retries are disabled. A lost response can leave an unknown outcome; inspect the object before manually retrying. A later 412 does not prove an earlier write failed. No delete fallback or whole-activity replay is performed.

## Azure Blob Download

Download needs no input message. Set **Connection String**, **Container Name** and **File Name** (an exact blob key rather than a URL). Case, Unicode, prefixes and significant whitespace are preserved. A connection string with a read-only SAS works; the activity reads only blob properties and content and does not create, list, delete or change access policies.

Leading and trailing slashes are preserved. Keys containing URI-normalized dot segments, such as `a/../b`, are rejected before a read or write so they cannot target another object.

The default response is **Binary**. Binary and DICOM preserve file bytes. Select a text response and an optional **Text Encoding** to decode the content. Blank uses strict UTF-8; invalid bytes fail. A UTF-8 BOM is preserved as U+FEFF. Content type is returned as metadata and does not choose an encoding or decompress content.

**Maximum Download MB** defaults to 8 MiB and accepts 1–8. Both properties and the stream byte count enforce the cap. This conservative bound leaves room for base64 and nested JSON escaping inside the default 64 MiB version 5 bridge envelope. Larger files need another transfer path.

Optional **Version ID** selects a stored version without altering the exact blob key, including leading and trailing slashes. **Expected ETag** rejects a changed object and requires a specific ETag; wildcard `*` is rejected for both Download and Upload. Every content GET is pinned to the ETag inspected by HEAD, even when Expected ETag is blank. Incomplete content fails. `AzureBlobMetadataJson` returns `name`, `size`, `etag`, `contentType`, `versionId` and `lastModifiedUtc`.

An interrupted download can resume at most five times, preserving the selected key/version and ETag. One two-minute limit covers the entire read; an earlier version 5 bridge deadline or cancellation also stops it. HTTP request retries are disabled, and the bridge never automatically replays a whole activity after uncertain dispatch. Cancelled or exhausted transfers fail without returning partial content. Missing or denied blobs, invalid credentials or encodings, oversized content and transport failures also fail the invocation.

## Runtime requirements

The activity DLL remains dependency-light and calls its paired persistent .NET Framework runner synchronously. Version 5 discovers the activities through the same runner's bridge. The installer requires .NET Framework 4.8 or later, installs the activity DLL in all three product Custom Libraries folders and installs the runner only under Integration Host Server. It does not include the host API DLL. The host service account needs network access and permission for the selected Azure operation.

## What the installer adds

- **Blob Storage** support through **Azure Blob Upload** and **Azure Blob Download**, including text, Binary and DICOM content
- **Azure Service Bus** support through the built-in receiver and sender workflow types

## Typical uses

- Archiving inbound or outbound messages to Azure
- Publishing CSV, XML, JSON, or other text output to Blob Storage
- Storing binary exports or DICOM files in Azure Blob Storage
- Dropping workflow output where other Azure services will pick it up
- Sending workflow messages to Azure Service Bus queues or topics
- Receiving inbound Azure Service Bus messages into a workflow
