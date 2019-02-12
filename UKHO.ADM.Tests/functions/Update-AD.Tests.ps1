InModuleScope $mut {
    Describe "Update-AD" {
        Context "with valid cd" {
            Mock Generate-ConfigurationObject       
            Mock Get-ADChanges { return @{ "CreatedOUs" = 1; SystemColours = @{
                "info" = "White";
                "adding" = "Green";
                "remove" = "Red";
                "modify" = "Yellow";
                "error" = "Magenta";
                "header" = "Blue";
                "detail" = "Gray";
            }}}
            Update-AD -cd @{}
            It "Should Call Generate-ConfigurationObject" {
                Assert-MockCalled Generate-ConfigurationObject
            }
            It "Should Call Get-ADChanges" {
                Assert-MockCalled Get-ADChanges
            }
        }
    }
}