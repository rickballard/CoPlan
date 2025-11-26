# CoPlan_Scan_Repos.ps1
# Role:
#   Walk a list of repos and emit a coarse "plan state" summary.
# Notes:
#   This is an MVP stub. It focuses on structure, not deep semantics.

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string[]] $RepoPaths,

    [string] $OutputPath = "./coplan_planstate_v0.1.json"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$items = @()

foreach ($repo in $RepoPaths) {
    if (-not (Test-Path -LiteralPath $repo)) {
        Write-Warning "Repo path not found: $repo"
        continue
    }

    $name = Split-Path $repo -Leaf

    $docs  = Get-ChildItem -LiteralPath $repo -Recurse -Include '*.md','*.rst' -ErrorAction SilentlyContinue
    $code  = Get-ChildItem -LiteralPath $repo -Recurse -Include '*.ps1','*.py','*.js','*.ts','*.cs','*.go' -ErrorAction SilentlyContinue

    $items += [pscustomobject]@{
        Name              = $name
        Path              = $repo
        DocFileCount      = $docs.Count
        CodeFileCount     = $code.Count
        ExampleDocSamples = $docs | Select-Object -First 3 -ExpandProperty FullName
    }
}

$result = [pscustomobject]@{
    Workspace = (Get-Location).Path
    Generated = (Get-Date).ToUniversalTime().ToString("o")
    Repos     = $items
}

$result | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath
Write-Host "CoPlan scan completed. Output written to $OutputPath"
