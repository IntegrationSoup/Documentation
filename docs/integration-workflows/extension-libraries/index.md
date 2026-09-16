# Extension Libraries

Integration Soup Extension Libraries add extra workflow features that you can install alongside Integration Soup and Integration Host.

These extensions are distributed as MSI installers and are documented here as product features you can add to your workflows.

## Available extension libraries

- [HTML to PDF](html-to-pdf.md)
- [RTF to PDF](rtf-to-pdf.md)
- [Azure Activities](azure-activities.md)
- [AWS Activities](aws-activities.md)
- [Encryption Activities](encryption-activities.md)
- [SFTP Activities](sftp-activities.md)
- [ZIP Activities](zip-activities.md)
- [Validate HL7 Transformer](validate-hl7-transformer.md)
- [HL7 Value Transformers](hl7-value-transformers.md)

## Download installers

All extension library installers are published here:

- [Integration Soup Extension Libraries Directory](https://www.integrationsoup.com/ExtensionLibraries/index.html)

Direct MSI links:

- [IntegrationSoup.HtmlToPdfActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.HtmlToPdfActivities.msi)
- [IntegrationSoup.RtfToPdfActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.RtfToPdfActivities.msi)
- [IntegrationSoup.AzureActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.AzureActivities.msi)
- [IntegrationSoup.AwsActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.AwsActivities.msi)
- [IntegrationSoup.EncryptionActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.EncryptionActivities.msi)
- [IntegrationSoup.SftpActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.SftpActivities.msi)
- [IntegrationSoup.ZipActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.ZipActivities.msi)
- [IntegrationSoup.ValidateHl7Transformer.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.ValidateHl7Transformer.msi)
- [IntegrationSoup.HL7ValueTransformers.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.HL7ValueTransformers.msi)

## .NET Framework prerequisite

The bridge-enabled Extension Library installers require **Microsoft .NET Framework 4.8 or later** on each
computer where their MSI is installed. This applies to all ten packages, including
HL7 Value Transformers and Validate HL7 Transformer, because installation uses a
shared helper built for .NET Framework 4.8. .NET Framework 4.8.1 also satisfies this
requirement; .NET Framework 4.7.2 does not.

The installer checks the framework before a new installation or upgrade. If it
is missing or too old, setup stops with a message directing the user to the
[.NET Framework 4.8 Runtime download](https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48).
Install the runtime, restart Windows if requested, and run the Extension Library
installer again. Maintenance and uninstall remain available if the runtime is
removed after installation.

To check a computer, run this single line in PowerShell:

```powershell
(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full').Release
```

A release value of **528040 or higher** meets the requirement. The value
**461814** identifies .NET Framework 4.7.2 and requires an update. See
[Microsoft's framework detection guidance](https://learn.microsoft.com/en-us/dotnet/framework/install/how-to-determine-which-versions-are-installed).

## General installation flow

1. Run the MSI on the Integration Soup server.
2. Restart the Integration Soup service if it is not restarted automatically.
3. Open the Workflow Designer and add the new activity to your workflow.
4. Configure the activity parameters and message template as described on the extension page for that feature.

## Notes

- Some extensions have extra server prerequisites, such as a browser for HTML to PDF or LibreOffice for RTF to PDF.
- ZIP Activities uses a persistent out-of-process runner and the .NET ZIP implementation included with the installer; no separate ZIP application is required.
- In version 4, HL7 Value Transformers runs as transformer code loaded from `Custom Libraries`.
- [Version 5 deployment](version-5-deployment.md) uses registered isolated runners and requires bridge-enabled Extension Library installers.
- Each extension page below explains the exact parameters to set, what to place into the activity message, and what the response message contains.
