InModuleScope $mut {

    Describe "ConvertTo-GroupObjects" {
        $pwd = ConvertTo-SecureString "123" -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ("username", $pwd)

        Context "When passed an invalid configuration object" {

            Mock Validate-Group { 
                $ret = [ValidationContext]::new()
                $ret.ValidationResults += [ValidationResult]::new("An Error", "Something went wrong")
                return $ret
            }
            Mock Write-ErrorsAndTerminate {}

            It "Calls Write-ErrorsAndTerminate once" {

                ConvertTo-GroupObjects -GroupConfig $null
                Assert-MockCalled Write-ErrorsAndTerminate -Times 1
            }
        }

        Context "When passed a valid configuration object" {

            Mock Validate-Group { 
                $ret = [ValidationContext]::new()
                return $ret
            }
            Mock Write-ErrorsAndTerminate {}
        
            $ou = [ADOrganisationalUnit]::new("Bar", "", $null)
            [ADGroup[]]$ret = ConvertTo-GroupObjects -Settings @{ GroupPrefix = "Noo" } -GroupConfig @{ Settings = @{ GroupPrefix = "Noo" }; Name = "Foo" } -OU $ou

            It "returns an array of ADGroup elements" {
                $ret.GetType() | Should Be "ADGroup[]"
            }

            It "returns an ADGroup object array with 2 elements" {
                $ret.Count | Should Be 2
            }
            It "Should not call Write-ErrorsAndTerminate" {
                Assert-MockCalled Write-ErrorsAndTerminate -Times 0
            }
            It "should return a UG Group" {
                ($ret | Where-Object {$_.Name -eq "AG_Noo_Bar_Foo-UG"}).Count | Should Be 1
            }
            It "should return a GG Group" {
                ($ret | Where-Object {$_.Name -eq "AG_Noo_Bar_Foo-GG"}).Count | Should Be 1
            }
        }

        Context "When passed a valid configuration object and is in the primary domain" {
        
            Mock Validate-Group { 
                $ret = [ValidationContext]::new()
                return $ret
            }
            Mock Write-ErrorsAndTerminate {}
        
            $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $true, "DC=subdomain,DC=fakedomain,DC=com",$cred)
            $ou = [ADOrganisationalUnit]::new("Bar", "", $domain)
            [ADGroup[]]$ret = ConvertTo-GroupObjects -Settings @{ GroupPrefix = "Noo" } -GroupConfig @{Settings = @{ GroupPrefix = "Noo" }; Name = "Foo" } -OU $ou

            It "returns an array of ADGroup elements" {
                $ret.GetType() | Should Be "ADGroup[]"
            }      
            It "returns an ADGroup object array with 2 elements" {
                $ret.Count | Should Be 2
            }
            It "Should not call Write-ErrorsAndTerminate" {
                Assert-MockCalled Write-ErrorsAndTerminate -Times 0
            }
            It "should return a DL Group" {
                ($ret | Where-Object {$_.Name -eq "AG_Noo_Bar_Foo-DL"}).Count | Should Be 1
            }
            It "should return a GG Group" {
                ($ret | Where-Object {$_.Name -eq "AG_Noo_Bar_Foo-GG"}).Count | Should Be 1
            }
        }
    }
}