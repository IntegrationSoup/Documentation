# GitHub Integration

## What this page covers

This page explains how to use GitHub around the workflow directory:

- storing workflow files in a GitHub repository
- seeing Integration Soup saves as normal git changes
- using GitHub Actions to deploy workflow files
- understanding where GitHub ends and target-side automation begins

---

## End-to-end model

```mermaid
flowchart LR
    A[Integration Soup saves workflow file] --> B[Git working tree shows file change]
    B --> C[Commit and push to GitHub]
    C --> D[GitHub repository]
    D --> E[GitHub Actions workflow]
    E --> F[Target host workflow directory]
    F --> G[Integration Soup imports the file]
```

---

## Recommended repository layouts

Two layouts work well.

### Layout A: repository working copy equals the workflow directory

Use this when:

- one host is the main authoring host
- operators are comfortable committing directly from that machine
- the repository contains mostly workflow files

Typical shape:

```text
C:\ProgramData\popokey\HL7SoupIntegrationServer\Workflows
  .git\
  4e29f49a-b0bf-4d8d-b29f-0d6d7f6f5e87.hl7Workflow
  6a1f6d54-8a3d-4f08-a2a3-e34c1b67d4cc.hl7Workflow
```

Benefits:

- Integration Soup saves become normal git file modifications
- deleting a workflow becomes a normal git deletion
- no extra copy step is required on the authoring host

Trade-offs:

- repository metadata lives in the workflow directory
- this pattern is most natural on the host that owns the working copy

### Layout B: repository contains a `workflows/` folder that is deployed into the workflow directory

Use this when:

- the repository also contains scripts, docs, CI/CD, or environment files
- you want a cleaner separation between repository root and deployed runtime folder
- you deploy to multiple hosts

Typical shape:

```text
repo-root/
  workflows/
    4e29f49a-b0bf-4d8d-b29f-0d6d7f6f5e87.hl7Workflow
    6a1f6d54-8a3d-4f08-a2a3-e34c1b67d4cc.hl7Workflow
  .github/
    workflows/
      deploy-workflows.yml
```

Benefits:

- cleaner repository structure
- easier to add CI/CD and deployment assets
- easier to package the same workflow set for multiple targets

Trade-offs:

- requires an explicit copy or deploy step into the host workflow directory

---

## Local authoring flow

When the workflow directory is a Git working copy, the normal operator flow is:

1. Edit or import a workflow in Integration Soup.
2. Integration Soup writes the current `.hl7Workflow` file to the workflow directory when workflow history and archive saving is enabled.
3. Git sees the change as a normal modified, added, or deleted file.
4. Review the change with normal git tooling.
5. Commit and push to GitHub.

This keeps source control outside the product while still making the workflow directory the source-controlled working set.

---

## Using GitHub Actions for deployment

GitHub Actions is useful when you want GitHub to coordinate deployment after a push.

Typical model:

- push workflow file changes to GitHub
- let a GitHub Actions workflow react to `push`
- optionally allow manual redeploy with `workflow_dispatch`
- run the deployment on a self-hosted runner that can reach the target host or target share

GitHub itself does not directly make private machines pull new files.

One of these still has to exist on the target side:

- a self-hosted runner on the target host
- a self-hosted runner on another machine that can copy to the target host
- another deployment agent or scheduled sync process

---

## Example GitHub Actions workflow

The example below assumes:

- the repository keeps workflow files in `workflows/`
- a Windows self-hosted runner can reach the target workflow directory
- the target host is already configured to import from its local workflow directory

```yaml
name: Deploy Integration Soup workflows

on:
  push:
    branches:
      - main
    paths:
      - "workflows/**"
      - ".github/workflows/deploy-workflows.yml"
  workflow_dispatch:

jobs:
  deploy:
    runs-on: [self-hosted, windows]

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Copy workflow files to the target workflow directory
        shell: powershell
        run: |
          $source = Join-Path $env:GITHUB_WORKSPACE "workflows"
          $target = "C:\ProgramData\popokey\HL7SoupIntegrationServer\Workflows"

          New-Item -ItemType Directory -Force -Path $target | Out-Null

          Get-ChildItem -Path $source -File |
            Where-Object { $_.Name -like "*.hl7Workflow" -or $_.Name -like "*.soupworkflow" } |
            ForEach-Object {
              Copy-Item -Path $_.FullName -Destination (Join-Path $target $_.Name) -Force
            }
```

How to adapt it:

- if the runner is installed directly on the Integration Soup host, keep a local path for `$target`
- if the runner is on another machine, change `$target` to a reachable deployment location such as a UNC path
- if the target host uses `On restart`, add the host restart or maintenance step outside this sample
- if the target host uses `Automatic`, the copied files can import while the host keeps running

---

## Manual and externally triggered deployment runs

GitHub Actions can be helpful even when deployment should not happen on every push.

Common options:

- use `workflow_dispatch` for a manual deploy button in GitHub
- use GitHub CLI or the GitHub REST API to trigger a manual deployment workflow
- use other GitHub dispatch mechanisms when an external system should ask GitHub to start a workflow

In all of these cases, GitHub is only triggering the workflow. A runner or other target-side automation still performs the real file copy.

---

## Practical recommendations

- Keep Integration Soup responsible only for local workflow load and save behavior.
- Keep commit, review, branch, and deployment policy in GitHub and external automation.
- Use a self-hosted runner when deployment needs access to private infrastructure.
- Prefer complete-file copy or stage-then-rename patterns if large files or network shares are involved.
- Decide separately whether deployment should also remove files that were deleted from the repository.

## Related pages

- [Workflow Directory and Source Control](workflow-directory.md)
- [Generic Git Patterns](generic-git.md)
- [Deployment Patterns](deployment-patterns.md)
