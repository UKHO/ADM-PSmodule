function Get-ADChanges {
    [CmdletBinding()]
    param(
        [ADDomain[]] $ADDomains
    )
    begin {
        $ADChanges = [ADChanges]::new()
    }
    process {
        Write-Colour -LinesBefore 1 "UKHO.ADM will perform the following changes:" -Color $ADChanges.SystemColours.process

        $ADDomains | Sort-Object { $_.IsPrimary} -Descending | ForEach-Object {    
            ForEach ($OU in $_.OrganisationalUnits) {
                $ADChanges = Traverse-OU -ou $OU -ADChanges $ADChanges
            }
        }
    }
    end {
        Write-Colour -LinesBefore 1 "Change Summary:" -Color $ADChanges.SystemColours.detail
        Write-Colour -StartTab 1 "Created OU: $($ADChanges.CreatedOUs)" -Color $ADChanges.SystemColours.detail
        Write-Colour -StartTab 1 "Created Groups: $($ADChanges.CreatedGroups)" -Color $ADChanges.SystemColours.detail
        Write-Colour -StartTab 1 "Added Groups: $($ADChanges.AddedGroups)" -Color $ADChanges.SystemColours.detail
        Write-Colour -StartTab 1 "Removed Groups: $($ADChanges.RemovedGroups)" -Color $ADChanges.SystemColours.detail
        Write-Colour -StartTab 1 "Removed Users: $($ADChanges.RemovedUsers)" -Color $ADChanges.SystemColours.detail
        Write-Colour -StartTab 1 "Added Users: $($ADChanges.AddedUsers)" -Color $ADChanges.SystemColours.detail

        $ADChanges
    }
}