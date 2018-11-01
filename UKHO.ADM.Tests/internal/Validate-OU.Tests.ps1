InModuleScope $mut {


    Describe "Validate-OU" {
        Context "When passed a null ouConfig object" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-OU -OUConfig $null
                $ret.IsValid() | Should Be $false
            }
        }

        Context "When passed a non-null ouConfig object without a Name" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-OU -OUConfig @{ Fred = "bar" }
                $ret.IsValid() | Should Be $false
            }
        }

        Context "When passed a non-null ouConfig object with a Name" {
            It "Returns a validationcontext with IsValid = true" {
                $ret = Validate-OU -OUConfig @{ Name = "foobar"; }
                $ret.IsValid() | Should Be $true
            }
        }
    }
}