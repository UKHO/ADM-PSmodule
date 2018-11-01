# UKHO.ADM

UKHO.ADM (Active Directory Management) is a powershell module that when given a configuration object of domains, groups and users and alters active directory to match that configuration object. It applies the UKHO polices for UG, GG and DL groups, so defining the group once will cause the correct groups to be created across domains.

The module has two stages "discovery" and "apply". During the "discovery" stage the module interrogates AD to discover what actions need to occur, these are displayed so users can verify the changes. The "apply" stage is where the module applies the actions it needs to take. **The actions are only applied if `-ApplyChanges $true` has been set.**

The configuration object should be stored within a file, then before invoking the module, read the file will be read and pass the resulting the object into the module call. This should have the effect of being able to store our active directory configuration within Git.

## Capabilities

- Creating OUs
- Creating new groups with AG prefix
- Adding a group to a OU
- Removing a group from a OU (See restriction below)
- Add a user to a group
- Removing a user from a group

## Restrictions

- Users are not created
- Users are only added to groups, they cannot be added directly to an OU
- For existing OUs, users added directly to the OU are not removed
- For existing OUs, any sub-OUs which exist  not needed are **not** deleted.
- Groups are not removed from the base-OU. If a group exists but isn't needed at the base-OU level, it is ignored.
- A Credential with Management Access is required for each domains OU you wish to manage

## Usage

**The account that runs this module needs to have delegated access the relevant OU to be modified and on the relevant domains.**

A full example of an configuration object and invocation is below, the configuration object needs to have three properties:

- `Settings` (Hashtable)
  - Settings allows you to set a `GroupPrefix` and `Environment` if needed.
- `Domain` (Array)
- `Users` (Hashtable)
- `OUStructure` (Array)

The `Domain.Credential` property could be provided with a `Get-Credential`, There is a function `Get-ADAccount` this currently calls `Get-Credential`, but could be backed with PMP.

```powershell
$configObject = @{
  Settings = @{
    #If you dont want either of these, leave them blank
    GroupPrefix = "SC"
    Environment = "PRD"
  }
  Domain = @( # Array of domains of where the changes should be applied to.
    @{
      Name = "subdomain"
      FQDN = "subdomain.domain.com"
      DomainController = "server1.subdomain.domain.com"
      DistinguishedName = "DC=subdomain,DC=domain,DC=com"
      Credential = Get-ADAccount "AdminAccount" #This is a mandatory property of type pscredential
    }
    @{
      Name = "subdomain2"
      FQDN = "subdomain2.domain.com"
      DomainController = "server2.subdomain2.domain.com"
      DistinguishedName = "DC=subdomain2,DC=domain,DC=com"
      IsPrimary = $true
      Credential = Get-ADAccount "AdminAccount"
    }
  )
  Users = @{
    User1 = @{
        Domain   = "subdomain.domain.com"
        UserName = "user1"
    }
    User2 = @{
        Domain   = "subdomain2.domain.com"
        UserName = "user2"
    }
    User3 = @{
        Domain   = "subdomain.domain.com"
        UserName = "user3"
    }
  }
  OUStructure = @(
    @{
      Name   = "SC"
      RootOU = "OU=ACG,OU=UPA"
      SubOUs = @( # Array of SubOUs to be under this root OU
        @{
          Name   = "DevTeam"
          Groups = @( # Array of groups to be in this OU
            @{
              Name  = "ProjectAdmins" # Name of Group
              Users = @( 
                  $configData.Users.User1 # subdomain account
                  $configData.Users.User2 # subdomain2 account
                  $configData.Users.User3 # Business domain account
              )
            }
          )
        }
      )
    }
  )
}

# Invoke the module but don't apply changes allowing the user to review.
Update-AD  $configObject

# Invoke the module and apply changes.
Update-AD $configData $true
```

## Tips

- Start small!
  - This module will generate a lot of changes in Active Directory which can make it very hard to verify the module is doing what you expect. Make the smallest possible change first, probably something like creating an OU or creating a group, ensure the change is what you wanted and then move onto the next step. Doing it all at once will make it nearly impossible to check it has been done correctly.
