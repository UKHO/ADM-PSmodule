InModuleScope $mut {
    Describe "Validate-User" {
        Context "When passed a null config object" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-User -userConfig $null
                $ret.IsValid() | Should Be $false
            }
        }

        Context "When passed a non-null config object without a UserName" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-User -userConfig @{ Domain = "bar" }
                $ret.IsValid() | Should Be $false
            }
        }

        Context "When passed a non-null config object without a Domain" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-User -userConfig @{ UserName = "foobar"; }
                $ret.IsValid() | Should Be $false
            }
        }


        Context "When passed a non-null config object with a UserName and Domain" {
            It "Returns a validationcontext with IsValid = true" {
                $ret = Validate-User -userConfig @{ UserName = "foobar"; Domain = "foobar" }
                $ret.IsValid() | Should Be $true
            }
        }
    }
}