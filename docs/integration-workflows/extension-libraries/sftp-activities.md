# SFTP Activities

The SFTP Activities Extension Library adds two activities to Integration Soup:

- **SFTP Upload**
- **SFTP Download**

Use them when you need to exchange files securely with partner systems over SFTP.

## Download

- [IntegrationSoup.SftpActivities.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.SftpActivities.msi)
- [Website tutorial page](https://www.integrationsoup.com/ExtensionLibraries/SftpActivities.html)

## Using SFTP Upload in a workflow

1. Install the MSI on the Integration Soup server.
2. Restart the Integration Soup service if needed.
3. Add **SFTP Upload** after the step that produces the content you want to send.
4. In the activity message template, use **Insert Activity Message** from the receiver or earlier activity that contains the content to upload.
5. Fill in the connection and destination parameters below.

## Using SFTP Download in a workflow

1. Add **SFTP Download** where the workflow needs to fetch a file from a partner server.
2. Fill in the connection and remote file parameters.
3. Use the response message from this activity in the next workflow step.

## Parameters

### Common connection parameters

- **Host Name**: the SFTP server name, for example `sftp.partner.example`
- **Port**: leave blank for port `22`, or enter a different positive port number if required
- **User Name**: the login user for the SFTP server
- **Password**: the login password when password authentication is used
- **Private Key Path**: the full path on the Integration Soup server to the private key file when key-based authentication is used
- **Private Key Passphrase**: the passphrase for the private key, if required
- **SSH Host Key Fingerprint**: the server fingerprint in WinSCP format, for example `ssh-rsa 2048 xx:xx:xx:xx`
- **Remote Path**: the full remote file path

Examples:

- upload: `/outbound/messages/ADT_A01_20260320.hl7`
- download: `/inbound/orders/order001.hl7`

### Upload-only parameters

- **Create Remote Directory**: set to `true` if the remote folder should be created automatically when it does not exist
- **Treat Message As Base64**: set to `true` when the activity message already contains base64-encoded file bytes

### Download-only parameters

- **Delete Remote File After Download**: set to `true` when the source file should be removed after a successful download

## Activity message

### SFTP Upload

Place the content to upload into the activity message.

- For plain HL7, CSV, XML, JSON, or another text payload, insert that text normally and leave **Treat Message As Base64** as `false`.
- If an earlier step returns binary data as base64 text and you want to upload the real file bytes, insert that base64 content and set **Treat Message As Base64** to `true`.

### SFTP Download

This activity does not require an incoming activity message.

It works from the connection settings and the remote path you provide.

## Response message

- **SFTP Upload** returns a **Text** message confirming the upload
- **SFTP Download** returns a **Binary** response message containing the downloaded file bytes as base64 text

## Typical uses

- Sending generated reports or documents to external partners
- Polling for partner files that need to be imported into Integration Soup
- Automating traditional file-based integrations inside the Workflow Designer
