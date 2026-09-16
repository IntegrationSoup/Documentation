# Validate HL7 Transformer

The Validate HL7 Transformer Extension Library adds two validation activities to Integration Soup:

- **Validate HL7 Message** validates an HL7 message and returns an enriched JSON result.
- **Validate HL7 Message to HL7 ACK** validates an HL7 message and returns a complete HL7 acknowledgement.

Both activities run a saved HL7 Soup validation profile. They report red invalid highlighters as errors. Other highlighter colours, including orange warnings, are not returned by this Extension Library.

## Download and prerequisites

- [IntegrationSoup.ValidateHl7Transformer.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.ValidateHl7Transformer.msi)
- [Website tutorial page](https://www.integrationsoup.com/ExtensionLibraries/ValidateHl7Transformer.html)
- Integration Soup installed on the machine that runs the workflow
- A saved `.HL7SoupValidators` profile deployed to the Integration Soup machine. HL7 Soup is needed to create or edit profiles, but it does not have to be installed on the production server.
- An incoming HL7 message. A typed HL7 activity message is preferred; HL7-formatted generic text can also be parsed by the activity.

The Extension Library is loaded directly into the Integration Host process. It does not use a persistent out-of-process runner, and it does not require a change to the Integration Host executable.

## Common setup

1. Install the MSI on the Integration Soup machine.
2. The installer restarts a detected Integration Host service so it can load the upgraded DLL. Reopen the Workflow Designer if the activities are not listed yet.
3. Add one of the validation activities after the receiver or earlier activity that supplies the HL7 message.
4. In the activity message template, use **Insert Activity Message** to preserve the message's HL7 type. If a bound message arrives as generic text, the activity reparses its HL7-formatted content; an empty activity input uses the workflow's received HL7 message.
5. Enter the exact validation profile name in the **Profile** parameter.
6. Leave **Error if invalid** cleared to return validation findings as data while the workflow continues normally, or select it when an invalid result should mark the current workflow message as errored and take the receiver's error-response path. The checkbox description is **Mark Workflow Error on Invalid**.

The complete message still needs to contain interpretable HL7 content, including an MSH segment.

## Validation profile changes

The Extension Library checks the saved profile file whenever it validates a message. Edits saved in HL7 Soup are loaded by the next validation. The Integration Soup service and the workflow do not need to restart for profile changes.

Automatic profile refresh requires read and write/create permission in:

```text
C:\ProgramData\Popokey\SharedSettings\Validators
```

The Extension Library uses a content hash and a short-lived profile snapshot to bypass the Integration Host's in-memory profile cache, then removes that snapshot after it has loaded. Give the service account delete permission for automatic snapshot cleanup. If snapshot creation is unavailable, validation falls back to the host's normal profile loading, but a changed profile may remain cached until the service restarts. Snapshot deletion is best effort; without delete permission, temporary aliases can accumulate.

## Validate HL7 Message: JSON response

**Validate HL7 Message** returns a version-independent JSON result. It retains the original HL7 Soup path and also separates the path into fields that are convenient to bind in a workflow.

```json
{
  "Profile": "ADT A01 Validation",
  "HasErrors": true,
  "AcknowledgmentCode": "AE",
  "Errors": [
    {
      "Path": "MSH-15",
      "ErrorSegment": "MSH",
      "ErrorSegmentOccurrence": 1,
      "ErrorField": 15,
      "ErrorFieldRepetition": null,
      "ErrorComponent": null,
      "ErrorSubcomponent": null,
      "Reason": "is not in message",
      "Severity": "E",
      "Hl7ErrorCode": "101",
      "Hl7ErrorText": "Required field missing",
      "Hl7ErrorCodingSystem": "HL70357",
      "ApplicationErrorCode": "PROFILE_REQUIRED",
      "ApplicationErrorText": "Required by validation profile",
      "ApplicationErrorCodingSystem": "L"
    }
  ]
}
```

`HasErrors` is `true` when the result contains one or more errors. `AcknowledgmentCode` is `AA` when there are no errors and `AE` when errors are present. These fields always describe the validation outcome and do not depend on the **Error if invalid** checkbox. A successful result has an empty `Errors` array.

For a path such as `OBX[2]-5[3].2.1`, the structured values are segment `OBX`, segment occurrence `2`, field `5`, field repetition `3`, component `2` and subcomponent `1`.

The standard HL7 error-code mapping is:

- `101` for a required field missing
- `102` for invalid formatting, dates, lengths, case and general profile-rule failures
- `103` for a value outside a table or permitted list
- `200` for an unsupported value at `MSH-9.1`
- `201` for an unsupported value at `MSH-9.2`
- `202` for an unsupported processing ID at `MSH-11`
- `203` for an unsupported version ID at `MSH-12`

## Validate HL7 Message to HL7 ACK: HL7 response

**Validate HL7 Message to HL7 ACK** returns an HL7 acknowledgement that can be bound directly as a TCP receiver's custom response when its response timing is **After All Processing**.

For a v2.5.1 message with a missing `MSH-15`, the response is shaped like this:

```text
MSH|^~\&|ReceivingApp|ReceivingFacility|SendingApp|SendingFacility|20260720120000+1000||ACK^A01^ACK|MSG0001|P|2.5.1
MSA|AE|MSG0001|MSH-15: is not in message
ERR||MSH^1^15|101^Required field missing^HL70357|E|PROFILE_REQUIRED^Required by validation profile^L||Validation profile: ADT A01 Validation; Path: MSH-15; is not in message|MSH-15: is not in message
```

The acknowledgement follows Integration Soup's automatic ACK header behaviour:

- Copy the incoming MSH and preserve its separators, timestamp, message control ID, processing ID, version and later fields.
- Swap `MSH-3` with `MSH-5` and `MSH-4` with `MSH-6`.
- Change `MSH-9.1` to `ACK` while preserving the trigger event in `MSH-9.2`.
- For HL7 v2.5 and later, set `MSH-9.3` to `ACK`, adding that component when the incoming `MSH-9` contains only two components.
- Copy the incoming `MSH-10` into `MSA-2`.
- Return `MSA-1` as `AA` when validation passes or `AE` when it fails.

The activity preserves the incoming HL7 version and chooses the ERR representation from `MSH-12.1`:

- HL7 v2.1 through v2.3 use one legacy `ERR` segment with repeating `ERR-1` values containing the segment, occurrence, field and standard error code.
- HL7 v2.3.1 and v2.4 use the richer legacy repeating `ERR-1` field. It also carries a local application code and shortened path text. Component and subcomponent locations, severity and separate diagnostic fields do not exist in this legacy structure.
- HL7 v2.5 and later use one `ERR` segment per error. The activity populates `ERR-2`–`ERR-5` and `ERR-7`–`ERR-8`; `ERR-6` is left empty.
- A missing or unrecognised `MSH-12.1` uses the detailed legacy `ERR-1` form.

A v2.4 error is therefore shaped like this:

```text
ERR|MSH^1^15^101&Required field missing&HL70357&PROFILE_REQUIRED&MSH-15: is not in&L
```

Multiple v2.4 errors are repetitions of `ERR-1`, separated by `~`, in one `ERR` segment.

## Workflow control and TCP responses

A validation finding is part of the activity result, rather than an execution failure. When the profile runs and the JSON or ACK is produced, the validation activity has completed successfully even when the result contains `HasErrors=true` or `MSA-1=AE`. Its activity row therefore records successful completion, while the result and its error details remain available in the activity response and logs.

Both activities provide an optional **Error if invalid** checkbox, with the description **Mark Workflow Error on Invalid**. It is cleared by default:

- **Cleared:** validation findings are returned as data and the workflow continues normally. Automatic TCP response handling therefore follows its normal success path, usually returning an application accept. Bind `HasErrors`, `AcknowledgmentCode` or `MSA-1` in later workflow logic. To return the validation ACK instead, choose **Return Response From Activity** or bind the ACK activity result into a **Custom Response**.
- **Selected:** an invalid result still populates the activity's JSON or ACK response, and also marks the current workflow message as errored with the first validation path and reason. With response timing set to **After All Processing**, automatic TCP handling returns an error response. **Validate HL7 Message to HL7 ACK** also makes its detailed `AE`/`ERR` ACK the workflow response; the JSON activity leaves the receiver to generate its normal workflow-error response.

Selecting the checkbox marks the workflow message as errored without interrupting downstream workflow activities, so the TCP listener remains available for the next message. Configuration and execution failures still throw, including a blank or missing profile, a missing profile file, input that cannot be interpreted as HL7, profile-access failures that the host cannot fall back from, or a missing MSH when creating an ACK.

For explicit workflow logic, leave **Error if invalid** cleared and bind the activity result into later workflow conditions or transformers. A workflow can return the bound ACK as its custom TCP response, route or quarantine the message, or use its own conditional code transformer to throw an exception when the bound result indicates an invalid message. A deliberate transformer exception uses the workflow's normal exception-response handling, so configure and test that response path separately.

## Working with older HL7 versions

The JSON activity is the simplest way to obtain severity, component-level location and application-code detail independently of the sender's HL7 version.

If a workflow specifically needs modern ERR bindings, validate twice: validate the untouched original-version message to produce the external ACK, and validate a copied message whose version is changed to HL7 v2.5 or v2.5.1 for internal modern ERR processing. Changing only the generated modern ACK's version back does not convert its ERR structure and would produce an invalid older-version ACK.

## Typical uses

- Rejecting or quarantining invalid messages before transformation or delivery
- Returning a detailed custom ACK to an HL7 TCP sender
- Logging validation failures for troubleshooting or reporting
- Routing messages according to `HasErrors`, `AcknowledgmentCode`, error paths or codes
