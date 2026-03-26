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
- [Validate HL7 Transformer](validate-hl7-transformer.md)

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
- [IntegrationSoup.ValidateHl7Transformer.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.ValidateHl7Transformer.msi)

## General installation flow

1. Run the MSI on the Integration Soup server.
2. Restart the Integration Soup service if it is not restarted automatically.
3. Open the Workflow Designer and add the new activity to your workflow.
4. Configure the activity parameters and message template as described on the extension page for that feature.

## Notes

- Some extensions have extra server prerequisites, such as a browser for HTML to PDF or LibreOffice for RTF to PDF.
- Each extension page below explains the exact parameters to set, what to place into the activity message, and what the response message contains.
