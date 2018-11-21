param(
    $ManifestFilePath)

Import-Module UKHO.BuildTools

Get-Module | Format-Table

$wip = $ManifestFilePath | Split-Path

    if(Test-Path("$wip\functions")){
        $FunctionToExport += Get-ChildItem "$wip\functions" | Select -expand BaseName
    }

Write-Host "Following functions will be exported: $FunctionToExport"

Add-FunctionsToExport -ManifestFilePath $ManifestFilePath -FunctionsToExport $FunctionToExport