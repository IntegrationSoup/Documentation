# RTF to PDF

The RTF to PDF Extension Library adds the **Convert RTF to PDF** activity to Integration Soup.

Use it when your workflow receives referrals, letters, or reports as RTF and you want a PDF result for storage, review, or onward delivery.

## Download

- [IntegrationSoup.RtfToPdfActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.RtfToPdfActivities.msi)
- [Website tutorial page](https://www.integrationsoup.com/ExtensionLibraries/RtfToPdfActivities.html)

## Requirements

- LibreOffice must be installed on the Integration Soup server.
- If LibreOffice is not installed in the default location, set `RTFTOPDF_LIBREOFFICE_PATH` to `soffice.exe` or `soffice.com`.

## Using it in a workflow

1. Install the MSI on the Integration Soup server.
2. Install LibreOffice on that same server if it is not already present.
3. Restart the Integration Soup service if needed.
4. Add **Convert RTF to PDF** after the step that supplies the RTF content.
5. In the activity message template, place the RTF directly or use **Insert Activity Message** or **Insert Variable** to bring it in from an earlier step.
6. Use the response message from this activity wherever the PDF is needed next.

## Parameters

This activity has no extra parameter fields.

Everything it needs comes from the activity message.

## Activity message

Place the raw RTF text into the activity message.

Example:

```text
{\rtf1\ansi\deff0{\fonttbl{\f0 Calibri;}}\f0\fs24 Sample RTF content.\par}
```

If the RTF is produced earlier in the workflow, insert that earlier activity message so the converter always uses the current content.

## Response message

The response message is a **Binary** message containing the generated PDF.

Inside Integration Soup, binary content is represented as base64 text.

## Typical uses

- Converting embedded clinical letters into PDF
- Normalizing rich text content into a consistent output format
- Producing PDF documents before a later workflow step stores or delivers them

## Troubleshooting

- If conversion fails, verify LibreOffice is installed and accessible to the Integration Soup service.
- If LibreOffice is installed in a custom location, set `RTFTOPDF_LIBREOFFICE_PATH` and restart the service.
