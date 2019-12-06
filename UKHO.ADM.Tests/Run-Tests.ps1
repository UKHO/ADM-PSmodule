param($ManifestFilePath)
Set-Location $PSScriptRoot

$mut = "UKHO.ADM"

$moduleRoot = "$PSScriptRoot\..\$mut"

# Install required modules
$ModuleLocation = (Split-Path $ManifestFilePath)
$ManifestFileName = (Split-Path $ManifestFilePath -Leaf)
Install-RequiredModules $ModuleLocation $ManifestFileName

Remove-Module $mut -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
Import-Module $moduleRoot -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

Get-ChildItem -Path $PSScriptRoot -Filter "*.Tests.ps1" -Recurse | ForEach-Object {
     . $_.FullName
 }