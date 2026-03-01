# Prompt: CreateCodeTransformers (`AiFunctionType.CreateCodeTransformers`)

Generates C# code content for code-based transformer actions.

---

## Input intent

- explicit code requirement from instruction set
- optional imported code conversion context (for example Mirth)

---

## Output contract

- plain C# code content (no markdown wrappers)

---

## Supporting components

- [Code Prompts](../components/code-prompts.md)
- [Prompt Storage and Overrides](../components/prompt-storage-and-overrides.md)

---

## Usage note

The code output is typically wrapped into `CodeTransformerAction` by the calling flow.
