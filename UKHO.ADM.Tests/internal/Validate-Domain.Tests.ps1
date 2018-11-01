InModuleScope $mut {


    Describe "Validate-Domain" {
        Context "When passed a null domainConfig object" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-Domain -DomainConfig $null
                $ret.IsValid() | Should Be $false
            }
        }

        Context "When passed a non-null domainConfig object without an FQDN" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-Domain -DomainConfig @{ DomainController = "foo"; RootOU = "bar" }
                $ret.IsValid() | Should Be $false
            }
        }

        Context "When passed a non-null domainConfig object without a DomainController (DC)" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-Domain -DomainConfig @{ FQDN = "bar"; RootOU = "foo"  }
                $ret.IsValid() | Should Be $false
            }
        }

        Context "When passed a non-null domainConfig object without a RootOU" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-Domain -DomainConfig @{ FQDN = "bar"; DomainController = "foo"  }
                $ret.IsValid() | Should Be $false
            }
        }

        Context "When passed a non-null domainConfig object with a FQDN, DomainController and RootOU" {
            It "Returns a validationcontext with IsValid = false" {
                $ret = Validate-Domain -DomainConfig @{ FQDN = "bar"; DomainController = "foo"; DistinguishedName = "foobar"  }
                $ret.IsValid() | Should Be $false
            }
        }
        Context "When passed a non-null domainConfig object with a FQDN, DomainController, RootOU and credential" {
            It "Returns a validationcontext with IsValid = false" {
                $secpasswd = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
                $mycreds = New-Object System.Management.Automation.PSCredential ("username", $secpasswd)
                $ret = Validate-Domain -DomainConfig @{ FQDN = "bar"; DomainController = "foo"; DistinguishedName = "foobar"; Credential = $mycreds  }
                $ret.IsValid() | Should Be $true
            }
        }
    }
}