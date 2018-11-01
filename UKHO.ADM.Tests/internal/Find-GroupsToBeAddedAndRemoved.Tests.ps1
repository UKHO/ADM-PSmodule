InModuleScope $mut {
    Describe "Find-GroupsToBeAddedAndRemoved" {
        $pwd = ConvertTo-SecureString "123" -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ("username", $pwd)
        $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $false, "DC=subdomain,DC=fakedomain,DC=com",$cred)
        $subGroup = [ADGroup]::new("SC", "LIVE", "DevTeam", "SubGroup", "GG", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) # SC = SourceControl
        $subGroup2 = [ADGroup]::new("SC", "LIVE", "DevTeam", "SubGroup2", "GG", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
        $subGroup3 = [ADGroup]::new("SC", "LIVE", "DevTeam", "SubGroup3", "GG", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 

        Context "A group with one groupMember and who is not already in the group" {
            Mock Get-ADGroupMember {}
            Mock Get-Differences {}

            $group = [ADGroup]::new("SC", "LIVE", "DevTeam", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
            $group.ADGroupMembers += $subGroup

            Find-GroupsToBeAddedAndRemoved $group

            It "Calls Get-ADGroupMember" {
                Assert-MockCalled Get-ADGroupMember -Times 1
            }

            It "Correctly transforms the single ADGroupMember from the group parameter and uses it to call Get-Differences" {
                # We expect the key to be the "DistinguishedName"
                Assert-MockCalled Get-Differences -Times 1 -ParameterFilter {$setOne.Count -eq 1 -and 
                    $setOne.ContainsKey($subGroup.DistinguishedName) -and
                    $setTwo.Count -eq 0}
            }
        }

        Context "A group with no GroupMembers" {
            Mock Get-ADGroupMember {}
            Mock Get-Differences {}

            $group = [ADGroup]::new("SC", "LIVE", "DevTeam", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 

            Find-GroupsToBeAddedAndRemoved $group

            It "Call Get-ADGroupMember" {
                Assert-MockCalled Get-ADGroupMember -Times 1
            }
 
            It "Calls Get-Differences with empty hashmaps" {
                Assert-MockCalled Get-Differences -Times 1 -ParameterFilter {$setOne.Count -eq 0 -and 
                    $setTwo.Count -eq 0}
            }
        }

        Context "A group with one GroupMember who is already in that group" {
            $adGroup = @{
                DistinguishedName = $subGroup.DistinguishedName
                objectClass       = 'group'
            }
            Mock Get-ADGroupMember { return @($adGroup) }        
            Mock Get-Differences {}

            $group = [ADGroup]::new("SC", "LIVE", "DevTeam", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
            $group.ADGroupMembers += $subGroup

            Find-GroupsToBeAddedAndRemoved $group

            It "Calls Get-ADGroupMember" {
                Assert-MockCalled Get-ADGroupMember -Times 1
            }

            It "Correctly transforms both the ADGroupMember objects and the objects returned from Get-ADGroupMember" {
                # The should be a hashmap with the key being the SamAccountName
                Assert-MockCalled Get-Differences -Times 1 -ParameterFilter {$setOne.Count -eq 1 -and 
                    $setOne.ContainsKey($subGroup.DistinguishedName) -and
                    $setTwo.Count -eq 1 -and
                    $setTwo.ContainsKey($subGroup.DistinguishedName)}
            }
        }

        Context "A group with multiple GroupMembers who are not already in that group" {
            Mock Get-ADGroupMember {}
            Mock Get-Differences {}

            $group = [ADGroup]::new("SC", "LIVE", "DevTeam", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
            $group.ADGroupMembers += $subGroup
            $group.ADGroupMembers += $subGroup2
            $group.ADGroupMembers += $subGroup3

            Find-GroupsToBeAddedAndRemoved $group

            It "Call Get-ADGroupMember" {
                Assert-MockCalled Get-ADGroupMember -Times 1
            }
 
            It "Correctly transforms the multiple Groups from the group parameter and uses them to call Get-Differences" {
                Assert-MockCalled Get-Differences -Times 1 -ParameterFilter {$setOne.Count -eq 3 -and
                    $setOne.ContainsKey($subGroup.DistinguishedName) -and
                    $setOne.ContainsKey($subGroup2.DistinguishedName) -and
                    $setOne.ContainsKey($subGroup3.DistinguishedName) -and
                    $setTwo.Count -eq 0}
            }
        }

        Context "A group with no subGroups but multiple groups already exists in the group" {
            $adGroup = @{DistinguishedName = 'subGroup1'
                objectClass                = 'group'
            }
            $adGroup2 = @{DistinguishedName = 'subGroup2'
                objectClass                 = 'group'
            }
            $adGroup3 = @{DistinguishedName = 'subGroup3'
                objectClass                 = 'group'
            }
            Mock Get-ADGroupMember { return @($adGroup, $adGroup2, $adGroup3)} 
            Mock Get-Differences {}

            $group = [ADGroup]::new("SC", "LIVE", "DevTeam", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 

            Find-GroupsToBeAddedAndRemoved $group

            It "Calls Get-ADGroupMember" {
                Assert-MockCalled Get-ADGroupMember -Times 1
            }
            It "Correctly transforms the AD objects returned by Get-ADGroupMember and uses them to call Get-Differences" {
                Assert-MockCalled Get-Differences -Times 1 -ParameterFilter { $setTwo.Count -eq 3 -and
                    $setTwo.ContainsKey("subGroup1") -and
                    $setTwo.ContainsKey("subGroup2") -and
                    $setTwo.ContainsKey("subGroup3") -and
                    $setOne.Count -eq 0
                }
            }
        }

        Context "A group with one user and a groupMember" {
            $adUser = @{
                SamAccountName = "user1"
                objectClass    = 'user'
            }
            $groupDistinguishedName = 'AG_MADEUPGROUP'
            $adGroup = @{
                DistinguishedName = $groupDistinguishedName
                objectClass       = 'group'
            }
            Mock Get-ADGroupMember { return @($adUser, $adGroup) }        
            Mock Get-Differences {}

            $group = [ADGroup]::new("SC", "LIVE", "DevTeam", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
        
            Find-GroupsToBeAddedAndRemoved $group

            It "Calls Get-ADGroupMember" {
                Assert-MockCalled Get-ADGroupMember -Times 1
            }

            It "Filters group objects out" {
                Assert-MockCalled Get-Differences -Times 1 -ParameterFilter {
                    $setOne.Count -eq 0 -and
                    $setTwo.Count -eq 1 -and
                    $setTwo.ContainsKey($groupDistinguishedName) -and
                    $setTwo.ContainsKey($aduser.SamAccountName) -eq $false}
            }
        }    
    }
}