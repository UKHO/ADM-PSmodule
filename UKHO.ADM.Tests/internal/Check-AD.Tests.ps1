InModuleScope $mut {
    Describe "Check-OUExists" {
        $pwd = ConvertTo-SecureString "123" -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ("username", $pwd)
        $domain = [ADDomain]::new("fakedomain.com", "server1.fakedomain.com", $false, "DC=subdomain,DC=fakedomain,DC=com",$cred)

        Context "When an OU which exists is passed in" {

            Mock Get-ADOrganizationalUnit {return ""}

            $ou = [ADOrganisationalUnit]::new("UKHO", "OU=UKHO,OU=TFS,OU=ACG,OU=Accounts,DC=subdomain,DC=fakedomain,DC=com", $domain)
      
            $result = Check-OUExists $ou

            It "Checks the OU exists" {
                Assert-MockCalled Get-ADOrganizationalUnit  -Times 1
            }
            It "Returns true" {
                $result | Should Be $true
            }
        }

        Context "When an OU that does not exist is passed in" {

            Mock Get-ADOrganizationalUnit {throw [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] "blah"}

            $ou = [ADOrganisationalUnit]::new("UKHO", "OU=DoesNotExsist,OU=UKHO,OU=TFS,OU=ACG,OU=Accounts,DC=subdomain,DC=fakedomain,DC=com", $domain)
      
            $result = Check-OUExists $ou

            It "Checks the OU exists" {
                Assert-MockCalled Get-ADOrganizationalUnit -Times 1
            }
            It "Returns false" {
                $result | Should Be $false
            }
        }
    }
}