class ValidationResult {

    ValidationResult([string]$propertyName, [string]$message) {
        $this.PropertyName = $propertyName
        $this.Message = $message
    }
    
    [string]$PropertyName
    [string]$Message
    [bool]$IsWarning
    
}
    
class ValidationContext {
    ValidationContext() {
        $this.ValidationResults = @()
    }
    
    [ValidationResult[]]$ValidationResults
    
    [bool]IsValid() {
        return ($this.ValidationResults -eq $null) -or ($this.ValidationResults.Count -le 0)
    }
}

class ADGroup {    
    [string]$namingConvention = "AG_{0}_{1}_{2}_{3}-{4}"

    ADGroup([string]$GroupPrefix,[string]$Environment, [string]$containerName, [string]$GroupName, [string]$groupLevel, [string]$currentADPath, [ADDomain]$domain) {
        $this.Name = ($this.namingConvention -f $GroupPrefix, $Environment, $containerName, $GroupName, $groupLevel).Replace("__","_").Replace(" ","")
        $this.DistinguishedName = ("CN={0},{1}" -f $this.Name, $currentADPath)
        $this.ADGroupMembers = @()
        $this.UserAccountMembers = @()
        $this.Domain = $domain
        $this.ADMGenerated = $true
    }

    ADGroup([string]$DistinguishedName, [ADDomain]$domain) {
        $this.DistinguishedName = $distinguishedName
        $this.Name = $this.DistinguishedName.Split(',')[0].Split("=")[1]
        $this.Domain = $domain
        $this.ADMGenerated = $false
    }

    
    [string]$Name
    [ADUserAccount[]]$UserAccountMembers
    [ADGroup[]]$ADGroupMembers
    [string]$DistinguishedName
    [ADDomain] $Domain
    [bool]$ADMGenerated

}

class ADUserAccount {

    ADUserAccount([string]$name, [ADDomain]$domain) {
        $this.UPN = ("{0}@{1}" -f $name, $domain.FQDN) #fredBob@domain.co.uk
        $this.SamAccountName = $name #fredBob
        $this.Domain = $domain
    }
    
    [string]$SamAccountName
    [ADDomain]$Domain
    [string]$UPN
}

class ADOrganisationalUnit {

    #ContainerName
    #Name
    #Group Level
    [string]$namingConvention = "AG_{0}_{1}-{2}"

    ADOrganisationalUnit([string]$name, [string]$currentADPath, [ADDomain]$domain) {
        $this.Name = $name
        $this.ParentOrganistaionalUnit = $currentADPath
        $this.DistinguishedName = ("OU={0},{1}" -f $name, $currentADPath)
        $this.Domain = $domain
    }

    [string]$Name
    [string]$DistinguishedName
    [ADOrganisationalUnit[]]$SubOrganisationalUnits
    [ADGroup[]]$Groups
    [string]$ParentOrganistaionalUnit
    [ADDomain]$Domain = $domain

}

class ADDomain {

    ADDomain([string]$fqdn, [string]$domainController, [bool]$isPrimary, [string]$distinguishedName, [PSCredential]$Credential) {
        $this.FQDN = $fqdn
        $this.DomainController = $domainController
        $this.IsPrimary = $isPrimary
        $this.DistinguishedName = $distinguishedName
        $this.OrganisationalUnits = @()
        $this.Credential = $Credential
    }

    [string]$FQDN
    [bool]$IsPrimary
    [string]$DomainController
    [string]$DistinguishedName
    [ADOrganisationalUnit[]]$OrganisationalUnits
    [pscredential]$Credential
}

class ADChanges {

    ADChanges() {
        $this.RemoveUserFromGroup = @()
        $this.AddUserToGroup = @()
        $this.CreateGroup = @()
        $this.CreateOU = @()
        $this.RemoveGroupMemberFromGroup = @()
        $this.AddGroupMemberToGroup = @()
        $this.RemovedUsers = 0
        $this.AddedUsers = 0
        $this.CreatedOUs = 0
        $this.CreatedGroups = 0
        $this.AddedGroups = 0
        $this.RemovedGroups = 0
        $this.DeletedGroups = 0
        $this.h = Get-Host 
    }
    
