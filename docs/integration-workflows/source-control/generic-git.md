# Generic Git Patterns

## What this page covers

This page describes git-based patterns that work the same way across:

- GitHub
- GitLab
- Azure DevOps Repos
- Bitbucket
- self-hosted git servers
- local-only git repositories

The concepts also apply to other source-control systems that can keep a local folder in sync with a controlled version history, but the examples here assume git.

---

## The core rule

Treat the Integration Soup workflow directory as the runtime folder of current workflow files.

Source control can either:

- be the working copy in that folder
- or publish files into that folder from somewhere else

Integration Soup never needs to know which git platform you use. It only sees files arriving in or being written to the local workflow directory.

---

## Common patterns

| Pattern | How it works | Best when | Trade-offs |
|---|---|---|---|
| Direct working copy | The git working copy is the workflow directory | Single host, manual ops, straightforward source control | `.git` metadata lives in the workflow folder |
| Repository plus sync step | The repo lives elsewhere and a script copies workflow files into the workflow directory | Repositories that contain docs, scripts, CI/CD, or multiple assets | Requires a separate deploy or sync step |
| Central repo plus deployment pipeline | A central repo publishes workflow files to one or more hosts | Multiple environments, multiple hosts, controlled rollout | More moving parts and stronger operational discipline required |

---

## Pattern 1: direct checkout into the workflow directory

This is the simplest pattern.

Operationally:

- clone the repository directly into the workflow directory
- let Integration Soup save workflow files into that working copy
- use normal git status, commit, push, pull, and branch operations outside the product

Benefits:

- very little glue code
- easy to reason about
- good fit for a primary authoring host

Watch-outs:

- host-specific files should not be mixed into the same repository unless that is intentional
- if several people or processes edit the same host directly, git conflict handling remains an external operational concern

---

## Pattern 2: repository elsewhere plus sync into the workflow directory

This pattern separates repository structure from runtime structure.

Operationally:

- keep workflow files in a repository folder such as `workflows/`
- use a script, pipeline, or deployment tool to copy them into the workflow directory
- let Integration Soup import from the workflow directory according to its configured import mode

Benefits:

- repository can hold related assets without placing them in the runtime folder
- easier to package and deploy the same workflow set to multiple hosts

This is often the best pattern for shared repositories or controlled release processes.

---

## Pattern 3: central repository plus coordinated deployment

This is the most scalable pattern.

Operationally:

- one central repository stores the approved workflow files
- review and approval happen in source control
- a deployment step publishes the approved workflow set to one or more target hosts

Use this when:

- several hosts must stay aligned
- environments such as test, staging, and production exist
- workflow rollout should be coordinated instead of copied manually

This is the pattern most teams eventually move to.

---

## How this maps to other git platforms

The platform changes, but the operational model stays the same.

Examples:

- GitLab:
  repository plus GitLab CI job or runner copies workflow files to the host
- Azure DevOps:
  Azure Repos plus pipeline agent copies workflow files to the host
- Bitbucket:
  repository plus pipeline or external runner copies workflow files to the host
- self-hosted git:
  repository plus scheduled pull, webhook listener, or deployment script copies workflow files to the host

The important design question is not the git brand. It is:

- where the authoritative workflow files live
- how they reach the host workflow directory
- whether the host imports them automatically or on restart

---

## Practical recommendations

- Start with direct working copy when simplicity matters most.
- Move to repository-plus-sync when the repo needs to hold more than just workflow files.
- Move to coordinated deployment when several hosts or environments must stay consistent.
- Keep deletion behavior explicit.
- Keep deployment logic outside Integration Soup.

## Related pages

- [Workflow Directory and Source Control](workflow-directory.md)
- [GitHub Integration](github.md)
- [Deployment Patterns](deployment-patterns.md)
