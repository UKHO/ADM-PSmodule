function Split-GroupDistinguishedName {
    [CmdletBinding()]
    param(
        [string]$distinguishedName
    )

    begin {
        $nameSplit = $distinguishedName.Split(",", 2) #Split on the first occurance of `,`. Should return two strings
        $path = $namesplit[1]
        $groupNameSplit = $nameSplit[0].Split("=") # Split on any =. This should leave the usable name in the second variable
        $groupScope = $groupNameSplit[1].Substring($groupNameSplit[1].Length - 2)
    }
    process {
        switch ($groupScope) {
            "DL" {
                $groupScope = 'DomainLocal'            
            }
            "GG" {
                $groupScope = 'Global'
            }
            "UG" {
                $groupScope = 'Universal'
            }
        }
    }

    end {
        @{"Path" = $path; "GroupScope" = $groupScope; }
    }
}