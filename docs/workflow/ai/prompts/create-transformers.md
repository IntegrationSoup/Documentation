# Prompt: CreateTransformers (`AiFunctionType.CreateTransformers`)

Generates structured transformer action lists in JSON.

---

## Input intent

- transformer instruction text
- source/target activity IDs and message types
- path prompt guidance

---

## Output contract

- JSON list of transformer actions (typed objects)

---

## Supporting components

- [Transformer Prompts](../components/transformer-prompts.md)
- [Path Prompts](../components/path-prompts.md)
- [Code Prompts](../components/code-prompts.md) when code action content is required

---

## Usage note

This is action-object generation, not high-level instruction generation.  
Instruction generation is covered by `CreateSenderTransformerInstructions` and receiver-specific instruction prompts.
