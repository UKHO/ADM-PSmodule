InModuleScope $mut {
    Describe "ConvertTo-DomainObject" {
        Context "When passed an invalid configuration object" {

            Mock Validate-Domain { 
                $ret = [ValidationContext]::new()
                $ret.ValidationResults += [ValidationResult]::new("An Error", "Something went wrong")
                return $ret
            }
            Mock Write-ErrorsAndTerminate {}

            It "Calls Write-ErrorsAndTerminate once" {

                ConvertTo-DomainObject -DomainConfig $null
                Assert-MockCalled Write-ErrorsAndTerminate -Times 1
            }
        }

        Context "When passed a valid configuration object" {

            Mock Validate-Domain { 
                $ret = [ValidationContext]::new()
                return $ret
            }
            Mock Write-ErrorsAndTerminate {}
        
            $ret = ConvertTo-DomainObject -DomainConfig @{ FQDN = "foo"; DomainController = "bar"; DistinguishedName = "foobar" }

            It "returns an ADDomain object" {
                $ret.GetType() | Should Be "ADDomain"
            }
            It "Should not call Write-ErrorsAndTerminate" {
                Assert-MockCalled Write-ErrorsAndTerminate -Times 0
            }
        }

        Context "When passed a configuration object without a IsPrimary property" {
            Mock Validate-Domain { 
                $ret = [ValidationContext]::new()
                return $ret
            }
            Mock Write-ErrorsAndTerminate {}

            $ret = ConvertTo-DomainObject -DomainConfig @{ FQDN = "foo"; DomainController = "bar"; DistinguishedName = "foobar" }

            It "returns an ADDomain object with IsPrimary as false" {
                $ret.IsPrimary | Should Be $false
            }
            It "Should not call Write-ErrorsAndTerminate" {
                Assert-MockCalled Write-ErrorsAndTerminate -Times 0
            }
        }

        Context "When passed a configuration object with IsPrimary set to false" {

            Mock Validate-Domain { 
                $ret = [ValidationContext]::new()
                return $ret
            }

            Mock Write-ErrorsAndTerminate {}

            $ret = ConvertTo-DomainObject -DomainConfig @{ FQDN = "foo"; DomainController = "bar"; DistinguishedName = "foobar"; IsPrimary = $false}

            It "returns an ADDomain object with IsPrimary as false" {
                $ret.IsPrimary | Should Be $false
            }
            It "Should not call Write-ErrorsAndTerminate" {
                Assert-MockCalled Write-ErrorsAndTerminate -Times 0
            }
        }
    }
}