<#
.SYNOPSIS
Validate our configuration and then turn it into a a strongly ADDomain object

#>
function Generate-ConfigurationObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $ConfigData
    )
    begin {
        [ADDomain[]]$ret = @()
    }
    process {
        #Create all the domains
        $ConfigData.Domains | ForEach-Object {
            $ret += ConvertTo-DomainObject -DomainConfig $_          
        }

        $ret | Sort-Object { $_.IsPrimary } -Descending | ForEach-Object {
            $domain = $_
            $ConfigData.OUStructure | ForEach-Object {
                $ou = ConvertTo-OUObject -Settings $ConfigData.Settings -OUConfig $_ -CurrentADPath ("{0},{1}" -f $_.RootOU, $domain.DistinguishedName) -Domain $domain
                $domain.OrganisationalUnits += $ou    
            }
        }

        #Get DLs from the primary
        $DLArray = @();
        foreach ($dom in $ret | Where {$_.IsPrimary}) {
            $pou = $dom.OrganisationalUnits
            $DLarray += Get-GroupsFromOrgUnit -OrgUnit $pou -Type "DL"
        }

        # Get UGs
        $UGArray = @();
        foreach ($dom in $ret | Where {-Not $_.IsPrimary}) {
            $ou = $dom.OrganisationalUnits
            $UGarray += Get-GroupsFromOrgUnit -OrgUnit $ou -Type "UG"    
        }
    
        #Smoosh them together
        foreach ($ug in $UGArray) {
            Write-Information $ug.Name
            # based on Name pattern
            $firstBitOfUgName = $ug.Name.Substring(0,$ug.Name.LastIndexOf("-"))
            foreach ($dl in $DLArray) {
                $firstBitOfDlName = $dl.Name.Substring(0,$dl.Name.LastIndexOf("-"))
                if ($firstBitOfUgName -eq $firstBitOfDlName) {
                    $dl.ADGroupMembers += $ug
                }
            }
        }
    }
    end {
        $ret
    }
}


