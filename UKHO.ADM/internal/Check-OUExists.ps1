function Check-OUExists {
    [CmdletBinding()]
    Param(
        [ADOrganisationalUnit]$ou
    )
    begin {
        $exists = $false
    }
    process {
        # Check that this OU exists
        try {
            Get-ADOrganizationalUnit -Identity $ou.DistinguishedName -Server $ou.Domain.DomainController | Out-Null
            $exists = $true
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            $exists = $false
        }
    }
    end {
        $exists
    }
}