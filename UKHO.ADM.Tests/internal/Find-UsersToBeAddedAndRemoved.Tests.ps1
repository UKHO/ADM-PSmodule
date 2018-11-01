InModuleScope $mut {
    Describe "Find-UsersToBeAddedAndRemoved" {
        $pwd = ConvertTo-SecureString "123" -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ("username", $pwd)
        $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $false, "DC=subdomain,DC=fakedomain,DC=com",$cred)
        $user = [ADUserAccount]::new("user1", $domain)
        $user2 = [ADUserAccount]::new("user2", $domain)
        $user3 = [ADUserAccount]::new("user3", $domain)

        Context "A group with one user and who are not already in the group" {
            Mock Get-ADGroupMember {}
            Mock Get-Differences {}

            $group = [ADGroup]::new("SC", "LIVE", "DevTeam", "Readers", "DL", "OU=SC,OU=UKHO,OU=DevTeam,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
            $group.UserAccountMembers += $user

            Find-UsersToBeAddedAndRemoved $group

            It "Calls Get-ADGroupMember" {
                Assert-MockCalled Get-ADGroupMember -Times 1
            }

            It "Correctly transforms the single user from the group parameter and uses it to call Get-Differences" {
                # We expect the key to be "SamAccountName"
                Assert-MockCalled Get-Differences -Times 1 -ParameterFilter {$setOne.Count -eq 1 -and 
                    $setOne.ContainsKey($user.SamAccountName) -and
                    $setTwo.Count -eq 0}
            }
        }

        Context "A group with no users" {
            Mock Get-ADGroupMember {}
            Mock Get-Differences {}

            $group = [ADGroup]::new("SC", "LIVE", "DevTeam", "Readers", "DL", "OU=SC,OU=UKHO,OU=DevTeam,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 

            Find-UsersToBeAddedAndRemoved $group

            It "Call Get-ADGroupMember" {
                Assert-MockCalled Get-ADGroupMember -Times 1
            }
 
            It "Calls Get-Differences with empty hashmaps" {
                Assert-MockCalled Get-Differences -Times 1 -ParameterFilter {$setOne.Count -eq 0 -and 
                    $setTwo.Count -eq 0}
            }
        }

        Context "A group with one user who is already in that group" {
            $adUser = @{SamAccountName = 'user1'
                objectClass            = 'user'
            }
            Mock Get-ADGroupMember { return @($adUser) }        
            Mock Get-Differences {}

            $group = [ADGroup]::new("SC", "LIVE", "DevTeam", "Readers", "DL", "OU=SC,OU=UKHO,OU=DevTeam,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
            $group.UserAccountMembers += $user

            Find-UsersToBeAddedAndRemoved $group

            It "Calls Get-ADGroupMember" {
                Assert-MockCalled Get-ADGroupMember -Times 1
            }

            It "Correctly transforms both the user objects and the objects returned from Get-ADGroupMember" {
                # The should be a hashmap with the key being the SamAccountName
                Assert-MockCalled Get-Differences -Times 1 -ParameterFilter {$setOne.Count -eq 1 -and 
                    $setOne.ContainsKey($user.SamAccountName) -and
                    $setTwo.Count -eq 1 -and
                    $setTwo.ContainsKey($user.SamAccountName)}
            }
        }

        Context "A group with multiple users who are not already in that group" {
            Mock Get-ADGroupMember {}
            Mock Get-Differences {}

            $group = [ADGroup]::new("SC", "LIVE", "DevTeam", "Readers", "DL", "OU=SC,OU=UKHO,OU=DevTeam,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
            $group.UserAccountMembers += $user
            $group.UserAccountMembers += $user2
            $group.UserAccountMembers += $user3

            Find-UsersToBeAddedAndRemoved $group

            It "Call Get-ADGroupMember" {
                Assert-MockCalled Get-ADGroupMember -Times 1
            }
 
            It "Correctly transforms the multiple users from the group parameter and uses them to call Get-Differences" {
                Assert-MockCalled Get-Differences -Times 1 -ParameterFilter {$setOne.Count -eq 3 -and
                    $setOne.ContainsKey($user.SamAccountName) -and
                    $setOne.ContainsKey($user2.SamAccountName) -and
                    $setOne.ContainsKey($user3.SamAccountName) -and
                    $setTwo.Count -eq 0}
            }
        }

        Context "A group with no users but multiple users already exists in the group" {
            $adUser = @{SamAccountName = '1user'
                objectClass            = 'user'
            }
            $adUser2 = @{SamAccountName = '2user'
                objectClass             = 'user'
            }
            $adUser3 = @{SamAccountName = '3user'
                objectClass             = 'user'
            }
            Mock Get-ADGroupMember { return @($adUser, $adUser2, $adUser3)} 
            Mock Get-Differences {}

            $group = [ADGroup]::new("SC", "LIVE", "DevTeam", "Readers", "DL", "OU=SC,OU=UKHO,OU=DevTeam,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 

            Find-UsersToBeAddedAndRemoved $group
            It "Calls Get-ADGroupMember" {
                Assert-MockCalled Get-ADGroupMember -Times 1
            }
            It "Correctly transforms the AD objects returned by Get-ADGroupMember and uses them to call Get-Differences" {
                Assert-MockCalled Get-Differences -Times 1 -ParameterFilter { $setTwo.Count -eq 3 -and
                    $setTwo.ContainsKey("1user") -and
                    $setTwo.ContainsKey("2user") -and
                    $setTwo.ContainsKey("3user") -and
                    $setOne.Count -eq 0
                }
            }
        }

        Context "A group with one user and a groupMember" {
            $adUser = @{
                SamAccountName = $user.SamAccountName
                objectClass    = 'user'
            }
            $groupSamAccountName = 'AG_MADEUPGROUP'
            $adGroup = @{
                SamAccountName = $groupSamAccountName
                objectClass    = 'group'
            }
            Mock Get-ADGroupMember { return @($adUser, $adGroup) }        
            Mock Get-Differences {}

            $group = [ADGroup]::new("SC", "LIVE", "DevTeam", "Readers", "DL", "OU=SC,OU=UKHO,OU=DevTeam,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
        
            Find-UsersToBeAddedAndRemoved $group

            It "Calls Get-ADGroupMember" {
                Assert-MockCalled Get-ADGroupMember -Times 1
            }

            It "Filters group objects out" {
                Assert-MockCalled Get-Differences -Times 1 -ParameterFilter {
                    $setOne.Count -eq 0 -and
                    $setTwo.Count -eq 1 -and
                    $setTwo.ContainsKey($user.SamAccountName) -and
                    $setTwo.ContainsKey($groupSamAccountName) -eq $false}
            }
        }    
    }
}