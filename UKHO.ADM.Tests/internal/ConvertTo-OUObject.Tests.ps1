InModuleScope $mut {

    Describe "ConvertTo-OUObject" {
        Context "When passed an invalid configuration object" {

            Mock Validate-OU { 
                $ret = [ValidationContext]::new()
                $ret.ValidationResults += [ValidationResult]::new("An Error", "Something went wrong")
                return $ret
            }
            Mock Write-ErrorsAndTerminate {}

            It "Calls Validate-Domain once" {        
                ConvertTo-OUObject -OUConfig $null
                Assert-MockCalled Validate-OU -Times 1
            }
            It "Calls Write-ErrorsAndTerminate once" {        
                ConvertTo-OUObject -OUConfig $null
                Assert-MockCalled Write-ErrorsAndTerminate -Times 1
            }
        }

        Context "When passed a valid flat configuration object" {

            Mock Validate-OU { 
                $ret = [ValidationContext]::new()
                return $ret
            }
            Mock Write-ErrorsAndTerminate {}

            $ret = ConvertTo-OUObject -OUConfig @{ Name = "foo"}

            It "Calls Validate-OU once" {        
                ConvertTo-OUObject -OUConfig $null
                Assert-MockCalled Validate-OU -Times 1
            }
            It "Calls Write-ErrorsAndTerminate never" {        
                ConvertTo-OUObject -OUConfig $null
                Assert-MockCalled Write-ErrorsAndTerminate -Times 0
            }
            It "returns an OU object" {       
                $ret.GetType() | Should Be "ADOrganisationalUnit"
            }
        }

        Context "When passed a valid nested configuration object" {

            Mock Validate-OU { 
                $ret = [ValidationContext]::new()
                return $ret
            }
            Mock Write-ErrorsAndTerminate {}

            $ret = ConvertTo-OUObject -OUConfig @{Name = "foo"; SubOUs = @(@{Name = "Devs"; SubOUs = @(@{Name = "Admins"; })})}

            It "Calls Validate-OU 3 times" {        
                ConvertTo-OUObject -OUConfig $null
                Assert-MockCalled Validate-OU -Times 3
            }
            It "Calls Write-ErrorsAndTerminate never" {        
                ConvertTo-OUObject -OUConfig $null
                Assert-MockCalled Write-ErrorsAndTerminate -Times 0
            }
            It "returns an OU object" {
            
                $ret[0].Name | Should Be "foo"
                $ret[0].SubOrganisationalUnits[0].Name | Should Be "Devs"
                $ret[0].SubOrganisationalUnits[0].SubOrganisationalUnits[0].Name | Should Be "Admins"
            }
        }
    }
}