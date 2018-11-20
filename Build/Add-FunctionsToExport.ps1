param(
    [Parameter(Mandatory)]
    [String]
    $ManifestFilePath)

Write-Host "Manifest File Path is"
Write-Host $ManifestFilePath
Write-Host "Manifest File Path done"


Import-Module UKHO.BuildTools

Get-Module | Format-Table

$wip = $ManifestFilePath | Split-Path

    if(Test-Path("$wip\functions")){
        $FunctionToExport += Get-ChildItem "$wip\functions" | Select -expand BaseName
    }

    Write-Host "function to export is"
    Write-Host $FunctionToExport
    Write-Host "Function to export done"

Add-FunctionsToExport -ManifestFilePath $ManifestFilePath -FunctionsToExport $FunctionToExport