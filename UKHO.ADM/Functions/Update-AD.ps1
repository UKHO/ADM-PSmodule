function Update-AD {
    [CmdletBinding()]
    param(
        $cd,
        [bool]$ApplyChanges = $false
    )
    begin {}
    process {
        Write-Color "Actions are indicated with the following symbols:`n" -Color White
        Write-Color "`t+", " adding or creating`n" -Color Green, White
        Write-Color "`t-", " removing or deleting`n" -Color Red, White
        Write-Color "`t~", " modification or change`n" -Color Yellow, White
        Write-Color "`tx", " errors have occurred`n"  -Color Magenta, White

        $out = Generate-ConfigurationObject -ConfigData $cd 

        Write-Color "UKHO.ADM will perform the following changes:" -Color Blue

        $ADChanges = Get-ADChanges($out)

        Write-Color "Change Summary:`n",
        "`tCreated OU: $($ADChanges.CreatedOUs)`n",
        "`tCreated Groups: $($ADChanges.CreatedGroups)`n",
        "`tAdded Groups: $($ADChanges.AddedGroups)`n",
        "`tRemoved Groups: $($ADChanges.RemovedGroups)`n",
        "`tRemoved Users: $($ADChanges.RemovedUsers)`n",
        "`tAdded Users: $($ADChanges.AddedUsers)" `
            -Color Gray

        if ($ApplyChanges) {

            Write-Host ""
            Write-Host ""
            Write-Host ""
            Write-Host ""

            Write-Color "UKHO.ADM will now apply the changes" -Color Blue

            $ADChanges.ApplyChanges()        
        }
    }
    end {}
}