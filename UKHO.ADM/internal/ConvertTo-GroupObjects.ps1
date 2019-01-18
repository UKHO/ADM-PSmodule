function ConvertTo-GroupObjects {
    [CmdletBinding()]
    param(
        $Settings,
        $GroupConfig,
        [ADOrganisationalUnit] $OU
    )
    begin {}
    process {

        $validation = (Validate-Group -GroupConfig $GroupConfig)

        if ($validation.IsValid()) {
        
            [ADGroup[]]$groups = @()        
        
            if ($OU.Domain.IsPrimary) {

                $dlGroup = [ADGroup]::new($Settings.GroupPrefix, $Settings.Environment, $OU.Name, $GroupConfig.Name, "DL", $OU.DistinguishedName, $OU.Domain)
                $ggGroup = [ADGroup]::new($Settings.GroupPrefix, $Settings.Environment, $OU.Name, $GroupConfig.Name, "GG", $OU.DistinguishedName, $OU.Domain)
                $dlGroup.ADGroupMembers += $ggGroup

                # Adds groups that exist externally from configData
                Get-NonADMGeneratedGroup -OU $OU -GroupConfig $GroupConfig -ggGroup $ggGroup

                $groups += $dlGroup
                $groups += $ggGroup
            }
            else {
                $ugGroup = [ADGroup]::new($Settings.GroupPrefix, $Settings.Environment, $OU.Name, $GroupConfig.Name, "UG", $OU.DistinguishedName, $OU.Domain)
                $ggGroup = [ADGroup]::new($Settings.GroupPrefix, $Settings.Environment, $OU.Name, $GroupConfig.Name, "GG", $OU.DistinguishedName, $OU.Domain)
                $ugGroup.ADGroupMembers += $ggGroup

                # Adds groups that exist externally from configData
                Get-NonADMGeneratedGroup -OU $OU -GroupConfig $GroupConfig -ggGroup $ggGroup

                $groups += $ugGroup
                $groups += $ggGroup
            }

            #Add users
            if ($null -ne $GroupConfig.Users -and $GroupConfig.Users.Count -gt 0) { 
                $GroupConfig.Users | Where-Object {$_.Domain -eq $OU.Domain.FQDN} | ForEach-Object {
                    $ggGroup.UserAccountMembers += ConvertTo-UserObject -UserConfig $_ -Domain $OU.Domain
                }                
            }
                   

            [ADGroup[]]$groups
        }
        else {
            Write-ErrorsAndTerminate -ValidationContext $validation
        }
    }
    end {}
}