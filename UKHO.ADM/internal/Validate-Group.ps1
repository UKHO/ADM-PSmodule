function Validate-Group {
    [CmdletBinding()]
    param (
        $GroupConfig
    )
    begin {
        [ValidationContext]$ret = [ValidationContext]::new()
    }
    process {

        if ($GroupConfig -eq $null) {
            $ret.ValidationResults += [ValidationResult]::new("GroupConfig", "The GroupConfigObject passed in was null. You must pass an non-null object.")      
        }
        else {
            if ([string]::IsNullOrEmpty($GroupConfig.Name)) {
                $ret.ValidationResults += [ValidationResult]::new("Name", "The Name is not set for the Group {0}. It must have a value." -f $GroupConfig.Name)
            }        
        }
    }
    end {
        $ret
    }
}