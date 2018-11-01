<#
.SYNOPSIS
Gets AD Management Account

.DESCRIPTION
Gets AD Management account for modifications in a domain

.PARAMETER UserName
Username to use

.EXAMPLE
Get-AdManagementAccount -UserName "Domain\User"
#>

function Get-ADAccount {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $UserName
    )
    
    begin {
    }
    
    process {
        Get-Credential $UserName
    }
    
    end {
    }
}