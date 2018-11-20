param($BuildNumber,$ManifestFilePath)

Import-Module UKHO.BuildTools

Get-Module | Format-Table

$wip = $ManifestFilePath | Split-Path

    if(Test-Path("$wip\functions")){
        $FunctionToExport += Get-ChildItem "$wip\functions" | Select -expand BaseName
    }

Add-FunctionsToExport -ManifestFilePath $ManifestFilePath -FunctionsToExport $FunctionToExport