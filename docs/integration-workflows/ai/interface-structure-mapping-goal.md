# AI Interface Structure Mapping Goal

Status: goal document  
Last reviewed: 2026-06-11

This document describes the goal for an AI-assisted service that suggests mappings between two Integration Soup interface structures.

The intent is to make interface creation faster by using AI to understand the full context of both structures, while keeping cost, privacy risk, and abuse risk low.

---

## Goal

Create a secure, low-cost service that takes two `InterfaceStructure` objects and returns useful mapping suggestions between them.

The service should help users quickly connect source fields to target fields in Interface Designer and Create Interface. It should use AI where context and judgement help, and deterministic logic where exact or obvious matches are available.

The feature should feel like a smart assistant inside the app, not an automatic black box. Users should be able to review, accept, reject, and adjust suggested mappings before they become part of the interface.

---

## Desired user experience

A user has a source interface structure and a target interface structure. They ask the application to suggest mappings.

The application returns a list of suggested mappings such as:

- accepted suggestions that look safe and obvious
- review suggestions that are plausible but need human confirmation
- unmapped target fields where no confident source field was found

The user can inspect the suggestions, make edits, and apply the approved mappings.

The user should not need to understand which suggestions came from AI versus deterministic matching. The application may show confidence and reasons where helpful, but the focus should be on making mapping review quick and clear.

---

## Why full structures should be sent to AI

The AI should receive the full source and target structures, not just fields that were missed by deterministic matching.

Field names often only make sense in context. For example, a target field named `Middle` may be hard to map by itself, but clear when it appears under `Patient.Name` beside `Given` and `Family`.

Sending the full structures allows the AI to use:

- parent and child field context
- nearby sibling fields
- message type
- common naming patterns
- repeated group structure
- field purpose implied by location
- deterministic candidate matches as hints

Cost is expected to be acceptable because this feature runs during design-time mapping, not runtime message processing.

---

## Core principles

### Quality over minimal prompt size

The service should optimize for useful mapping suggestions. It is acceptable to send the full structures if that improves correctness and reduces user cleanup.

### AI as an assistant, not an authority

AI output should be treated as suggestions. The application should validate returned paths and allow users to review mappings before applying them.

### Deterministic logic as support

Existing mapping logic should not replace the AI call. It should provide:

- candidate matches
- confidence signals
- fallback suggestions
- validation support

### Low cost by design

The system should use inexpensive AI models by default, request structured JSON, cache repeated requests, and enforce per-install quotas.

### Private by default

The service should send structure metadata, not runtime message data. Sample messages, patient data, order values, and other sensitive payloads should not be sent unless explicitly reviewed and approved later.

### Only available to Integration Soup apps

The service should not be a public unauthenticated endpoint. Deployed apps should authenticate with either per-install signed requests or Azure identity.

---

## In scope

- Mapping from one interface structure to another.
- Support for structures created or used by Interface Designer and Create Interface.
- Full-structure AI context.
- Deterministic candidate generation.
- Deterministic fallback when AI is unavailable.
- Per-install security controls.
- Azure-hosted identity where available.
- Response validation before mappings are shown or applied.
- Output that can be converted into existing mapping transformer actions.

---

## Out of scope

- Runtime message transformation.
- Automatic deployment of mappings without user review.
- Sending sample message data to AI by default.
- Training a custom model in the first version.
- Building a public API for third-party callers.
- Replacing existing workflow transformer behavior.

---

## Security goals

The service should support two trusted caller models.

### Per-install signed requests

For customer, on-prem, and non-Azure deployments, each installation should have its own identity and shared secret. The application backend signs requests before calling the mapping service.

The browser or Blazor client should not contain the signing secret.

The service should reject requests that have invalid signatures, unknown installation IDs, expired timestamps, replayed nonces, disabled installations, or exceeded quotas.

### Azure identity

For Integration Soup apps hosted in Azure, the service should support Microsoft Entra or managed identity authentication. This avoids shared secrets where the deployment environment can support Azure identity cleanly.

### Abuse protection

The service should include limits that prevent accidental or malicious cost spikes:

