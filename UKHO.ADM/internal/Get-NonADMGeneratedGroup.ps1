function Get-NonADMGeneratedGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $OU,
        [Parameter(Mandatory)]
        $GroupConfig,
        [Parameter(Mandatory)]    
        $ggGroup
    )
    
    begin {
    }
    
    process {
        if ($null -ne $GroupConfig.Groups -and $GroupConfig.Groups.Count -gt 0) {
            $GroupConfig.Groups | ForEach-Object {
                if ($_.DistinguishedName -like "*$($OU.Domain.DistinguishedName)") {
                    $groupGroup = [ADGroup]::new($_.DistinguishedName, $OU.Domain)
                    if (Check-GroupExists $groupGroup) {
                        Write-Verbose "Adding Group $($groupGroup.DistinguishedName) TO GROUP $($ggGroup.DistinguishedName)"
                        $ggGroup.ADGroupMembers += $groupGroup
                    }
                    else {
                        Write-Error "Group $($groupGroup.DistinguishedName) Not found in $($OU.Domain.DistinguishedName)"
                    }
                }
            }
        }
    }
    
    end {
    }
}