param($RepositoryName, $RepositorySourceUri, $RepositoryPublishUri, $NugetAPIKey, $ModuleFolderPath)

Register-Repository $RepositoryName $RepositorySourceUri $RepositoryPublishUri

Publish-ModuleToFeed $NugetAPIKey $RepositoryName $ModuleFolderPath

UnRegister-Repository $RepositoryName