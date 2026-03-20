# HTML to PDF

The HTML to PDF Extension Library adds the **Convert HTML to PDF** activity to Integration Soup.

Use it when your workflow produces letters, reports, forms, or other styled HTML that should be turned into a PDF inside the workflow.

## Download

- [IntegrationSoup.HtmlToPdfActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.HtmlToPdfActivities.msi)
- [Website tutorial page](https://www.integrationsoup.com/ExtensionLibraries/HtmlToPdfActivities.html)

## Requirements

- Chrome or Edge must be installed on the Integration Soup server.
- Chrome is recommended when the Integration Soup service runs under a Windows service account.
- If required, set `HTMLTOPDF_BROWSER_PATH` to the browser executable you want to use.

## Using it in a workflow

1. Install the MSI on the server machine where Integration Soup is installed.
2. Restart the Integration Soup service if needed.
3. Add **Convert HTML to PDF** after the workflow step that prepares the HTML.
4. In the activity message template, place the HTML directly or use **Insert Activity Message** or **Insert Variable** to bring the HTML in from an earlier step.
5. Use the response message from this activity wherever the generated PDF is needed next.

## Parameters

This activity has no extra parameter fields.

Everything it needs comes from the activity message.

## Activity message

Place the HTML markup you want to convert into the activity message.

A complete HTML document is best, but a simple fragment will also work. For example:

```html
<html>
  <body>
    <h1>Discharge Summary</h1>
    <p>Patient discharged in stable condition.</p>
  </body>
</html>
```

If the HTML is produced earlier in the workflow, insert that earlier activity message so the latest HTML is always used.

## Response message

The response message is a **Binary** message containing the generated PDF.

Inside Integration Soup, binary content is represented as base64 text.

## Typical uses

- Creating referral letters and discharge summaries as PDFs
- Converting generated HTML reports into PDF for storage or delivery
- Producing a PDF before a later step writes, sends, or uploads it

## Troubleshooting

- If Edge fails under a service account, install Chrome and point `HTMLTOPDF_BROWSER_PATH` at Chrome.
- If no PDF is produced, verify the activity message contains valid HTML and the server browser is installed correctly.
