function Update-AD {
    [CmdletBinding()]
    param(
        $cd,
        [bool]$ApplyChanges = $false
    )
    begin {}
    process {
        Write-Color "A change plan has been geneated and is show below.`n",
        "Actions are indicated with the following symbols:`n",
        "`t+"," adding or creating`n",
        "`t-"," removing or deleting`n",
        "`t~"," modification or change`n",
        "`tx", " errors have occurred`n" `
        -Color White, 
        White,
        Green,White,
        Red,White,
        Yellow,White,
        Magenta, White

        $out = Generate-ConfigurationObject -ConfigData $cd 

        Write-Color "UKHO.ADM will perform the following changes:" -Color Blue

        $ADChanges = Get-ADChanges($out)

        Write-Color "Plan:`n",
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

            Write-Color -Line "UKHO.ADM will now apply the changes" -Color Blue

            $ADChanges.ApplyChanges()        
        }
    }
    end {}
}