InModuleScope $mut {
    Describe "Get-NonADMGeneratedGroup" {
        $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $false, "DC=subdomain,DC=fakedomain,DC=com", $cred)
        $ou = [ADOrganisationalUnit]::new("UKHO", "OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain)
        $group = [ADGroup]::new("DevTeam", "LIVE", "SC", "Readers", "GG", "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain) 
    
        Context "When passed a group is in same domain" {
            $groupConfig = @{Settings = @{ GroupPrefix = "Noo" }; Name = "Foo"; Groups = @(@{DistinguishedName = "CN=Hello,DC=subdomain,DC=fakedomain,DC=com"}); }
            
            Mock Check-GroupExists { return $true }

            Get-NonADMGeneratedGroup -OU $ou -GroupConfig $groupConfig -ggGroup $group
            
            It "Calls Check-GroupExists" {
                Assert-MockCalled Check-GroupExists -Times 1
            }

        }

        
        Context "When passed a group is in different domain" {            
            $groupConfig = @{Settings = @{ GroupPrefix = "Noo" }; Name = "Foo"; Groups = @(@{DistinguishedName = "CN=Hello,DC=subdomain1,DC=fakedomain,DC=com"}); }

            Mock Check-GroupExists { return $true }

            Get-NonADMGeneratedGroup -OU $ou -GroupConfig $groupConfig -ggGroup $group
            
            It "Does not call Check-GroupExists" {
                Assert-MockCalled Check-GroupExists -Times 0
            }

        }
    }
}