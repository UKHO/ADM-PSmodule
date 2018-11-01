function Update-AD {
    [CmdletBinding()]
    param(
        $cd,
        [bool]$ApplyChanges = $false
    )
    begin {}
    process {

        $out = Generate-ConfigurationObject -ConfigData $cd 

        Write-Host "Changes To Be Applied" -ForegroundColor "Blue"

        $ADChanges = Get-ADChanges($out)

        if ($ApplyChanges) {

            Write-Host ""
            Write-Host ""
            Write-Host ""
            Write-Host ""

            Write-Host "Applying changes" -ForegroundColor "Blue"

            $ADChanges.ApplyChanges()        
        }
    }
    end {}
}