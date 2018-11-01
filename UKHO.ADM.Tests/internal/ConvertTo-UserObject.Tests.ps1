InModuleScope $mut {

    Describe "ConvertTo-UserObject" {
        Context "When passed a valid configuration object" {
            Mock Validate-User { 
                $ret = [ValidationContext]::new()
                return $ret
            }        
            Mock Write-ErrorsAndTerminate {}
            $pwd = ConvertTo-SecureString "123" -AsPlainText -Force
            $cred = New-Object System.Management.Automation.PSCredential ("username", $pwd)
            $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $true, "DC=subdomain,DC=fakedomain,DC=com",$cred)
            $ret = ConvertTo-UserObject -userConfig @{UserName = "user1"} -Domain $domain
            It "does not terminate" {
                Assert-MockCalled Write-ErrorsAndTerminate -Times 0
            }
            It "Returns a user object" {
                $ret.GetType() | Should Be "ADUserAccount"
            }

            It "Returns a correct UPN" {
                $ret.UPN | Should Be "user1@subdomain.fakedomain.com"
            }
        }
        
        Context "When passed an invalid configuration object" {

            Mock Validate-User { 
                $ret = [ValidationContext]::new()
                $ret.ValidationResults += [ValidationResult]::new("An Error", "Something went wrong")
                return $ret
            }
            Mock Write-ErrorsAndTerminate {}

            It "Calls Write-ErrorsAndTerminate once" {

                ConvertTo-UserObject -userConfig $null
                Assert-MockCalled Write-ErrorsAndTerminate -Times 1
            }

        }

    }
}