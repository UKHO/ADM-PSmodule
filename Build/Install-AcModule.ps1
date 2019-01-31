function Install-AcModule 
{
	[CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true)]
    [string]
    $ModuleName,
    [Parameter(Mandatory=$true)]
    $ModuleVersion
)
begin {}
process {
    if(((Get-Module -ListAvailable -Name $ModuleName) | Where-Object {$_.Version.ToString() -eq $ModuleVersion}) -eq $null)
    {
        Write-Host "Module $ModuleName ver.$ModuleVersion not installed on node. Installing..."
        try
        {            
            Install-Module -Name $ModuleName -RequiredVersion $ModuleVersion -SkipPublisherCheck -Force
            Write-Host "Module $ModuleName installation complete."
        }
        catch
        {
            Write-Error -Exception $_.Exception -Message "Module $ModuleName ver.$ModuleVersion failed to install."
        } 
    }
    else
    {
        Write-Host "Module $ModuleName already installed."
    }
}
end {}
}