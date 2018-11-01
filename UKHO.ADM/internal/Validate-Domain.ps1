function Validate-Domain {
    [CmdletBinding()]
    param (
        $DomainConfig
    )
    begin {
        [ValidationContext]$ret = [ValidationContext]::new()
    }
    process {
        if ($DomainConfig -eq $null) {
            $ret.ValidationResults += [ValidationResult]::new("domainConfig", "The domainConfigObject passed in was null. You must pass an non-null object.")      
        }
        else {
            if ([string]::IsNullOrEmpty($DomainConfig.FQDN)) {
                $ret.ValidationResults += [ValidationResult]::new("FQDN", "The FQDN is not set for the domain {0}. It must have a value." -f $DomainConfig.Name)
            }
            if ([string]::IsNullOrEmpty($DomainConfig.DomainController)) {
                $ret.ValidationResults += [ValidationResult]::new("DomainController", "The DomainController is not set for the domain {0}. It must have a value." -f $DomainConfig.Name)
            }
            if ([string]::IsNullOrEmpty($DomainConfig.DistinguishedName)) {
                $ret.ValidationResults += [ValidationResult]::new("DistinguishedName", "The DistinguishedName is not set for the domain {0}. It must have a value." -f $DomainConfig.Name)
            }
            if ($DomainConfig.Credential -eq $null) {
                $ret.ValidationResults += [ValidationResult]::new("Credential", "The Credential is not set for the domain {0}. It must have a value." -f $DomainConfig.Name)
            }
        }
    }
    end {
        $ret
    }
}