[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$ArchivePath)
$ErrorActionPreference = 'Stop'
$expected = '6801F93E533846CEA05F4F531874A0E84371AB2331C5585B57CD7E3B869CF96B'
if (-not (Test-Path -LiteralPath $ArchivePath -PathType Leaf)) { throw 'Official NapCat.Shell.zip not found.' }
if ((Get-FileHash -LiteralPath $ArchivePath -Algorithm SHA256).Hash -ne $expected) { throw 'Archive SHA256 differs from verified v4.18.41 baseline. Nothing installed.' }
$destination = Join-Path $PSScriptRoot 'runtime\shell'
if (Test-Path -LiteralPath $destination) { throw 'runtime/shell already exists. Preserve its config; choose another checkout for a fresh install.' }
New-Item -ItemType Directory -Path (Join-Path $PSScriptRoot 'runtime') -Force | Out-Null
Expand-Archive -LiteralPath $ArchivePath -DestinationPath $destination
foreach ($name in 'NapCatWinBootMain.exe','NapCatWinBootHook.dll','qqnt.json','loadNapCat.js','napcat.mjs') {
    if (-not (Test-Path -LiteralPath (Join-Path $destination $name) -PathType Leaf)) { throw "Unexpected archive layout: missing $name. Check extracted runtime before continuing." }
}
$configPath = Join-Path $PSScriptRoot 'config.local.json'
if (-not (Test-Path -LiteralPath $configPath)) { Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'config.example.json') -Destination $configPath }
Write-Output 'Official runtime extracted. Edit config.local.json, then double-click Start.cmd.'