    # Stores all strings output to the host during the "changes" phase
    # Because we check if a group exists multiple times (one group can be a group member of many groups) it is possible to say "CREATE GROUP"(and the similar) multiple times
    # Having all the output in a single object means we can easily check if we have already encountered this exact "CREATE GROUP" step before.
    hidden $StringContent = @{} 
    hidden $h

    [ScriptBlock[]]$RemoveUserFromGroup
    [ScriptBlock[]]$AddUserToGroup
    [ScriptBlock[]]$CreateGroup
    [ScriptBlock[]]$CreateOU
    [ScriptBlock[]]$RemoveGroupMemberFromGroup
    [int]$RemovedUsers
    [int]$AddedUsers 
    [int]$CreatedOUs
    [int]$CreatedGroups
    [int]$AddedGroups
    [int]$RemovedGroups
    [int]$DeletedGroups
    # UnsafeOperation and has to be done last
    [ScriptBlock[]]$AddGroupMemberToGroup
    
    CreateO([ADOrganisationalUnit] $ADOrganisationalUnit) {
        $outputString = "CREATE OU $($ADOrganisationalUnit.DistinguishedName)"
        if ($this.StringContent.ContainsKey($outputString) -eq $false) {
            $this.StringContent.Add($outputString, $true)
            Write-Color -LinesBefore 2 "`t+ CREATE OU $($ADOrganisationalUnit.Name) on $($ADOrganisationalUnit.Domain.FQDN)" -Color Green
            Write-Color "`t`t$($ADOrganisationalUnit.DistinguishedName)" -Color White
            $this.CreatedOUs += 1

            $f = {
                Write-Verbose "Attempting to create OU $($ADOrganisationalUnit.DistinguishedName)"
                try {
                    New-ADOrganizationalUnit $ADOrganisationalUnit.Name -Path $ADOrganisationalUnit.ParentOrganistaionalUnit -Server $ADOrganisationalUnit.Domain.DomainController -Credential $ADOrganisationalUnit.Domain.Credential
                    Write-Colour -LinesBefore 2 "`t+ CREATED OU $($ADOrganisationalUnit.Name) on $($ADOrganisationalUnit.Domain.FQDN)" -Color Green
                    Write-Colour "`t`t$($ADOrganisationalUnit.DistinguishedName)" -Color White
                }
                Catch {
                    Write-Color "x Failed to create OU $($ADOrganisationalUnit.DistinguishedName) :" -ForegroundColor Magenta
                    Write-Color -LinesBefore 1 "`t$_" -Color White #Echos out the exceptions message
                    throw;         
                }
            }.GetNewClosure() 
    
            $this.CreateOU += $f
        }
    }

    CreateG([ADGroup] $group) {
        $outputString = "CREATE GROUP $($group.DistinguishedName)"    

        if ($this.StringContent.ContainsKey($outputString) -eq $false) {
            $this.StringContent.Add($outputString, $true)
            Write-Color -LinesBefore 1 "`t+ CREATE GROUP $($group.Name) on $($group.Domain.FQDN)" -Color Green
            Write-Color "`t`t $($group.DistinguishedName)" -Color White
            $this.CreatedGroups += 1
            $n = Split-GroupDistinguishedName $group.DistinguishedName
    
            $f = {
                Write-Verbose "Attempting to create group $($group.DistinguishedName)" 
                
                try {
                    New-ADGroup -Name $group.Name -GroupScope $n.GroupScope -Path $n.Path -GroupCategory "Security" -Confirm:$false -Server $Group.Domain.DomainController -Credential $Group.Domain.Credential
                    Write-Color -LinesBefore 1 "`t+ CREATED GROUP $($group.Name) on $($group.Domain.FQDN)" -Color Green
                    Write-Color "`t`t $($group.DistinguishedName)" -Color White
                }
                catch {
                    Write-Color "x Failed to create group $($group.DistinguishedName) :" -Color Magenta
                    Write-Color -LinesBefore 1 "`t$_" -Color White #Echos out the exceptions message
                    throw;
                }
    
            }.GetNewClosure() 
        
            $this.CreateGroup += $f
        }
    }

