# Encryption Activities

The Encryption Activities Extension Library adds two activities to Integration Soup:

- **Encrypt Message**
- **Decrypt Message**

Use them when you need to protect message content before it is stored or transmitted, and then recover the original text later in the workflow when needed.

## Download

- [IntegrationSoup.EncryptionActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.EncryptionActivities.msi)
- [Website tutorial page](https://www.integrationsoup.com/ExtensionLibraries/EncryptionActivities.html)

## Using it in a workflow

1. Install the MSI on the server.
2. Restart the Integration Soup service if needed.
3. Add **Encrypt Message** where you want plain text to become encrypted text, or **Decrypt Message** where you want encrypted text turned back into readable text.
4. In the activity message template, insert the source content from the receiver or earlier activity.
5. Enter the same encryption key in both the encrypt and decrypt steps, preferably by inserting a protected variable rather than typing it directly into the workflow.

## Parameters

### Encryption Key

Enter the shared secret used for both encryption and decryption.

A longer key is better. The built-in guidance recommends at least 12 characters.

## Activity message

- For **Encrypt Message**, place the plain text to protect into the activity message.
- For **Decrypt Message**, place the encrypted text into the activity message.

A common pattern is to use **Insert Activity Message** so the text flows directly from the previous workflow step.

## Response message

- **Encrypt Message** returns encrypted text.
- **Decrypt Message** returns the original readable text.

Both return **Text** messages that can be passed to later workflow steps.

## Typical uses

- Protecting temporary payloads before saving them outside the workflow
- Encrypting message content before partner delivery or storage
- Decrypting inbound content that arrives already protected
