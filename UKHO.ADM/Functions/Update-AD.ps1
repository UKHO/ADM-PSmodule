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

        if ($ApplyChanges) {

            $ADChanges.ApplyChanges()        
        }
    }
    end {}
}