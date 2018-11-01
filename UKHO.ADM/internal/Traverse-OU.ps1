# Traverse an OU and iterates over all groups inside that OU and all subOUs within that OU
function Traverse-OU {
    [CmdletBinding()]
    param(
        [ADOrganisationalUnit]$ou,
        [ADChanges]$ADChanges
    )
    begin {}
    process {
        if ((Check-OUExists $ou) -eq $false) {
            $ADChanges.CreateO($ou)
        }

        Foreach ($group in $ou.Groups) {
            $ADChanges = Traverse-Group -group $group -ADChanges $ADChanges        
        }   
    
        foreach ($subOU in $ou.SubOrganisationalUnits) {
            $ADChanges = Traverse-OU -ou $subOU -ADChanges $ADChanges
        }
    }
    end {
        $ADChanges
    }
}

