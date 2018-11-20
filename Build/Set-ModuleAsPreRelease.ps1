<#
.SYNOPSIS

Determines if a module should be marked as PreRelease based on the value of $branch

.DESCRIPTION

Set-ModuleAsPreRelease determines if a module should be marked as PreRelease. This is determined by doing a case insensitive comparison of $branch to $ReleaseBranch (which defaults to master)

.EXAMPLE

Example of usage from TFS

Set-ModuleAsPreRelease.ps1 -PreReleaseTag "dev$(Build.BuildId)" -ManifestFilePath "$(Build.SourcesDirectory)\$(ModuleName)\$(ModuleName).psd1" -Branch $(Build.SourceBranchName)

.PARAMETER ManifestFilePath

string path to the modules psd1 to be marked as PreRelease

.PARAMETER PreReleaseTag

string to be added to end of module name marking it as PreRelease. - is added automatically. Example PreReleaseTag dev$(Build.BuildId)

.PARAMETER Branch

name of branch being built. When called from TFS, the value passed in will probably be $(Build.SourceBranchName)

.PARAMETER ReleaseBranch

name of branch module is released from, PreRelease does not need to be set when building from this branch. Default value is master
#>

param(
    [Parameter(Mandatory)]
    [String]
    $PreReleaseTag,    

    [Parameter(Mandatory)]
    [String]
    $ManifestFilePath, 
    
    [Parameter(Mandatory)]
    [String]
    $Branch,
    
    [String]
    $ReleaseBranch = "Master")

if($Branch -eq $ReleaseBranch){    
    Write-Host "Branch $Branch for build is the same as the ReleaseBranch $ReleaseBranch. Module NOT marked as PreRelease"
}
else{    
    Update-ModuleManifest -Path $ManifestFilePath -PreRelease $PreReleaseTag.Trim("-") -Verbose
    Write-Host "Branch $Branch for build is different to ReleaseBranch $ReleaseBranch. Module marked as PreRelease"
}