Set-Location $PSScriptRoot

$mut = "UKHO.ADM"

$moduleRoot = "$PSScriptRoot\..\$mut"

Remove-Module $mut -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
Import-Module $moduleRoot -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

Get-ChildItem -Path $PSScriptRoot -Filter "*.Tests.ps1" -Recurse | ForEach-Object {
     . $_.FullName
 }