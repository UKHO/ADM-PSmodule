InModuleScope $mut {
    Describe "Update-AD" {
        Context "with valid cd" {
            Mock Generate-ConfigurationObject       
            Mock Get-ADChanges
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