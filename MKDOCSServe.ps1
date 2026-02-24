Set-Location "C:\Users\jason\source\repos\Documentation"

$venvActivate = ".\.venv\Scripts\Activate.ps1"
if (Test-Path $venvActivate) {
    . $venvActivate
} else {
    Write-Host "Virtual env not found at .\.venv. Create it first:"
    Write-Host "  python -m venv .venv"
    exit 1
}

mkdocs serve