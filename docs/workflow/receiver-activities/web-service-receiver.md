**Web Service Receiver (WebServiceReceiverSetting)**

## What this setting controls

`WebServiceReceiverSetting` defines a SOAP web service endpoint that accepts a single string message parameter, converts that payload into an Integration Soup message, runs the workflow, and returns a string response through the SOAP operation.

This document is about the persisted workflow JSON contract and the runtime effects of those fields.

## Scope

This setting combines:

- WCF/SOAP endpoint hosting
- optional HTTPS and username/password authentication
- inbound message typing
- workflow response generation

Only serialized workflow JSON fields are covered.

## Operational model

```mermaid
flowchart TD
    A[SOAP client calls SendMessage(string message)] --> B[Optional HTTPS and username/password validation]
    B --> C[Extract string payload from SOAP body]
    C --> D[Create workflow message using MessageType]
    D --> E[Run filters, variable transformers, activities]
    E --> F[Choose response mode]
    F --> G[Return string result in SOAP response body]
```

Important non-obvious points:

- The SOAP contract is effectively one string-in, string-out operation.
- The payload inside the SOAP body is treated as plain text and then parsed according to `MessageType`.
- The receiver is not supported in the .NET Core host path. It only runs when the workflow is hosted in the older .NET Framework application path.
- The endpoint URL is built from the machine name, port, and `ServiceName`. It is not authored as an arbitrary full URL.

## JSON shape

Typical object shape:

```json
{
  "$type": "HL7Soup.Functions.Settings.Receivers.WebServiceReceiverSetting, HL7SoupWorkflow",
  "Id": "db7d3a7b-c697-4cb1-90e5-76224e9b5a3d",
  "Name": "Lab Order Service",
  "WorkflowPatternName": "Lab Order Service",
  "Disabled": false,
  "MessageType": 4,
  "ReceivedMessageTemplate": "<Order><Id>123</Id></Order>",
  "MessageTypeOptions": null,
  "ServiceName": "LabOrderService",
  "Port": 8085,
  "UseSsl": true,
  "UseDefaultSSLCertificate": true,
  "CertificateThumbPrint": "",
  "Authentication": false,
  "AuthenticationUserName": "",
  "AuthenticationPassword": "",
  "UseSoap12": false,
  "IncludeHttpLocalHostEndpoint": false,
  "LocalHostEndpointPort": 8081,
  "ResponseMessageTemplate": "<Result><Accepted>true</Accepted></Result>",
  "ReturnCustomResponse": true,
  "ReturnNoResponse": false,
  "ReponsePriority": 2,
  "Filters": "00000000-0000-0000-0000-000000000000",
  "VariableTransformers": "00000000-0000-0000-0000-000000000000",
  "Transformers": "00000000-0000-0000-0000-000000000000",
  "Activities": [
    "11111111-1111-1111-1111-111111111111"
  ],
  "AddIncomingMessageToCurrentTab": true
}
```

## Endpoint fields

### `ServiceName`

The path portion of the SOAP endpoint, without a leading slash.

Examples:

- `"LabOrderService"`
- `"HL7Soup/WebServiceReceiverService"`

Runtime URL pattern:

- HTTP: `http://<machine-name>:<port>/<ServiceName>`
- HTTPS: `https://<machine-name>:<port>/<ServiceName>`
- WSDL: the same URL with `?wsdl`

Rules and effects:

- Must not start with `/`.
- Must not end with `/`.
- The UI strips reserved URL characters such as `& ; ? : @ = + $ ,` and spaces.
- The generated endpoint uses the machine name, not `localhost`.

Important outcome:

- Clients that call `localhost` may not match the intended externally reachable address. The product guidance and generated URL are based on the machine name.

### `Port`

TCP port used by the WCF service host.

If the address is already registered or the port is already in use, startup fails.

### `UseSoap12`

Controls the SOAP binding version.

Behavior:

- `false`: SOAP 1.1 style binding
- `true`: SOAP 1.2 style binding

Important outcome:

