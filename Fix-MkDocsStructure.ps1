# Fix-MkDocsStructure.ps1
# Run from PowerShell. Adjust $RepoRoot if needed.

$ErrorActionPreference = "Stop"

$RepoRoot = "C:\Users\jason\source\repos\Documentation"

# Paths
$DocsRoot      = Join-Path $RepoRoot "docs"
$WorkflowSrc   = Join-Path $RepoRoot "Workflow"
$WorkflowDest  = Join-Path $DocsRoot "workflow"

# Ensure docs root exists
New-Item -ItemType Directory -Force -Path $DocsRoot | Out-Null
New-Item -ItemType Directory -Force -Path $WorkflowDest | Out-Null

# Helper to move folders if they exist
function Move-FolderIfExists {
    param(
        [Parameter(Mandatory=$true)][string]$Source,
        [Parameter(Mandatory=$true)][string]$Destination
    )

    if (Test-Path $Source) {
        New-Item -ItemType Directory -Force -Path (Split-Path $Destination -Parent) | Out-Null

        if (Test-Path $Destination) {
            # Destination exists; merge contents
            Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
                $target = Join-Path $Destination $_.Name
                if (Test-Path $target) {
                    # If item already exists, skip to avoid overwriting
                    Write-Host "Skipping existing: $target"
                } else {
                    Move-Item -LiteralPath $_.FullName -Destination $Destination
                }
            }
            # Remove source if now empty
            if (-not (Get-ChildItem -LiteralPath $Source -Force -ErrorAction SilentlyContinue)) {
                Remove-Item -LiteralPath $Source -Force -Recurse
            }
        } else {
            Move-Item -LiteralPath $Source -Destination $Destination
        }
    }
}

# Move your current structure under docs/workflow (if present)
Move-FolderIfExists -Source (Join-Path $WorkflowSrc "Examples")          -Destination (Join-Path $WorkflowDest "examples")
Move-FolderIfExists -Source (Join-Path $WorkflowSrc "ReceiverActivities") -Destination (Join-Path $WorkflowDest "receiver-activities")
Move-FolderIfExists -Source (Join-Path $WorkflowSrc "SenderActivities")   -Destination (Join-Path $WorkflowDest "sender-activities")

# If Workflow folder is now empty, remove it
if (Test-Path $WorkflowSrc) {
    $items = Get-ChildItem -LiteralPath $WorkflowSrc -Force -ErrorAction SilentlyContinue
    if (-not $items) {
        Remove-Item -LiteralPath $WorkflowSrc -Force -Recurse
    }
}

# Ensure section folders exist (even if they were empty)
New-Item -ItemType Directory -Force -Path (Join-Path $WorkflowDest "examples") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $WorkflowDest "receiver-activities") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $WorkflowDest "sender-activities") | Out-Null

# Create starter markdown files if missing
function Ensure-File {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Content
    )
    if (-not (Test-Path $Path)) {
        $dir = Split-Path $Path -Parent
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
    }
}

Ensure-File -Path (Join-Path $DocsRoot "index.md") -Content @"
# Integration Soup Documentation

Welcome. Use the navigation to browse workflow activities, API, and examples.
"@

Ensure-File -Path (Join-Path $WorkflowDest "index.md") -Content @"
# Workflow

This section covers how to build workflows in Integration Soup Integration Host.
"@

Ensure-File -Path (Join-Path $WorkflowDest "receiver-activities\index.md") -Content @"
# Receiver Activities

Receiver activities accept inbound data (e.g., TCP/MLLP HL7, files, etc.).
"@

Ensure-File -Path (Join-Path $WorkflowDest "sender-activities\index.md") -Content @"
# Sender Activities

Sender activities send outbound data (e.g., TCP/MLLP HL7, database, files, etc.).
"@

Ensure-File -Path (Join-Path $WorkflowDest "examples\index.md") -Content @"
# Examples

End-to-end workflow examples, including message templates and mappings.
"@

# Create mkdocs.yml if missing
$MkdocsYml = Join-Path $RepoRoot "mkdocs.yml"
if (-not (Test-Path $MkdocsYml)) {
    Set-Content -LiteralPath $MkdocsYml -Encoding UTF8 -Value @"
site_name: Integration Soup Docs
site_description: Documentation for Integration Soup / Integration Host
# repo_url: https://github.com/<ORG>/<REPO>
# edit_uri: edit/main/docs/

theme:
  name: material
  features:
    - navigation.sections
    - navigation.instant
    - navigation.top
    - search.suggest
    - search.highlight
    - content.action.edit

markdown_extensions:
  - admonition
  - pymdownx.details
  - pymdownx.superfences
  - pymdownx.highlight

nav:
  - Home: index.md
  - Workflow:
      - Overview: workflow/index.md
      - Receiver Activities: workflow/receiver-activities/index.md
      - Sender Activities: workflow/sender-activities/index.md
      - Examples: workflow/examples/index.md
"@
}

# Optional: GitHub Pages deploy workflow (only create if missing)
$WorkflowDir = Join-Path $RepoRoot ".github\workflows"
$DeployYml   = Join-Path $WorkflowDir "deploy-mkdocs.yml"

if (-not (Test-Path $DeployYml)) {
    New-Item -ItemType Directory -Force -Path $WorkflowDir | Out-Null
    Set-Content -LiteralPath $DeployYml -Encoding UTF8 -Value @'
name: Deploy MkDocs to GitHub Pages

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.x"

      - name: Install dependencies
        run: |
          pip install mkdocs mkdocs-material

      - name: Build site
        run: mkdocs build

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: site

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
'@
}

Write-Host ""
Write-Host "Done."
Write-Host "Next steps:"
Write-Host "1) (Optional) Edit mkdocs.yml and set repo_url/edit_uri."
Write-Host "2) Install locally: pip install mkdocs mkdocs-material"
Write-Host "3) Preview: mkdocs serve"
Write-Host "4) Commit + push."