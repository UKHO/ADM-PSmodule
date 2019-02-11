function Get-ADChanges {
    [CmdletBinding()]
    param(
        [ADDomain[]] $ADDomains,
        [HashTable]$SystemColours
    )
    begin {
        $ADChanges = [ADChanges]::new()
        $ADChanges.SystemColours = $SystemColours
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