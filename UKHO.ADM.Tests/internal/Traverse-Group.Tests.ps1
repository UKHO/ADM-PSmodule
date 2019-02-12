InModuleScope $mut {
    Describe "Traverse-Group" {
        $pwd = ConvertTo-SecureString "123" -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ("username", $pwd)
        Context "When a group which exists and has no sub groups or members is passed in" {

            Mock Check-GroupExists {return $true}
            Mock Find-UsersToBeAddedAndRemoved {return @(@(), @())}
            Mock Find-GroupsToBeAddedAndRemoved {return @(@(), @())}
            $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $false, "DC=subdomain,DC=fakedomain,DC=com", $cred)
            $group = [ADGroup]::new("DevTeam", "LIVE", "SC", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
            $ADChanges = [ADChanges]::new()

            Traverse-Group $group $ADChanges

            It "Checks the group exists" {
                Assert-MockCalled Check-GroupExists -Times 1
            }
            It "Calls Find-UsersToBeAddedAndDeleted" {
                Assert-MockCalled Find-UsersToBeAddedAndRemoved -Times 1
            }
            It "Calls Find-GroupsToBeAddedAndRemoved" {
                Assert-MockCalled Find-GroupsToBeAddedAndRemoved -Times 1
            }
            It "Has not altered any fields on ADChanges" {
                $ADChanges.RemoveUserFromGroup.Count | Should Be 0
                $ADChanges.AddUserToGroup.Count | Should Be 0
                $ADChanges.CreateGroup.Count | Should Be 0
                $ADChanges.CreateOU.Count | Should Be 0
                $ADChanges.RemoveGroupMemberFromGroup.Count | Should Be 0            
            }
        }

        Context "When a group which exists with no sub groups and two users who has not been added to the group" {

            $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $false, "DC=subdomain,DC=fakedomain,DC=com", $cred)
            $user = [ADUserAccount]::new("user1", $domain)
            $user2 = [ADUserAccount]::new("user2", $domain)
            Mock Check-GroupExists {return $true}
            Mock Find-UsersToBeAddedAndRemoved {return @(@($user, $user2), @())}
            Mock Find-GroupsToBeAddedAndRemoved {return @(@(), @())}
            Mock Check-UserExists {return $true}
        

            $group = [ADGroup]::new("DevTeam", "LIVE", "SC", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
            $group.UserAccountMembers += $user
            $group.UserAccountMembers += $user2
            $ADChanges = [ADChanges]::new()

            Traverse-Group $group $ADChanges

            It "Checks the group exists" {
                Assert-MockCalled Check-GroupExists -Times 1
            }
            It "Calls Find-UsersToBeAddedAndDeleted" {
                Assert-MockCalled Find-UsersToBeAddedAndRemoved -Times 1
            }
            It "Calls Find-GroupsToBeAddedAndRemoved" {
                Assert-MockCalled Find-GroupsToBeAddedAndRemoved -Times 1
            }
            It "Has called AddUserToGroup twice" {
                $ADChanges.AddUserToGroup.Count | Should Be 2
            }
            It "Has not altered any fields on ADChanges" {
                $ADChanges.RemoveUserFromGroup.Count | Should Be 0
                $ADChanges.CreateGroup.Count | Should Be 0
                $ADChanges.CreateOU.Count | Should Be 0
                $ADChanges.RemoveGroupMemberFromGroup.Count | Should Be 0            
            }
        }

        Context "When a group which exists with no sub groups and two members that need to be removed" {

            $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $false, "DC=subdomain,DC=fakedomain,DC=com", $cred)
            $user = [ADUserAccount]::new("user1", $domain)
            $user2 = [ADUserAccount]::new("user3", $domain)
            Mock Check-GroupExists {return $true}
            Mock Find-UsersToBeAddedAndRemoved {return @(@(), @($user, $user2))}
            Mock Find-GroupsToBeAddedAndRemoved {return @(@(), @())}


            $group = [ADGroup]::new("DevTeam", "LIVE", "SC", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
            $group.UserAccountMembers += $user
            $group.UserAccountMembers += $user2

            $ADChanges = [ADChanges]::new()

            Traverse-Group $group $ADChanges

            It "Checks the group exists" {
                Assert-MockCalled Check-GroupExists -Times 1
            }
            It "Calls Find-UsersToBeAddedAndDeleted" {
                Assert-MockCalled Find-UsersToBeAddedAndRemoved -Times 1
            }
            It "Calls Find-GroupsToBeAddedAndRemoved" {
                Assert-MockCalled Find-GroupsToBeAddedAndRemoved -Times 1
            }
            It "Calls Remove-UserFromGroup twice" {
                $ADChanges.RemoveUserFromGroup.Count | Should Be 2
            }
            It "Has not altered any unnecessary fields on ADChanges" {
                $ADChanges.AddUserToGroup.Count | Should Be 0
                $ADChanges.CreateGroup.Count | Should Be 0
                $ADChanges.CreateOU.Count | Should Be 0
                $ADChanges.RemoveGroupMemberFromGroup.Count | Should Be 0            
            }
        }

        Context "When a group exists with no sub groups and two members, one which needs to be added, the other deleted" {
            Mock Check-GroupExists {return $true}
            Mock Check-UserExists {return $true}
            Mock Find-UsersToBeAddedAndRemoved {return @(@(${'UPN'="user1@subdomain.fakedomain.com"}), @(${'UPN'="user3@subdomain.fakedomain.com"}))}
            Mock Find-GroupsToBeAddedAndRemoved {return @(@(), @())}

            $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $false, "DC=subdomain,DC=fakedomain,DC=com", $cred)

            $group = [ADGroup]::new("DevTeam", "LIVE", "SC", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
            $group.UserAccountMembers += [ADUserAccount]::new("user1", $domain)
            $group.UserAccountMembers += [ADUserAccount]::new("user3", $domain)

            $ADChanges = [ADChanges]::new()

            Traverse-Group $group $ADChanges

            It "Checks the group exists" {
                Assert-MockCalled Check-GroupExists -Times 1
            }
            It "Calls Find-UsersToBeAddedAndDeleted" {
                Assert-MockCalled Find-UsersToBeAddedAndRemoved -Times 1
            }
            It "Calls Find-GroupsToBeAddedAndRemoved" {
                Assert-MockCalled Find-GroupsToBeAddedAndRemoved -Times 1
            }
            It "Calls Remove-UserFromGroup" {
                $ADChanges.RemoveUserFromGroup.Count | Should Be 1
            }
            It "Calls Add-UserToGroup" {
                $ADChanges.AddUserToGroup.Count | Should Be 1
            }
            It "Has not altered any fields on ADChanges" {
                $ADChanges.CreateGroup.Count | Should Be 0
                $ADChanges.CreateOU.Count | Should Be 0
                $ADChanges.RemoveGroupMemberFromGroup.Count | Should Be 0            
            }
        }

        Context "When a group exists with no sub groups and one member who does not need to be added or deleted" {
            Mock Check-GroupExists {return $true}
            Mock Find-UsersToBeAddedAndRemoved {return @(@(), @())}
            Mock Find-GroupsToBeAddedAndRemoved {return @(@(), @())}
        
            $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $false, "DC=subdomain,DC=fakedomain,DC=com", $cred)
            $group = [ADGroup]::new("DevTeam", "LIVE", "SC", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
            $group.UserAccountMembers += [ADUserAccount]::new("user1", $domain)

            $ADChanges = [ADChanges]::new()
            $ADChanges.SystemColours = $systemColours

            Traverse-Group $group $ADChanges

            It "Checks the group exists" {
                Assert-MockCalled Check-GroupExists -Times 1
            }
            It "Calls Find-UsersToBeAddedAndDeleted" {
                Assert-MockCalled Find-UsersToBeAddedAndRemoved -Times 1
            }
            It "Calls Find-GroupsToBeAddedAndRemoved" {
                Assert-MockCalled Find-GroupsToBeAddedAndRemoved -Times 1
            }
            It "Has not altered any fields on ADChanges" {
                $ADChanges.RemoveUserFromGroup.Count | Should Be 0
                $ADChanges.AddUserToGroup.Count | Should Be 0
                $ADChanges.CreateGroup.Count | Should Be 0
                $ADChanges.CreateOU.Count | Should Be 0
                $ADChanges.RemoveGroupMemberFromGroup.Count | Should Be 0            
            }
        }

        Context "When a group which does not exist with no sub groups and no members" {

            Mock Check-GroupExists {return $false}
            Mock Find-UsersToBeAddedAndRemoved {}
            Mock Find-GroupsToBeAddedAndRemoved {}
        
            $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $false, "DC=subdomain,DC=fakedomain,DC=com", $cred)
            $group = [ADGroup]::new("DevTeam", "LIVE", "SC", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 

            $ADChanges = [ADChanges]::new()

            Traverse-Group $group $ADChanges

            It "Checks the group exists" {
                Assert-MockCalled Check-GroupExists -Times 1
            }
            It "Does not call Find-UsersToBeAddedAndDeleted" {
                Assert-MockCalled Find-UsersToBeAddedAndRemoved -Times 0
            }
            It "Does not call Find-GroupsToBeAddedAndRemoved" {
                Assert-MockCalled Find-GroupsToBeAddedAndRemoved -Times 0
            }
            It "Has called Create-Group once" {
                $ADChanges.CreateGroup.Count | Should Be 1
            }
            It "Has not altered any fields on ADChanges" {
                $ADChanges.RemoveUserFromGroup.Count | Should Be 0
                $ADChanges.AddUserToGroup.Count | Should Be 0            
                $ADChanges.CreateOU.Count | Should Be 0
                $ADChanges.RemoveGroupMemberFromGroup.Count | Should Be 0            
            }
        }

        Context "When a group which does not exist with no sub groups and one member to be added" {

            Mock Check-GroupExists {return $false}
            Mock Find-UsersToBeAddedAndRemoved {}
            Mock Find-GroupsToBeAddedAndRemoved {}
            Mock Check-UserExists {return $true}
        
            $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $false, "DC=subdomain,DC=fakedomain,DC=com", $cred)

            $group = [ADGroup]::new("DevTeam", "LIVE", "SC", "Readers", "DL", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
            $group.UserAccountMembers += [ADUserAccount]::new("user1", $domain)

            $ADChanges = [ADChanges]::new()

            Traverse-Group $group $ADChanges

            It "Checks the group exists" {
                Assert-MockCalled Check-GroupExists -Times 1
            }
            It "Does not call Find-UsersToBeAddedAndDeleted" {
                Assert-MockCalled Find-UsersToBeAddedAndRemoved -Times 0
            }
            It "Does not call Find-GroupsToBeAddedAndRemoved" {
                Assert-MockCalled Find-GroupsToBeAddedAndRemoved -Times 0
            }
            It "Has called Add-UserToGroup once" {
                $ADChanges.AddUserToGroup.Count | Should Be 1
            }
            It "Has called Create-Group once" {
                $ADChanges.CreateGroup.Count | Should Be 1
            }
            It "Has not altered any fields on ADChanges" {
                $ADChanges.RemoveUserFromGroup.Count | Should Be 0
                $ADChanges.CreateOU.Count | Should Be 0
                $ADChanges.RemoveGroupMemberFromGroup.Count | Should Be 0            
            }
        }
    }
}