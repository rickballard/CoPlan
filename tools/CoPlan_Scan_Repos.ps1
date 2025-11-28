# CoPlan_Scan_Repos.ps1
# Role:
#   Walk a list of repos and emit a coarse "plan state" summary.
# Notes:
#   MVP stub: focuses on structure and doc/code density, not deep semantics.

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

    $docs = Get-ChildItem -LiteralPath $repo -Recurse -Include '*.md','*.rst' -ErrorAction SilentlyContinue
    $code = Get-ChildItem -LiteralPath $repo -Recurse -Include '*.ps1','*.py','*.js','*.ts','*.cs','*.go' -ErrorAction SilentlyContinue

    $docList  = @()
    if ($docs) { $docList  = @($docs) }

    $codeList = @()
    if ($code) { $codeList = @($code) }

    $sampleDocs = @()
    if ($docList.Count -gt 0) {
        $sampleDocs = $docList | Select-Object -First 3 -ExpandProperty FullName
    }

    $items += [pscustomobject]@{
        Name              = $name
        Path              = $repo
        DocFileCount      = $docList.Count
        CodeFileCount     = $codeList.Count
        ExampleDocSamples = $sampleDocs
    }
}

$result = [pscustomobject]@{
    Workspace = (Get-Location).Path
    Generated = (Get-Date).ToUniversalTime().ToString("o")
    Repos     = $items
}

$result | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath
Write-Host "CoPlan scan completed. Output written to $OutputPath"
