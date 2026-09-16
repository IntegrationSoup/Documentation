# HL7 Value Transformers

The HL7 Value Transformers Extension Library adds custom transformers that convert plain text into HL7-ready values.

Use it when a workflow value needs to be cleaned or shaped before it is inserted into an HL7 field.

Each transformer has a `Value` parameter for the source text and an `Output Variable` parameter for the converted result. If `Output Variable` is left blank, the transformer uses its default variable name, such as `XPN`, `XCN`, `XAD`, or `XTN`.

Default output variables are `Digits` for Digits only, `LettersAndDigits` for Letters and digits only, `LettersDigitsSpaces` for Letters, digits and spaces only, `XPN` for Text to HL7 person name, `XCN` for Text to HL7 clinician name, `XAD` for Text to HL7 address, and `XTN` for Text to HL7 phone.

## Download

- [IntegrationSoup.HL7ValueTransformers.msi](https://www.integrationsoup.com/downloads/CustomActivities/IntegrationSoup.HL7ValueTransformers.msi)
- [Website tutorial page](https://www.integrationsoup.com/ExtensionLibraries/HL7ValueTransformers.html)

## Included transformers

- **Digits only** removes everything except numeric digits.
- **Letters and digits only** removes spaces and punctuation, then uppercases letters.
- **Letters, digits and spaces only** removes punctuation, collapses repeated spaces, and uppercases letters.
- **Text to HL7 person name (XPN)** converts display names such as `Example Patient` into `Patient^Example`.
- **Text to HL7 clinician name (XCN)** converts clinician/provider names into person identifier, family, given, and middle-name components.
- **Text to HL7 address (XAD)** converts address lines into street, other designation, city, state, and postcode components.
- **Text to HL7 phone (XTN)** cleans phone values, normalizes common international prefixes, and places detected extensions into XTN component 8.

## Using it in a workflow

1. Install the MSI on the machine hosting Integration Soup.
2. Restart the Integration Soup service if needed.
3. Add one of the HL7 Value Transformers to the transformer chain for the source value.
4. Set the transformer's required `Value` parameter to the source text you want to convert. This can be a mapped field, variable, data-table value, or typed text.
5. Set `Output Variable` if you want a custom workflow variable name. If it is left blank, the transformer writes to its default variable, such as `XPN`, `XCN`, `XAD`, or `XTN`.
6. Insert or map that workflow variable into the target HL7 field or component.

Each transformer converts the single value supplied in the `Value` parameter and stores the converted text in a workflow variable. It does not replace the current message text.

The name transformers split names automatically when `Name Order` is blank. Two name words are treated as `given family`, and three or more name words are treated as `given middle family`. If the input contains a comma, the text before the comma is treated as family name and the text after it is split into given and middle names.

The name transformers also expose optional parameters. `Name Order` accepts compact values such as `FML`, `FL`, `LFM`, and `LF`, or words such as `First Middle Last`. Use `/` between alternatives. The XCN transformer also has `Person Identifier` for XCN component 1.

## Examples

`(021) 555-0100` with **Digits only** becomes:

```text
0215550100
```

`Dr Example Doctor` with **Text to HL7 person name (XPN)** becomes:

```text
Doctor^Example^^^Dr
```

`Donald X Duck` with **Text to HL7 person name (XPN)** becomes:

```text
Duck^Donald^X
```

`CORLEY BRIAN THOMAS` with **Text to HL7 person name (XPN)** and `Name Order` set to `LFM` becomes:

```text
CORLEY^BRIAN^THOMAS
```

`Christina Smith (A1234)` with **Text to HL7 clinician name (XCN)** becomes:

```text
A1234^Smith^Christina
```

`1 Example Street` plus `Wollongong NSW 2500` with **Text to HL7 address (XAD)** becomes:

```text
1 Example Street^^Wollongong^NSW^2500
```

`09 555 0100 ext 123` with **Text to HL7 phone (XTN)** becomes:

```text
095550100^^^^^^^123
```

## Runtime notes

This extension library runs directly as transformer code loaded from Integration Soup's `Custom Libraries` folder.

The name and address transformers escape HL7 separators in component values. Backslash, pipe, caret, ampersand, and tilde are converted to HL7 escape sequences, and line breaks inside component values become spaces.
