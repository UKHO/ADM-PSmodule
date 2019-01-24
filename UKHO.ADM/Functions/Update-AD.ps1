function Update-AD {
    [CmdletBinding()]
    param(
        $cd,
        [bool]$ApplyChanges = $false
    )
    begin {}
    process {
        $fg = "White"

        Write-Color "A change plan has been geneated and is show below.`n",
        "Actions are indicated with the following symbols:`n",
        "`t+"," adding or creating`n",
        "`t-"," removing or deleting`n",
        "`t~"," modification or change`n",
        "`tx", " errors have occurred`n" `
        -Color $fg, 
        $fg,
        Green,$fg,
        Red,$fg,
        Yellow,$fg,
        Magenta, $fg

        $out = Generate-ConfigurationObject -ConfigData $cd 

        Write-Color "UKHO.ADM will perform the following changes:" -Color Blue

        $ADChanges = Get-ADChanges($out)

        Write-Color "Plan:" -Color Gray

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