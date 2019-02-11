function Update-AD {
    [CmdletBinding()]
    param(
        $cd,
        [bool]$ApplyChanges = $false
    )
    begin {
        $systemColours = @{
            "info" = "White";
            "adding" = "Green";
            "remove" = "Red";
            "modify" = "Yellow";
            "error" = "Magenta";
            "header" = "Blue";
            "detail" = "Gray";
        }
    }
    process {
        Write-Colour -LinesBefore 1 "Actions are indicated with the following symbols:" -Color $systemColours.info
        Write-Colour -StartTab 1 "+", " adding or creating" -Color $systemColours.adding, $systemColours.info
        Write-Colour -StartTab 1 "-", " removing or deleting" -Color $systemColours.remove, $systemColours.info
        Write-Colour -StartTab 1 "~", " modification or change" -Color $systemColours.modify, $systemColours.info
        Write-Colour -StartTab 1 "x", " errors have occurred"  -Color $systemColours.error, $systemColours.info

        $out = Generate-ConfigurationObject -ConfigData $cd 

        Write-Colour -LinesBefore 1 "UKHO.ADM will perform the following changes:" -Color $systemColours.header

        $ADChanges = Get-ADChanges -ADDomains $out -SystemColours $systemColours

        Write-Colour -LinesBefore 1 "Change Summary:" -Color $systemColours.detail
        Write-Colour -StartTab 1 "Created OU: $($ADChanges.CreatedOUs)" -Color $systemColours.detail
        Write-Colour -StartTab 1 "Created Groups: $($ADChanges.CreatedGroups)" -Color $systemColours.detail
        Write-Colour -StartTab 1 "Added Groups: $($ADChanges.AddedGroups)" -Color $systemColours.detail
        Write-Colour -StartTab 1 "Removed Groups: $($ADChanges.RemovedGroups)" -Color $systemColours.detail
        Write-Colour -StartTab 1 "Removed Users: $($ADChanges.RemovedUsers)" -Color $systemColours.detail
        Write-Colour -StartTab 1 "Added Users: $($ADChanges.AddedUsers)" -Color $systemColours.detail

        if ($ApplyChanges) {

            Write-Colour -LinesBefore 4 "UKHO.ADM will now apply the changes" -Color $systemColours.header

            $ADChanges.ApplyChanges()        
        }
    }
    end {}
}