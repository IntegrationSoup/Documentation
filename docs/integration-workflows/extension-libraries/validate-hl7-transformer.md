# Validate HL7 Transformer

The Validate HL7 Transformer Extension Library adds the **Validate HL7 Message** activity to Integration Soup.

Use it to check HL7 messages against your validation profiles before the workflow continues.

## Download

- [IntegrationSoup.ValidateHl7Transformer.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.ValidateHl7Transformer.msi)
- [Website tutorial page](https://www.integrationsoup.com/ExtensionLibraries/ValidateHl7Transformer.html)

## Using it in a workflow

1. Install the MSI on the machine hosting Integration Soup.
2. Restart the Integration Soup service if needed.
3. Add **Validate HL7 Message** after the receiver or earlier step that supplies the HL7 message.
4. In the activity message template, use **Insert Activity Message** so the HL7 message from the earlier step flows into the validator.
5. Enter the name of the validation profile you want to apply.

## Parameters

### Profile

Enter the exact name of the HL7 Soup validation set you want this activity to run.

## Activity message

The incoming message must be an **HL7** message in the HL7 message template, not plain text.

The simplest way to do that is to insert the message directly from an earlier HL7 receiver or HL7 activity.

If the content has already been flattened into plain text before it reaches this activity, the validator cannot treat it as an HL7 message.

## Response message

The response message is **JSON** describing the validation outcome for the selected profile.

You can use that JSON in later workflow steps for:

- logging
- branching
- alerting

## Typical uses

- Rejecting or quarantining invalid messages before transformation or delivery
- Logging validation failures for troubleshooting or reporting
- Using validation results to drive workflow decisions automatically
