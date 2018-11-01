InModuleScope $mut {
    Describe "Traverse-AD" {
        Context "When passing in an OU with two sub OUs" {

            Mock Check-OUExists {}
            Mock Traverse-Group {}

            # Set up a OU structure with:
            #   OU - UKHO
            #       SubOU - dbTeam
            #           Group - Readers
            #       SubOU - DevTeams
            #           Group - DevTeam2
            #           Group - DevTeam3        
        
            $domain = [ADDomain]::new("subdomain.fakedomain.com", "server1.subdomain.fakedomain.com", $false, "DC=subdomain,DC=fakedomain,DC=com", $cred)
            $ou = [ADOrganisationalUnit]::new("UKHO", "OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain)

            $dbTeam = [ADOrganisationalUnit]::new("dbTeam", "OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain)
            $dbTeam.Groups += [ADGroup]::new("SC", "LIVE", "dbTeam", "Readers", "DL", "OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain)

            $devTeamsOU = [ADOrganisationalUnit]::new("Commercial", "OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain)        
            $devTeamsOU.Groups += [ADGroup]::new("SC", "","Commercial", "DevTeam2", "DL", "OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain)
            $devTeamsOU.Groups += [ADGroup]::new("SC", "","Commercial", "DevTeam3", "DL", "OU=UKHO,OU=SC,OU=ACG,OU=UPA,DC=subdomain,DC=fakedomain,DC=com", $domain)
            $ou.SubOrganisationalUnits += $dbTeam
            $ou.SubOrganisationalUnits += $devTeamsOU
      
            Traverse-OU $ou

            It "Calls Check-OU" {
                Assert-MockCalled Check-OUExists -Times 3 # It should call Check-OU for each OU/SubOU (This test has one OU with two sub OUs)
            }

            It "Calls Traverse-Group" {
                Assert-MockCalled Traverse-Group -Times 3 # It should be called once for each group in each OU
            }

        }    
    }
}