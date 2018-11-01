# Returns the objects that need to be added to setTwo and removed from setTwo to make setTwo the same as setOne.
function Get-Differences {
    [CmdletBinding()]
    param([hashtable]$setOne, [hashtable]$setTwo)

    # If exists in setOne && not in setTwo
    #   they need to be added to the set
    # if exists in setTwo && not in setOne
    #   they need to be removed from the set
    # if in both
    #   they are correct and nothing needs to be done
    # Therefore, find the duplicates, remove them from setOne and setTwo and this gives us the changes
    begin {
        $duplicates = @()
    }
    process {
        $setOne.Keys | ForEach-Object {
            if ($setTwo.ContainsKey($_)) {
                $duplicates += $_
            }
        }
    
        foreach ($dup in $duplicates) {
            $setTwo.Remove($dup)
            $setOne.Remove($dup)
        }
    
        # We removed the duplicates from this set so these needed to be added to this set
        $toBeAdded = $setOne.Values
        # We removed the duplicates from this set so any remaining must not be needed
        $toBeRemoved = $setTwo.Values
    }
    end {
        @($toBeAdded, $toBeRemoved)    
    }
}