    RemoveUserFromG($user, [ADGroup] $group) {
        $outputString = "REMOVE USER $($user.SamAccountName) FROM GROUP $($group.DistinguishedName)"

        if ($this.StringContent.ContainsKey($outputString) -eq $false) {
            $this.StringContent.Add($outputString, $true)
            Write-Color "`t~ Modify Group $($group.Name) on $($group.Domain.FQDN)" -Color Yellow
            Write-Color "`t`t$($group.DistinguishedName)" -Color White
            Write-Color "`t`t- Remove User $($user.SamAccountName)" -Color Red
            $this.RemovedUsers += 1
            $f = {
                Write-Verbose "Attempting to remove user $($user.SamAccountName) from group $($group.DistinguishedName)"
                try {
                    Remove-ADGroupMember -Identity $group.DistinguishedName -Members $user.SamAccountName -Confirm:$false -Server $group.Domain.DomainController  -Credential $group.Domain.Credential
                    Write-Color -LinesBefore 1 "`t~ Modified Group $($group.Name) on $($group.Domain.FQDN)" -Color Yellow
                    Write-Color "`t`t $($group.DistinguishedName)" -Color White
                    Write-Color "`t`t- REMOVED USER $($user.SamAccountName)" -Color Red 
                }
                catch {
                    Write-Color "x Failed to remove user $($user.SamAccountName) from group $($group.DistinguishedName):" -Color Magenta
                    Write-Color "`t$_" -Color White #Echos out the exceptions message                    
                    throw;
                }            
            }.GetNewClosure() 
            
           $this.RemoveUserFromGroup += $f
        }   
    }

   AddUserToG([ADUserAccount]$user, [ADGroup] $group) {
        if (Check-UserExists $user) {        
            $outputString = "ADD USER $($user.UPN) TO GROUP $($group.DistinguishedName)"
    
            if ($this.StringContent.ContainsKey($outputString) -eq $false) {
                $this.StringContent.Add($outputString, $true)
                Write-Color -LinesBefore 1 "`t~Modify Group $($group.Name) on $($group.Domain.FQDN)" -Color Yellow
                Write-Color "`t`t $($group.DistinguishedName)" -Color White            
                Write-Color "`t`t+ Add User $($user.SamAccountName)" -Color Green
                $this.AddedUsers += 1
                $f = {
                    Write-Verbose "Attempting to add user $($user.SamAccountName) to group $($group.DistinguishedName)"
                    try {                                        
                        Add-ADGroupMember -Identity $group.DistinguishedName -Members $user.SamAccountName -Confirm:$false -Server $User.Domain.DomainController -Credential $User.Domain.Credential
                        Write-Color -LinesBefore 1 "`t~Modified Group $($group.Name) on $($group.Domain.FQDN)" -Color Yellow
                        Write-Color "`t`t $($group.DistinguishedName)" -Color White
                        Write-Color "`t`t+ ADDED USER $($user.SamAccountName)" -Color Green
                    }
                    Catch {                
                        Write-Color "x Failed to add user $($user.SamAccountName) to group $($group.DistinguishedName):" -Color Magenta
                        Write-Color "`t$_" -Color White #Echos out the exceptions message
                        throw;
                    }                
                }.GetNewClosure()         
                $this.AddUserToGroup += $f
            }
        }
        else {
            $outputString = "$($user.UPN) does not exist, will not be created so cannot be added to $($group.DistinguishedName)"
            if ($this.StringContent.ContainsKey($outputString) -eq $false) {
                $this.StringContent.Add($outputString, $true)
    
                Write-Color $outputString -Color Magenta
            }
        }
    }

