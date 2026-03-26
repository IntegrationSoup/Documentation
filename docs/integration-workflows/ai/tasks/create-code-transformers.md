# Task: Create Code Transformations (`AiFunctionType.CreateCodeTransformers`)

Generates C# for code transformer actions.

---

## Use when

- transformer instructions explicitly require `Code`
- conversion from external script/code (for example Mirth JavaScript) is required

---

## Output contract

- plain C# code only
- no markdown wrappers
- compatible with Integration Soup code-context APIs

---

## Instruction input template (copy/paste)

```text
Create C# code for an Integration Soup CodeTransformerAction.

Context:
- Activity name:
- Message type:
- Required behavior:
- Available variables:
- Optional imported code block:

Constraints:
- output valid C#
- use CodeContext APIs (GetVariable, SetVariable, CurrentHL7, CurrentJson, etc.)
- no markdown

Return only code.
```

---

## Example 1 (new code generation)

## Input

```text
Set ${IsPediatric} true when PID-7 is less than 18 years from today.
```

## Output

```csharp
string dob = CurrentHL7.GetValueAtPath("PID-7.1");
DateTime parsed;
bool isPediatric = false;
if (DateTime.TryParseExact(dob, "yyyyMMdd", null, System.Globalization.DateTimeStyles.None, out parsed))
{
    int age = DateTime.Today.Year - parsed.Year;
    if (parsed > DateTime.Today.AddYears(-age)) age--;
    isPediatric = age < 18;
}
SetVariable("IsPediatric", isPediatric ? "true" : "false");
```

## Example 2 (conversion scenario)

## Input

```text
Convert imported code block that builds FullName from LastName and FirstName.
```

## Output

```csharp
string last = GetVariable("LastName");
string first = GetVariable("FirstName");
SetVariable("FullName", string.IsNullOrEmpty(last) ? first : last + ", " + first);
```

---

## Common failure modes

- returning explanations instead of code
- using APIs unavailable in workflow code context
- forgetting string/null handling for missing paths

---

## Related

- [Code Rules](../components/code-rules.md)
- [Create Transformer Actions](create-transformers.md)
