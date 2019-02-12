function Update-AD {
    [CmdletBinding()]
    param(
        $cd,
        [bool]$ApplyChanges = $false
    )
    begin {
    }
    process {
        $out = Generate-ConfigurationObject -ConfigData $cd 

        $ADChanges = Get-ADChanges -ADDomains $out

        Write-Colour -LinesBefore 1 "Actions are indicated with the following symbols:" -Color $ADChanges.SystemColours.info
        Write-Colour -StartTab 1 "+", " adding or creating" -Color $ADChanges.SystemColours.adding, $ADChanges.SystemColours.info
        Write-Colour -StartTab 1 "-", " removing or deleting" -Color $ADChanges.SystemColours.remove, $ADChanges.SystemColours.info
        Write-Colour -StartTab 1 "~", " modification or change" -Color $ADChanges.SystemColours.modify, $ADChanges.SystemColours.info
        Write-Colour -StartTab 1 "x", " errors have occurred"  -Color $ADChanges.SystemColours.error, $ADChanges.SystemColours.info
        Write-Colour -LinesBefore 1 "UKHO.ADM will perform the following changes:" -Color $ADChanges.SystemColours.header

        Write-Colour -LinesBefore 1 "Change Summary:" -Color $ADChanges.SystemColours.detail
        Write-Colour -StartTab 1 "Created OU: $($ADChanges.CreatedOUs)" -Color $ADChanges.SystemColours.detail
        Write-Colour -StartTab 1 "Created Groups: $($ADChanges.CreatedGroups)" -Color $ADChanges.SystemColours.detail
        Write-Colour -StartTab 1 "Added Groups: $($ADChanges.AddedGroups)" -Color $ADChanges.SystemColours.detail
        Write-Colour -StartTab 1 "Removed Groups: $($ADChanges.RemovedGroups)" -Color $ADChanges.SystemColours.detail
        Write-Colour -StartTab 1 "Removed Users: $($ADChanges.RemovedUsers)" -Color $ADChanges.SystemColours.detail
        Write-Colour -StartTab 1 "Added Users: $($ADChanges.AddedUsers)" -Color $ADChanges.SystemColours.detail

        if ($ApplyChanges) {

            Write-Colour -LinesBefore 4 "UKHO.ADM will now apply the changes" -Color $ADChanges.SystemColours.header

            $ADChanges.ApplyChanges()        
        }
    }
    end {}
}