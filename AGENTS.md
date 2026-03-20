# Documentation Repository Guidance

## Scope
- This repo publishes `https://integrationsoup.github.io/Documentation/` using MkDocs.
- Documentation content lives under:
  - `C:\Users\jason\source\repos\Documentation\docs`

## Extension Library Documentation
- Use the user-facing term `Extension Library`.
- Extension library docs should live under a dedicated workflow section, preferably:
  - `docs/workflow/extension-libraries/`
- When documenting an extension library, include:
  - what it does
  - prerequisites
  - installer name and download URL
  - whether it uses a persistent out-of-process runner
  - any host/service account considerations

## Coordination
- Website/tutorial pages belong in:
  - `C:\Users\jason\source\repos\HL7SoupWebsite\HL7SoupWebsite`
- Extension implementation lives in:
  - `C:\Users\jason\source\repos\CustomActivities`

## Navigation
- If a new extension library section or page is added, make sure the MkDocs navigation picks it up cleanly.
- This repo uses `awesome-pages`, so section structure and `index.md` files matter.
