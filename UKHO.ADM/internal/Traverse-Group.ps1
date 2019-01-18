#Traverse a group, creating and adding group members as needed as well as adding users to the group
function Traverse-Group {
    [CmdletBinding()]
    param(
        [ADGroup]$group,
        [ADChanges]$ADChanges
    )
    begin {}    
    process {
        if (Check-GroupExists $group) {

            ############################################
            # USERS TO BE ADDED AND REMOVED FROM GROUP #
            ############################################

            $toBeAdded, $toBeRemoved = Find-UsersToBeAddedAndRemoved $group
            foreach ($user in $toBeRemoved) {
                $ADChanges.RemoveUserFromG($user, $group)
            }

            foreach ($user in $toBeAdded) {
                $ADChanges.AddUserToG($user, $group) 
            }

            ####################################################
            # GROUP MEMBERS TO BE ADDED AND REMOVED FROM GROUP #
            ####################################################

            $toBeAdded, $toBeRemoved = Find-GroupsToBeAddedAndRemoved $group
            foreach ($grup in $toBeRemoved) {
                $ADChanges.RemoveGroupMemberFromG($grup, $group)
            }

            foreach ($grup in $toBeAdded) {
                $ADChanges.AddGroupMemberToG($grup, $group)
            }
        }
        else { 
            # The group doesn't exist so it has to be created, so EVERYTHING has to be added to it.
            $ADChanges.CreateG($group)

            foreach ($user in $group.UserAccountMembers) {
                $ADChanges.AddUserToG($user, $group)
            }

            foreach ($grup in $group.ADGroupMembers) {

                $ADChanges.AddGroupMemberToG($grup, $group)
            }
        }

        foreach ($g in $($group.ADGroupMembers | Where-Object ADMGenerated -eq $true) ) {
            $ADChanges = Traverse-Group $g $ADChanges
        }
    }
    end {
        $ADChanges
    }
}