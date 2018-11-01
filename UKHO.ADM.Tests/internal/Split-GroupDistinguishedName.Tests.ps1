
InModuleScope $mut {
    Describe "Split-GroupDistinguishedName" {
        Context "When a Global Group distinguished name is used" {
            $input = "CN=AG_DevTeam_ProjectAdmins-GG,OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com"

            $result = Split-GroupDistinguishedName $input

            It "Should return the correct path" {
                $result.Path | Should Be "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com"
            }
            It "Should return the correct groupScope" {
                $result.GroupScope | Should Be "Global"
            }
        }
        Context "When a DomainLocal Group distinguished name is used" {
            $input = "CN=AG_DevTeam_ProjectAdmins-DL,OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com"

            $result = Split-GroupDistinguishedName $input

            It "Should return the correct path" {
                $result.Path | Should Be "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com"
            }
            It "Should return the correct groupScope" {
                $result.GroupScope | Should Be "DomainLocal"
            }
        }
        Context "When a Universal Group distinguished name is used" {
            $input = "CN=AG_DevTeam_ProjectAdmins-UG,OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com"

            $result = Split-GroupDistinguishedName $input

            It "Should return the correct path" {
                $result.Path | Should Be "OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com"
            }
            It "Should return the correct groupScope" {
                $result.GroupScope | Should Be "Universal"
            }
        }
    }
}