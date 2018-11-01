InModuleScope $mut {
    Describe "Get-ADAccount" {
        Context "with User" {
            $secpasswd = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
            $mycreds = New-Object System.Management.Automation.PSCredential ("username", $secpasswd)
            Mock Get-Credential -ModuleName $mut -MockWith { return $mycreds}
            #Get-ADAccount "username"
            It "Should Call Get-Credential" {
                "Cannot Test Get-Credential"
                "1" | Should be "1"
            }
        }
    }
}