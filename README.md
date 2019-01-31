# UKHO.ADM

UKHO.ADM (Active Directory Management) is a powershell module that when given a configuration object of domains, groups and users and alters active directory to match that configuration object. It applies the UKHO polices for UG, GG and DL groups, so defining the group once will cause the correct groups to be created across domains.

The module has two stages "discovery" and "apply". During the "discovery" stage the module interrogates AD to discover what actions need to occur, these are displayed so users can verify the changes. The "apply" stage is where the module applies the actions it needs to take. **The actions are only applied if `-ApplyChanges $true` has been set.**

The configuration object should be stored within a file, then before invoking the module, read the file will be read and pass the resulting the object into the module call. This should have the effect of being able to store our active directory configuration within Git.

## Requirements

### RSAT-Powershell Windows Feature

The UKHO.ADM module uses RSAT-PowerShell functions. These functions are only available after installing [RSAT](https://support.microsoft.com/en-gb/help/2693643/remote-server-administration-tools-rsat-for-windows-operating-systems) and cannot be downloaded from PsGallery.

#### Install RSAT on a Windows Server

```powershell
Add-WindowsFeature RSAT-AD-PowerShell
```

#### Install RSAT on a Windows Desktop

Install relevant version for your [Windows Desktop version](https://support.microsoft.com/en-gb/help/2693643/remote-server-administration-tools-rsat-for-windows-operating-systems).

for Windows 10, [you can install from a KB](https://www.microsoft.com/en-gb/download/details.aspx?id=45520)

## Capabilities

- Creating OUs
- Creating new groups with AG prefix
- Adding a group to a OU
- Removing a group from a OU (See restriction below)
- Add a user to a group
- Removing a user from a group
- Adding existing group, a group outside of the current ADM process, to a group

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
- `Groups` (Hashtable)
  - Groups are ADGroups that exist enternally to the `$configData`
  - You are require to add the `DistinguishedName` of the ADGroup you wish to link
- `OUStructure` (Array)

The `Domain.Credential` property could be provided with a `Get-Credential`.

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
      Credential = Get-Credential "AdminAccount" #This is a mandatory property of type pscredential
    }
    @{
      Name = "subdomain2"
      FQDN = "subdomain2.domain.com"
      DomainController = "server2.subdomain2.domain.com"
      DistinguishedName = "DC=subdomain2,DC=domain,DC=com"
      IsPrimary = $true
      Credential = Get-Credential
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
  Groups = @{
    Group1 = @{
      # Find the account you were interested in, copy the distinguishedName, which includes the DC identity
      DistinguishedName = "CN=GroupName,OU=OtherACG,OU=UPA,DC=subdomain2,DC=domain,DC=com"
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
                  $configData.Users.User3 # subdomain account
              )
              Groups = @(
                $configData.Groups.Group1
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

## Security Disclosure

The UK Hydrographic Office (UKHO) collects and supplies hydrographic and geospatial data for the merchant shipping and the Royal Navy, to protect lives at sea. Maintaining the confidentially, integrity and availability of our services is paramount. Found a security bug? You might be saving a life by reporting it to us at UKHO-ITSO@ukho.gov.uk