    RemoveGroupMemberFromG($groupMember, [ADGroup] $group) {
        $outputString = "`t`tREMOVE GROUP $($groupMember.DistinguishedName) FROM GROUP $($group.DistinguishedName)"
        if ($this.StringContent.ContainsKey($outputString) -eq $false) {
            $this.StringContent.Add($outputString, $true)
            Write-Color -LinesBefore 1 "`t~ Modify GROUP $($groupMember.Name) on $($groupMember.Domain.FQDN)" -Color Yellow
            Write-Color "`t`t $($groupMember.DistinguishedName)" -Color White
            Write-Color "`t`t- REMOVE GROUP $($groupMember.Name)" -Color Red
            $this.RemovedGroups += 1

            $f = {
                Write-Verbose "Attempting to remove group $($groupMember.DistinguishedName) from group $($group.DistinguishedName)"
                try {                
                    Remove-ADGroupMember -Identity $group.DistinguishedName -Members $groupMember.DistinguishedName -Confirm:$false -Server $group.Domain.DomainController -Credential $group.Domain.Credential # Remove the the groupMember AD object to the group
                    Write-Color -LinesBefore 1 "`t~ Modified Group $($group.Name) on $($group.Domain.FQDN)" -Color Yellow
                    Write-Color"`t`t$($group.DistinguishedName)" -Color White
                    Write-Color "`t`t- REMOVED GROUP $($groupMember.DistinguishedName)" -Color Red
                }
                catch {
                    Write-Color "`tx Failed to remove group $($groupMember.DistinguishedName) from group $($group.DistinguishedName):" -Color Magenta
                    Write-Color "`t$_" -Color White #Echos out the exceptions message
                    throw;
                }

            }.GetNewClosure()         
            $this.RemoveGroupMemberFromGroup += $f
        }  
    }

    AddGroupMemberToG( [ADGroup]$groupMember, [ADGroup]$group) {       
        $outputString = "ADD GROUP $($groupMember.DistinguishedName) TO GROUP $($group.DistinguishedName)"
        if ($this.StringContent.ContainsKey($outputString) -eq $false) {
            $this.StringContent.Add($outputString, $true)
            Write-Color -LinesBefore 1 "`t~ Modify Group $($group.Name) on $($group.Domain.FQDN)" -Color Yellow
            Write-Color "`t`t$($group.DistinguishedName)" -Color White
            Write-Color "`t`t+ Add Group $($groupMember.DistinguishedName)" -Color Green
            $this.AddedGroups += 1
    
            $f = {
                Write-Verbose "Attempting to add group member $($groupMember.DistinguishedName) to group $($group.DistinguishedName)"
                try {
                    $gm = Get-ADGroup -Identity $groupMember.DistinguishedName -Server $groupMember.Domain.DomainController # Get the actual AD object for the groupMember that needs to be added
                    Add-ADGroupMember -Identity $group.DistinguishedName -Members $gm -Confirm:$false -Server $group.Domain.DomainController -Credential $group.Domain.Credential # Add the the groupMember AD object to the group
                    Write-Color -LinesBefore 1 "`t~ Modified Group $($group.Name) on $($group.Domain.FQDN)" -Color Yellow
                    Write-Color "`t`t$($group.DistinguishedName)" -Color White
                    Write-Color "`t`t+ Added Group $($groupMember.DistinguishedName)" -Color Green
                        }
                catch {
                    Write-Color "`tx Failed to add group $($groupMember.DistinguishedName) to group $($group.DistinguishedName):" -Color Magenta
                    Write-Color "`t`t$_" -Color White #Echos out the exceptions message
                    throw;
                }
            }.GetNewClosure()         
            $this.AddGroupMemberToGroup += $f
        }
    }

    ApplyChanges(){
        # Creates new OUs, groups, adds and removes users to groups
        foreach ($createO in $this.CreateOU) {
            Invoke-Scriptblock $createO
        }

        foreach($createG in $this.CreateGroup){
            Invoke-Scriptblock $createG
        }

        foreach($removeG in $this.RemoveUserFromGroup){
            Invoke-Scriptblock $removeG
        }

        foreach($addU in $this.AddUserToGroup){
            Invoke-Scriptblock $addU
        }

        foreach($RemoveGM in $this.RemoveGroupMemberFromGroup){
            Invoke-Scriptblock $RemoveGM
        }

        foreach ($AddGM in $this.AddGroupMemberToGroup) {
            Invoke-Scriptblock $AddGM
        }
    }
}