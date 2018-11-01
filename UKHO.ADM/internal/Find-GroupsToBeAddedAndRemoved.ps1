function Find-GroupsToBeAddedAndRemoved {
    [CmdletBinding()]
    param(
        [ADGroup]$group
    )

    # Get all groups from the AD group and turn the groups into a dictionary with the distinguishedName as the key.
    begin {
    $groupsAlreadyinGroup = @{}
    }
    process {
    Get-ADGroupMember -Identity $group.DistinguishedName -Server $group.Domain.DomainController | 
        Where-Object {$_.objectClass -eq "group"} | 
        ForEach-Object {$groupsAlreadyinGroup[$_.DistinguishedName] = $_}
        
    # Turn all the users from this group which has been loaded from the config into a dictionary with ther SAM as the key.
    $groupsThatNeedToBeInGroup = @{}
    $group.ADGroupMembers | ForEach-Object {$groupsThatNeedToBeInGroup[$_.DistinguishedName] = $_}
    }
    end {
        Get-Differences $groupsThatNeedToBeInGroup $groupsAlreadyinGroup
    }
}