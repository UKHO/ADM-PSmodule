. $PSScriptRoot\LoadConfiguration.ps1 # loads in all the configuration into a variable called $configData

Remove-Module UKHO.ADM -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot"\UKHO.ADM" -WarningAction SilentlyContinue

Update-AD $configData $false
