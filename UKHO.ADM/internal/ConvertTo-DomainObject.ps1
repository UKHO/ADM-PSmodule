<#
.SYNOPSIS
Validate the domain object from the configuration and turn it into a a strongly ADDomain object
#>
function ConvertTo-DomainObject {
    [CmdletBinding()]
    param(
        $DomainConfig
    )
    begin {}
    process {
        $validation = (Validate-Domain -DomainConfig $DomainConfig)

        if ($validation.IsValid()) {
            if ($DomainConfig.IsPrimary -eq $null) {
                $DomainConfig.IsPrimary = $false
            }
            Return [ADDomain]::new($DomainConfig.FQDN, $DomainConfig.DomainController, $DomainConfig.IsPrimary, $DomainConfig.DistinguishedName, $DomainConfig.Credential)
        }
        else {
            Write-ErrorsAndTerminate -ValidationContext $validation
        }
    }
    end {}
}