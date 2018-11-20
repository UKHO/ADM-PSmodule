param(
    [Parameter(Mandatory)]
    [String]
    $ManifestFilePath)

Import-Module UKHO.BuildTools

Get-Module | Format-Table

$wip = $ManifestFilePath | Split-Path

    if(Test-Path("$wip\functions")){
        $FunctionToExport += Get-ChildItem "$wip\functions" | Select -expand BaseName
    }

Write-Host $FunctionToExport

Add-FunctionsToExport -ManifestFilePath $ManifestFilePath -FunctionsToExport $FunctionToExport