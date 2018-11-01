
InModuleScope $mut {

    Describe "Validate-Group" {
        Context "When passed a null Group object" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-Group -GroupConfig $null
                $ret.IsValid() | Should Be $false
            }
        }

        Context "When passed a non-null Config object without a Name" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-Group -GroupConfig @{ Bar = "foo"; }
                $ret.IsValid() | Should Be $false
            }
        }

        Context "When passed a non-null Config object without a Settings Object" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-Group -GroupConfig @{ Bar = "foo"; }
                $ret.IsValid() | Should Be $false
            }
        }

        Context "When passed a non-null Config object without a GroupPrefix in the Settings Object" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-Group -GroupConfig @{ Settings = @{}; Bar = "foo"; }
                $ret.IsValid() | Should Be $false
            }
        }

        Context "When passed a Config object with a Name and GroupPrefix" {
            It "Returns a validationcontext with IsValid = true" {
                $ret = Validate-Group -GroupConfig @{ Settings = @{GroupPrefix = "Noo"}; Name = "bar"; }
                $ret.IsValid() | Should Be $true
            }
        }
    }
}