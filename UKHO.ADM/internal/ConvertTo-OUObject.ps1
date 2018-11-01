function ConvertTo-OUObject {
    [CmdletBinding()]
    param(
        $Settings,
        $OUConfig,
        $CurrentADPath,
        [ADDomain]$Domain
    )
    begin {        
    }

    process {
        $validation = (Validate-OU -OUConfig $OUConfig)

        if ($validation.IsValid()) {
            $ou = [ADOrganisationalUnit]::new($OUConfig.Name, $CurrentADPath, $Domain)
        }
        else {
            Write-ErrorsAndTerminate -ValidationContext $validation
        }
    
        if ($OUConfig.Groups -ne $null -and $OUConfig.Groups.Count -gt 0) {
            $groups = @()
            $OUConfig.Groups | ForEach-Object {
                $groups += ConvertTo-GroupObjects -Settings $Settings  -GroupConfig $_ -OU $ou
            }
            $ou.Groups = [ADGroup[]]$groups
        }
        
        if ($OUConfig.SubOUs -ne $null -and $OUConfig.SubOUs.Count -gt 0) {
            $OUConfig.SubOUs | ForEach-Object {
                $ou.SubOrganisationalUnits += ConvertTo-OUObject -Settings $Settings -OUConfig $_ -CurrentADPath $ou.DistinguishedName -Domain $Domain
            }
        }
    }
    end {
        [ADOrganisationalUnit]$ou
    }
}