
InModuleScope $mut {
    Describe "Split-UserDistinguishedName" {
        Context "When a user distinguished name is used" {
            $input = "CN=Person A,OU=DevTeam,OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com"

            $result = Split-UserDistinguishedName $input

            It "Should return CN" {
                $result.CN | Should Be "Person A"
            }
            It "Should return DC" {
                $result.DC | Should Be "subdomain.fakedomain.com"
            }
        }
    }
}