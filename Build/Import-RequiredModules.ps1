param($ManifestFilePath)

. $PSScriptRoot/Install-AcModule.ps1

$Location = $ManifestFilePath | Split-Path

$FileName = $ManifestFilePath | Split-Path -Leaf
    
[HashTable]$Manifest = Import-LocalizedData -BaseDirectory $Location -FileName $Filename

foreach ($module in $Manifest.RequiredModules) {
    Install-AcModule -ModuleName $module.ModuleName -ModuleVersion $module.ModuleVersion
}