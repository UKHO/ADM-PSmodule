param($Location, $Filename)

Import-Module UKHO.BuildTools -WarningAction silentlyContinue

Install-RequiredModules $Location $Filename

if(Get-Module -ListAvailable ActiveDirectory)
{
    Write-Information "Module ActiveDirectory Exists"
}
else {
    Write-Error "Module ActiveDirectory needs installing"
}