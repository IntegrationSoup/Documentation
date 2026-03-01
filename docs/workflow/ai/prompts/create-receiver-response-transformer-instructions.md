# Prompt: CreateRecieverResponseTransfomerInstructions (`AiFunctionType.CreateRecieverResponseTransfomerInstructions`)

Expands receiver response-transform instruction text for final response construction.

---

## Input intent

- response requirements
- returned message template intent
- full workflow context for response-stage mapping decisions

---

## Output contract

- instruction text for `AiReceiverActivity.ReturnedMessageTransformers[i].Instruction`

---

## Core expectation

- detailed response mapping logic
- preserve message templates exactly
- align response behavior with receiver protocol expectations (default vs custom)
