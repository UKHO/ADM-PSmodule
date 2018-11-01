
if(Get-Module -ListAvailable ActiveDirectory)
{
    Write-Information "Powershell Module ActiveDirectory Exists"
}
else {
    Write-Error "Powershell Module ActiveDirectory needs installing"
}

. $PSScriptRoot\Objects\Objects.ps1

$items = Get-ChildItem $PSScriptRoot\functions\*
foreach ($item in $items) {
    Import-Module $item.FullName
}
$items = Get-ChildItem $PSScriptRoot\internal\*

foreach ($item in $items) {
    Import-Module $item.FullName
}