- This changes the service binding and the SOAP envelope/content-type expected by clients.
- The current Web Service Receiver dialog does not expose this property, but the runtime honors it if it is present in JSON.
- If the setting is opened and saved in the current receiver dialog, this value is likely to revert to the dialog's implicit default.

## HTTPS and certificate fields

### `UseSsl`

Enables HTTPS for the main endpoint.

Behavior:

- `false`: plain HTTP
- `true`: HTTPS transport security

Important outcome:

- Username/password authentication only has runtime effect when this is `true`.

### `UseDefaultSSLCertificate`

Controls which server certificate is used for HTTPS startup.

- `true`: use the Integration Soup default/generated certificate
- `false`: use a custom certificate identified by `CertificateThumbPrint`

### `CertificateThumbPrint`

Thumbprint of the custom server certificate when:

- `UseSsl = true`
- `UseDefaultSSLCertificate = false`

If a custom certificate is intended and this field is blank, startup is not viable.

### Legacy serialized certificate fields

These fields still serialize but are not the practical way to author new JSON for this receiver:

- `CertificateFromFile`
- `CertificatePath`
- `CertificatePassword`
- `CertificateStoreLocation`
- `CertificateStoreName`
- `CertificateX509FindType`

For current Web Service receiver behavior, `CertificateThumbPrint` is the meaningful custom-certificate selector. New JSON should omit the legacy certificate-location fields unless you are maintaining older existing workflow files.

## Authentication fields

### `Authentication`

Enables username/password validation for the SOAP service.

Actual behavior:

- only meaningful when `UseSsl = true`
- ignored for plain HTTP

### `AuthenticationUserName`

Expected user name when `Authentication = true`.

### `AuthenticationPassword`

Expected password when `Authentication = true`.

Important outcome:

- This is SOAP message-credential behavior over HTTPS, not a general-purpose HTTP auth layer.
- Manual JSON can set these fields even when they have no effect because `UseSsl` is `false`.

## Advanced endpoint fields

These fields are serialized and honored by the runtime, but they are not part of the normal current receiver dialog flow.

### `IncludeHttpLocalHostEndpoint`

When `true` and `UseSsl = true`, the runtime also creates a second unsecured HTTP endpoint.

Important outcome:

- Despite the name, this is not restricted to `localhost` in the generated address logic.
- This creates an additional plain HTTP entry point for the same service.
- If the goal is HTTPS-only exposure, leave this `false`.

### `LocalHostEndpointPort`

Port used by the additional unsecured endpoint when `IncludeHttpLocalHostEndpoint = true`.

Default:

- `8081`

Recommended guidance:

- Treat this as advanced JSON-only behavior.
- Do not enable it unless you explicitly need a second plain HTTP endpoint and have tested it in your hosting environment.

## Message fields

### `MessageType`

Defines how the incoming SOAP string payload is interpreted inside Integration Soup and how `ResponseMessageTemplate` is typed.

For `WebServiceReceiverSetting`, the current UI allows:

- `1` = `HL7`
- `4` = `XML`
- `5` = `CSV`
- `11` = `JSON`
- `13` = `Text`
- `14` = `Binary`
- `16` = `DICOM`

Important outcome:

- The transport is SOAP, but the inner payload can still be HL7, XML, JSON, CSV, Text, Binary, or DICOM as far as Integration Soup is concerned.
- `Binary` is not raw SOAP attachment handling. The operation still receives a string payload.

### `MessageTypeOptions`

Optional per-message-type options object.

The most common useful case is CSV:

```json
{
  "$type": "HL7Soup.Workflow.MessageTypeOptions.CSVMessageTypeOption, HL7SoupWorkflow",
  "HasHeader": true,
  "Header": "Col1,Col2",
  "HasFooter": false,
  "Footer": "",
  "Delimiter": ","
}
```

For most SOAP/XML or SOAP/JSON scenarios, this is omitted.

### `ReceivedMessageTemplate`

Sample inbound payload used for bindings and design-time structure.

This does not change the generated SOAP contract. It only helps workflow authoring.

## Response fields

### `ResponseMessageTemplate`

