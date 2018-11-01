function Get-ADChanges {
    [CmdletBinding()]
    param(
        [ADDomain[]] $ADDomains   
    )
    begin {
        $ADChanges = [ADChanges]::new()
    }
    process {
        $ADDomains | Sort-Object { $_.IsPrimary} -Descending | ForEach-Object {    
            ForEach ($OU in $_.OrganisationalUnits) {
                $ADChanges = Traverse-OU -ou $OU -ADChanges $ADChanges
            }
        }
    }
    end {
        $ADChanges
    }
}