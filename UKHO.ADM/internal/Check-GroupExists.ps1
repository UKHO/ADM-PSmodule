# Check if an AD Group exists
function Check-GroupExists {
    [CmdletBinding()]
    param(
        [ADGroup]$group
    )
    begin {}
    process {
        try {
            Get-ADGroup -Identity $group.DistinguishedName -Server $group.Domain.DomainController | Out-Null
            $exists = $true
        }
        catch  [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            $exists = $false
        }
    }

    end {
        $exists
    }
}