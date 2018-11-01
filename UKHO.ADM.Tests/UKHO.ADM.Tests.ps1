Describe "$mut Module Tests" {
    Context "Module Manifest" {
        It "has the root module file of $mut.psm1" {
            "$moduleRoot\$mut.psm1" | Should Exist
        }

        It "has a manifest file $mut.psd1 in the root" {
            "$moduleRoot\$mut.psd1" | Should Exist
        }

        It "has a manifest file with a root module entry of $mut.psm1" {
            "$moduleRoot\$mut.psd1" | Should -FileContentMatchExactly "RootModule = '$mut.psm1'"
        }
    }
    Context "Manifest Content" {
        [HashTable]$Manifest = Import-LocalizedData -BaseDirectory $moduleRoot -FileName "$mut.psm1"
        It "has Description set" {
            $Manifest.Description | Should Not Be $null
            $Manifest.Description | Should Not Be ""
        }

        It "has a PrivateData.PsData.LicenseUri set" {
            $Manifest.PrivateData.PsData.LicenseUri | Should Not Be $null
        }
    }

    Context "Module Functions" {
        It "has no function files in the root" {
            (Get-ChildItem $moduleRoot -Filter "*.ps1").Count | Should Be 0
        }

        It "$mut is valid PowerShell code" {
            $psFile = Get-Content -Path "$moduleRoot\$mut.psm1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            if ($errors.Count -gt 0) {
                Write-Host $errors.Message
            }
            $errors.Count | Should Be 0
        }
        Get-ChildItem -Path $moduleRoot\internal -Filter "*.ps1" | ForEach-Object {
            $file = $_
            It "$($file.Name) is valid Powershell code" {
                $psFile = Get-Content -Path "$($file.FullName)" -ErrorAction Stop
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                if ($errors.Count -gt 0) {
                    Write-Host $errors.Message
                }
                $errors.Count | Should Be 0
            }
            It "$($file.Name) contains a maximum of one function" {
                (([string](Get-Content -Path $file.FullName).Split(" ") | Where-Object { $_ -eq "function" }).Count -le 1) | Should Be $true
            }
        }

        Get-ChildItem -Path @("$moduleRoot\functions", "$moduleRoot\internal") -Filter "*.ps1" | Where-Object { ([string](Get-Content -Path $_.FullName) -match "function") } | ForEach-Object {
            $file = $_
            It "$($file.Name)'s function is decorated with cmdletbinding attribute" {
                [string](Get-Content -Path $file.FullName) -match "[CmdletBinding()]" | Should Be $true
            } 
            It "$($file.Name)'s function has a begin block" {
                [string](Get-Content -Path $file.FullName) -match "begin {" | Should Be $true
            } 
            It "$($file.Name)'s function has a process block" {
                [string](Get-Content -Path $file.FullName) -match "process {" | Should Be $true
            }
            It "$($file.Name)'s function has a end block" {
                [string](Get-Content -Path $file.FullName) -match "end {" | Should Be $true
            }  
        }
    }
}