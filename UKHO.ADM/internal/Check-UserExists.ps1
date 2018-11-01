# Check if an AD User exists
function Check-UserExists {
    [CmdletBinding()]
    param(
        [ADUserAccount]$user
    )
    begin {}
    process {
        try {
            Get-ADUser -Identity $user.SamAccountName -Server $user.Domain.DomainController | Out-Null

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