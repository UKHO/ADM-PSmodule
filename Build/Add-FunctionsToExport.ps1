param(
    $ManifestFilePath)

Import-Module UKHO.BuildTools

$wip = $ManifestFilePath | Split-Path

    if(Test-Path("$wip\functions")){
        $FunctionToExport += Get-ChildItem "$wip\functions" | Select-Object -expand BaseName
    }
    else {
        Write-Error "Functions folder not found at $wip\functions. Cannot export any functions" 
    }

Write-Host "Following functions will be exported: $FunctionToExport"

#Update-ModuleManifest -Path $ManifestFilePath -FunctionsToExport $FunctionToExport

Add-FunctionsToExport -ManifestFilePath $ManifestFilePath -FunctionsToExport $FunctionToExport