The custom response payload template used when `ReturnCustomResponse = true`.

The result is returned as the SOAP operation's string return value.

### `ReturnCustomResponse`

Controls whether the response is built from `ResponseMessageTemplate`.

Default for `WebServiceReceiverSetting` is `true`.

This is the normal mode for SOAP receivers carrying XML, JSON, text, or other non-HL7 payloads.

### `ReturnNoResponse`

When `true`, the receiver returns an empty string response body instead of a populated payload.

Important outcome:

- The SOAP call still returns from the operation, but the string result is empty.
- The current receiver dialog does not expose this field directly.

### `ReponsePriority`

JSON enum values:

- `0` = `UponArrival`
- `1` = `AfterValidation`
- `2` = `AfterAllProcessing`

Behavior:

- `UponArrival`: build the response before filters and activities complete; remaining processing continues asynchronously
- `AfterValidation`: build the response after receiver filters and variable transformers, but before activities complete
- `AfterAllProcessing`: wait for activities to complete, then return the final response

Practical effects:

- Earlier response priorities return faster to the SOAP caller.
- Earlier response priorities cannot depend on outputs from later activities.
- If processing later fails after an early response was already returned, the caller does not see that failure.

### `Transformers`

Receiver response transformers.

These are meaningful when `ReturnCustomResponse = true` and allow the response payload to be adjusted after the template is materialized.

## Advanced JSON-only response modes

These inherited fields serialize and the runtime honors them, but the current Web Service Receiver dialog is not designed around them. Manual JSON using these modes can be lost or reset if the setting is reopened and saved in the UI.

### `ReturnResponseFromActivity`

When `true`, return the response produced by a downstream activity instead of using `ResponseMessageTemplate`.

### `ReturnResponseFromActivityId`

GUID of the activity whose response should be returned.

### `ReturnResponseFromActivityName`

Helper name for the chosen activity, mainly useful for diagnostics if that activity is missing or filtered out.

### `ReturnApplicationAccept`

Generate an automatic accept response.

### `ReturnApplicationReject`

Generate an automatic reject response.

### `RejectMessage`

Reject text used with `ReturnApplicationReject`.

### `ReturnApplicationError`

Generate an automatic error response.

### `ErrorMessage`

Error text used with `ReturnApplicationError`.

Critical limitation:

- Automatic accept/reject/error generation is only meaningful for message types that implement those generated responses.
- For non-HL7 payloads such as XML, JSON, Text, Binary, and DICOM, built-in generated responses may be empty or not useful.
- For most SOAP integrations, `ReturnCustomResponse = true` is the correct mode.

## Workflow linkage fields

### `Activities`

Ordered list of downstream workflow activity GUIDs.

### `Filters`

GUID of the receiver filter set.

If filters reject the message, workflow processing stops at the receiver and the response behavior depends on the configured response mode.

### `VariableTransformers`

GUID of the receiver-level variable transformer set.

These run after filters and before activities.

### `AddIncomingMessageToCurrentTab`

Controls whether the inbound message is added to the current list in the desktop product.

This does not change SOAP endpoint behavior.

### `Disabled`

If `true`, the setting is disabled.

### `WorkflowPatternName`

Workflow display/pattern name.

### `Id`

GUID of this receiver setting.

### `Name`

User-facing name of this receiver setting.

## Defaults for a new `WebServiceReceiverSetting`

Important defaults:

- `UseSsl = false`
- `IncludeHttpLocalHostEndpoint = false`
- `LocalHostEndpointPort = 8081`
- `Port = 8080`
- `ServiceName = "HL7Soup"`
- `Authentication = false`
- `CertificateFromFile = true`
- `UseDefaultSSLCertificate = true`
- `ReturnCustomResponse = true`
- `ReponsePriority = 2`
- `AddIncomingMessageToCurrentTab = true`

## Recommended authoring patterns

### SOAP endpoint carrying XML

Use:

- `MessageType = 4`
- `UseSoap12 = false` or `true` depending on the client contract
- `ReturnCustomResponse = true`
- XML content in both `ReceivedMessageTemplate` and `ResponseMessageTemplate`

