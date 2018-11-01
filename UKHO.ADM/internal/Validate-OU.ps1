function Validate-OU {
    [CmdletBinding()]
    param (
        $OUConfig
    )
    begin {
        [ValidationContext]$ret = [ValidationContext]::new()
    }

    process {
        if ($OUConfig -eq $null) {
            $ret.ValidationResults += [ValidationResult]::new("OUConfig", "The OUConfigObject passed in was null. You must pass an non-null object.")      
        }
        else {
            if ([string]::IsNullOrEmpty($OUConfig.Name)) {
                $ret.ValidationResults += [ValidationResult]::new("Name", "The Name is not set for the OU {0}. It must have a value." -f $OUConfig.Name)
            }
        }
    }
    end {
        $ret
    }
}