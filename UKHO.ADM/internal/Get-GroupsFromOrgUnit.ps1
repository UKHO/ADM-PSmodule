<#
.SYNOPSIS
Get-GroupsFromOrgUnit

.DESCRIPTION
Get-GroupsFromOrgUnit

.PARAMETER OrgUnit
The OrgUnit to review

.PARAMETER Type
The type/suffix of group you are after

.EXAMPLE
Get-GroupsFromSubOrgUnits -OrgUnits $ADObject.OrganisationalUnit -Type "DL"
#>
function Get-GroupsFromOrgUnit() {
    [CmdletBinding()]
    param(
        $OrgUnit,
        $Type
    )

    begin {
        $ret = @()
    }

    process {
        foreach ($group in $OrgUnit.Groups) {
            if ($group.Name -like "*-$Type") {
                $ret += $group
            }
        }    
        if($null -ne $OrgUnit.SubOrganisationalUnits) {
            foreach($subOU in $OrgUnit.SubOrganisationalUnits) {
                $ret += Get-GroupsFromOrgUnit -OrgUnit $subOU -Type $Type
            }
        }
    }
    
    end {
        $ret
    }

}