- per-install quotas
- request size limits
- field count limits
- timeout limits
- AI token limits
- kill switch per installation
- global AI-provider kill switch

---

## Privacy goals

The service should avoid sending sensitive data to AI providers.

Safe default input:

- field names
- paths
- message type
- structural hierarchy
- known common-field labels
- deterministic candidate matches

Input that should be avoided by default:

- sample message content
- runtime message values
- patient identifiers
- order identifiers
- free-text comments that may contain protected health information
- logs containing full prompt or response payloads

If comments or examples become useful later, they should go through a separate privacy review.

---

## Cost goals

The feature should be cheap enough to use casually during interface design.

Cost should be controlled by:

- using a small/cheap model by default
- sending structured prompts
- requesting structured JSON output
- caching by source and target structure hash
- retrying with a stronger model only when validation fails or confidence is poor
- enforcing per-install quotas
- tracking token usage

Because this feature is not expected to run often, quality and context should be prioritized over aggressive prompt trimming.

---

## Reliability goals

The user should still get useful suggestions when AI cannot be reached.

Fallback behavior should activate when:

- AI is disabled
- AI quota is exceeded
- the AI provider times out
- the AI provider is unavailable
- the AI response fails schema validation
- returned paths fail validation

Fallback results should come from deterministic matching and should be clearly safe to show as suggestions.

---

## Mapping result goals

Returned mappings should include enough information for the UI to explain and apply them safely.

Each suggested mapping should include:

- source path
- target path
- source and target path types
- confidence
- decision, such as accept or review
- reason
- validation status

The response should also identify target fields that could not be mapped confidently.

The output should be compatible with existing workflow mapping concepts, especially mapping transformer actions.

---

## Success criteria

The feature is successful when:

- users can generate useful first-pass mappings from Interface Designer or Create Interface
- full-structure context improves mappings for ambiguous field names
- users can review and apply suggestions quickly
- invalid paths are not returned as accepted mappings
- AI outages degrade into deterministic fallback behavior
- unauthorized clients cannot call the service
- per-install quotas prevent abuse
- no runtime message data is sent to AI by default
- cost remains low for normal design-time use

---

## Preferred direction

The preferred direction is an Azure Function called by Integration Soup application backends.

The Function should authenticate callers, enforce quotas, prepare full-structure AI context, add deterministic candidate hints, call a low-cost AI model, validate the structured response, and return mapping suggestions.

For non-Azure deployments, use per-install signed requests. For Azure-hosted deployments, use Microsoft Entra or managed identity where practical.

Deterministic matching should remain available as fallback and as evidence for the AI, but the AI should usually receive the complete source and target structures.

---

## Open questions

- Which `InterfaceStructure` fields are always safe to send?
- Should free-text comments be stripped by default?
- What confidence level should be required for an auto-accepted suggestion?
- Should users be able to choose a cheap mode versus a higher-quality mode?
- Where should per-install secrets and quotas be managed?
- Should mapping suggestions be saved for audit or learning?
- How should repeated groups and one-to-many mappings appear in the UI?

---

## Reference notes

- Azure Functions Consumption pricing includes a monthly free grant, which makes it a good fit for low-volume design-time calls. Recheck pricing before implementation: <https://azure.microsoft.com/en-us/pricing/details/functions/>
- Azure Functions HTTP triggers support function access levels, but function keys are not a per-install product identity model: <https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-http-webhook-trigger>
- App Service Authentication can be configured with Microsoft Entra for App Service and Azure Functions: <https://learn.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad>
- Azure OpenAI documents that customer data, prompts, and completions are not used to train models without permission or instruction: <https://learn.microsoft.com/en-us/azure/foundry/responsible-ai/openai/data-privacy>
- OpenAI Structured Outputs can force responses to follow a supplied JSON schema: <https://developers.openai.com/api/docs/guides/structured-outputs>
- OpenAI API pricing and model costs should be checked at implementation time: <https://developers.openai.com/api/docs/pricing>
- OpenAI data controls document API data handling and training defaults: <https://developers.openai.com/api/docs/guides/your-data>