### SOAP endpoint carrying JSON as string content

Use:

- `MessageType = 11`
- `ReturnCustomResponse = true`
- JSON text in `ResponseMessageTemplate`

This is valid if the SOAP contract intentionally carries JSON inside the string body.

### HTTPS SOAP service with fixed custom certificate

Use:

- `UseSsl = true`
- `UseDefaultSSLCertificate = false`
- `CertificateThumbPrint = "<thumbprint>"`

Do not rely on the legacy certificate-location fields for new JSON.

### Username/password protected SOAP service

Use:

- `UseSsl = true`
- `Authentication = true`
- `AuthenticationUserName = "<user>"`
- `AuthenticationPassword = "<password>"`

Do not expect this to protect a plain HTTP endpoint.

## Pitfalls and hidden outcomes

- The Web Service receiver is not supported when the workflow runs in the .NET Core host path. It requires the .NET Framework host path.
- `UseSoap12` is runtime-significant but not exposed by the current receiver dialog.
- `Authentication = true` has no meaningful effect unless `UseSsl = true`.
- The service URL is based on the machine name, not an arbitrary host name and not the caller's preferred alias.
- Clients often need to consume `?wsdl` from the generated machine-name URL rather than from `localhost`.
- `Binary` is not raw binary transport. The SOAP contract is still string-based.
- `IncludeHttpLocalHostEndpoint = true` creates a second plain HTTP endpoint, which can unintentionally weaken an HTTPS-only design.
- Manual JSON for advanced response modes such as `ReturnResponseFromActivity` can be lost when the setting is reopened and saved in the UI.
- Legacy certificate fields still serialize but are not the practical fields to author for current behavior.

## Minimal examples

### Minimal SOAP 1.1 XML receiver

```json
{
  "$type": "HL7Soup.Functions.Settings.Receivers.WebServiceReceiverSetting, HL7SoupWorkflow",
  "Id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "Name": "Lab Order Service",
  "MessageType": 4,
  "ServiceName": "LabOrderService",
  "Port": 8085,
  "UseSsl": false,
  "UseSoap12": false,
  "ResponseMessageTemplate": "<Result><Accepted>true</Accepted></Result>",
  "ReturnCustomResponse": true,
  "Activities": []
}
```

### SOAP 1.2 JSON-in-string receiver

```json
{
  "$type": "HL7Soup.Functions.Settings.Receivers.WebServiceReceiverSetting, HL7SoupWorkflow",
  "Id": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
  "Name": "JSON Service",
  "MessageType": 11,
  "ServiceName": "JsonService",
  "Port": 8090,
  "UseSsl": true,
  "UseDefaultSSLCertificate": true,
  "UseSoap12": true,
  "ResponseMessageTemplate": "{ \"accepted\": true }",
  "ReturnCustomResponse": true,
  "Activities": []
}
```

### HTTPS SOAP service with authentication

```json
{
  "$type": "HL7Soup.Functions.Settings.Receivers.WebServiceReceiverSetting, HL7SoupWorkflow",
  "Id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
  "Name": "Secure SOAP Service",
  "MessageType": 4,
  "ServiceName": "SecureOrderService",
  "Port": 8443,
  "UseSsl": true,
  "UseDefaultSSLCertificate": false,
  "CertificateThumbPrint": "0123456789ABCDEF0123456789ABCDEF01234567",
  "Authentication": true,
  "AuthenticationUserName": "apiuser",
  "AuthenticationPassword": "securepassword",
  "UseSoap12": false,
  "ResponseMessageTemplate": "<Result><Accepted>true</Accepted></Result>",
  "ReturnCustomResponse": true,
  "Activities": []
}
```

## Useful public references

- [Integration Soup](https://www.integrationsoup.com/)
- [Workflow Designer Help](https://www.integrationsoup.com/InAppTutorials/WorkflowDesignerHelp.html)
- [Send HL7 To a Database With Activities](https://www.integrationsoup.com/hl7tutorialaddpatienttodatabasewithactivities.html)
