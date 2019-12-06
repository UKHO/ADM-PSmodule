param($ManifestFilePath, $PreReleaseTag, $Branch)

Import-Module UKHO.BuildAndDeploy

# Install required modules
$ModuleLocation = (Split-Path $ManifestFilePath)
$ManifestFileName = (Split-Path $ManifestFilePath -Leaf)
Install-RequiredModules $ModuleLocation $ManifestFileName

# Update manifest to include all functions found within the `functions` folder
if(Test-Path("$ModuleLocation\functions")){
    $FunctionsToExport += Get-ChildItem "$ModuleLocation\functions" | Select -expand BaseName
}
Update-ModuleManifest -Path $ManifestFilePath -FunctionsToExport $FunctionsToExport

# Set module on as pre-release if not on master branch
Set-ModuleAsPreRelease -ManifestFilePath $ManifestFilePath -PreReleaseTag $PreReleaseTag -Branch $Branch