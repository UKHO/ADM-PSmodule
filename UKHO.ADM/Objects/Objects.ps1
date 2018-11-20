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
    }
    
    [string]$Name
    [ADUserAccount[]]$UserAccountMembers
    [ADGroup[]]$ADGroupMembers
    [string]$DistinguishedName
    [ADDomain] $Domain

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

    # UnsafeOperation and has to be done last
    [ScriptBlock[]]$AddGroupMemberToGroup
    
    CreateO([ADOrganisationalUnit] $ADOrganisationalUnit) {
        $outputString = "CREATE OU $($ADOrganisationalUnit.DistinguishedName)"
        if ($this.StringContent.ContainsKey($outputString) -eq $false) {
            $this.StringContent.Add($outputString, $true)
            Write-Host $outputString

            $f = {
                Write-Verbose "Attempting to create OU $($ADOrganisationalUnit.DistinguishedName)"
                try {
                    New-ADOrganizationalUnit $ADOrganisationalUnit.Name -Path $ADOrganisationalUnit.ParentOrganistaionalUnit -Server $ADOrganisationalUnit.Domain.DomainController -Credential $ADOrganisationalUnit.Domain.Credential
                    Write-Host "CREATED OU $($ADOrganisationalUnit.DistinguishedName)"
                }
                Catch {
                    Write-Host "Failed to create OU $($ADOrganisationalUnit.DistinguishedName) :" -ForegroundColor Red
                    Write-Host $_ -ForegroundColor Red #Echos out the exceptions message
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
            Write-Host $outputString
    
            $n = Split-GroupDistinguishedName $group.DistinguishedName
    
            $f = {
                Write-Verbose "Attempting to create group $($group.DistinguishedName)" 
                
                try {
                    New-ADGroup -Name $group.Name -GroupScope $n.GroupScope -Path $n.Path -GroupCategory "Security" -Confirm:$false -Server $Group.Domain.DomainController -Credential $Group.Domain.Credential
                    Write-Host "CREATED GROUP $($group.DistinguishedName)"
                }
                catch {
                    Write-Host "Failed to create group $($group.DistinguishedName) :" -ForegroundColor Red
                    Write-Host $_ -ForegroundColor Red #Echos out the exceptions message
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
            Write-Host $outputString
        
            $f = {
                Write-Verbose "Attempting to remove user $($user.SamAccountName) from group $($group.DistinguishedName)"
                try {
                    Remove-ADGroupMember -Identity $group.DistinguishedName -Members $user.SamAccountName -Confirm:$false -Server $group.Domain.DomainController  -Credential $group.Domain.Credential
                    Write-Host "REMOVED USER $($user.SamAccountName) FROM GROUP $($group.DistinguishedName)" 
                }
                catch {
                    Write-Host "Failed to remove user $($user.SamAccountName) from group $($group.DistinguishedName):" -ForegroundColor Red
                    Write-Host $_ -ForegroundColor Red #Echos out the exceptions message                    
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
                Write-Host $outputString
    
                $f = {
                    Write-Verbose "Attempting to add user $($user.SamAccountName) to group $($group.DistinguishedName)"
                    try {                                        
                        Add-ADGroupMember -Identity $group.DistinguishedName -Members $user.SamAccountName -Confirm:$false -Server $User.Domain.DomainController -Credential $User.Domain.Credential
                        Write-Host "ADDED USER $($user.SamAccountName) TO GROUP $($group.DistinguishedName)"
                    }
                    Catch {                
                        Write-Host "Failed to add user $($user.SamAccountName) to group $($group.DistinguishedName):" -ForegroundColor Red
                        Write-Host $_ -ForegroundColor Red #Echos out the exceptions message
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
    
                Write-Host $outputString -ForegroundColor Red
            }
        }
    }

    RemoveGroupMemberFromG($groupMember, [ADGroup] $group) {
        $outputString = "REMOVE GROUP $($groupMember.DistinguishedName) FROM GROUP $($group.DistinguishedName)"
        if ($this.StringContent.ContainsKey($outputString) -eq $false) {
            $this.StringContent.Add($outputString, $true)
            Write-Host $outputString

            $f = {
                Write-Verbose "Attempting to remove group $($groupMember.DistinguishedName) from group $($group.DistinguishedName)"
                try {                
                    Remove-ADGroupMember -Identity $group.DistinguishedName -Members $groupMember.DistinguishedName -Confirm:$false -Server $group.Domain.DomainController -Credential $group.Domain.Credential # Remove the the groupMember AD object to the group
                    Write-Host "REMOVED GROUP $($groupMember.DistinguishedName) FROM GROUP $($group.DistinguishedName)"
                }
                catch {
                    Write-Host "Failed to remove group $($groupMember.DistinguishedName) from group $($group.DistinguishedName):" -ForegroundColor Red
                    Write-Host $_ -ForegroundColor Red #Echos out the exceptions message
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
            Write-Host $outputString
    
            $f = {
                Write-Verbose "Attempting to add group member $($groupMember.DistinguishedName) to group $($group.DistinguishedName)"
                try {
                    $gm = Get-ADGroup -Identity $groupMember.DistinguishedName -Server $groupMember.Domain.DomainController # Get the actual AD object for the groupMember that needs to be added
                    Add-ADGroupMember -Identity $group.DistinguishedName -Members $gm -Confirm:$false -Server $group.Domain.DomainController -Credential $group.Domain.Credential # Add the the groupMember AD object to the group
                    Write-Host "ADDED GROUP $($groupMember.DistinguishedName) TO GROUP $($group.DistinguishedName)"
                }
                catch {
                    Write-Host "Failed to add group $($groupMember.DistinguishedName) to group $($group.DistinguishedName):" -ForegroundColor Red
                    Write-Host $_ -ForegroundColor Red #Echos out the exceptions message
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