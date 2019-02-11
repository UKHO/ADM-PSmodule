function Update-AD {
    [CmdletBinding()]
    param(
        $cd,
        [bool]$ApplyChanges = $false
    )
    begin {}
    process {
        Write-Colour -LinesBefore 1 "Actions are indicated with the following symbols:" -Color White
        Write-Colour -StartTab 1 "+", " adding or creating" -Color Green, White
        Write-Colour -StartTab 1 "-", " removing or deleting" -Color Red, White
        Write-Colour -StartTab 1 "~", " modification or change" -Color Yellow, White
        Write-Colour -StartTab 1 "x", " errors have occurred"  -Color Magenta, White

        $out = Generate-ConfigurationObject -ConfigData $cd 

        Write-Colour -LinesBefore 1 "UKHO.ADM will perform the following changes:" -Color Blue

        $ADChanges = Get-ADChanges($out)

        Write-Colour -LinesBefore 1 "Change Summary:" -Color Gray
        Write-Colour -StartTab 1 "Created OU: $($ADChanges.CreatedOUs)" -Color Gray
        Write-Colour -StartTab 1 "Created Groups: $($ADChanges.CreatedGroups)" -Color Gray
        Write-Colour -StartTab 1 "Added Groups: $($ADChanges.AddedGroups)" -Color Gray
        Write-Colour -StartTab 1 "Removed Groups: $($ADChanges.RemovedGroups)" -Color Gray
        Write-Colour -StartTab 1 "Removed Users: $($ADChanges.RemovedUsers)" -Color Gray
        Write-Colour -StartTab 1 "Added Users: $($ADChanges.AddedUsers)" -Color Gray

        if ($ApplyChanges) {

            Write-Colour -LinesBefore 4 "UKHO.ADM will now apply the changes" -Color Blue

            $ADChanges.ApplyChanges()        
        }
    }
    end {}
}