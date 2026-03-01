# Prompt: CreateRecieverVariableInstructions (`AiFunctionType.CreateRecieverVariableInstructions`)

Expands receiver variable-transform instruction text into explicit variable-setting steps.

---

## Input intent

- high-level variable requirements for receiver phase
- optional inbound message template and type hints

---

## Output contract

- instruction text for `AiReceiverActivity.VariableTransformers[i].Instruction`

---

## Core expectation

- variable creation only
- no mapping to outbound message in this stage
- explicit `${VariableName} from SourcePath` style instructions

---

## Usage note

This is an instruction-authoring step before transformer action object generation.
