function Find-UsersToBeAddedAndRemoved {    
    [CmdletBinding()]
    param(
        [ADGroup]$group
    )

    # Get all members from the AD group and turn the users into a dictionary with the SAM as the key.
    begin {
        $usersAlreadyinGroup = @{}
    }
    process {
        Get-ADGroupMember -Identity $group.DistinguishedName -Server $group.Domain.DomainController | 
            Where-Object {$_.objectClass -eq "user"} | 
            ForEach-Object {$usersAlreadyinGroup[$_.SamAccountName] = $_}
        
        # Turn all the users from this group which has been loaded from the config into a dictionary with ther SAM as the key.
        $usersThatNeedToBeInGroup = @{}
        $group.UserAccountMembers | ForEach-Object {$usersThatNeedToBeInGroup[$_.SamAccountName] = $_}
    }
    end {
        Get-Differences $usersThatNeedToBeInGroup $usersAlreadyinGroup
    }
}