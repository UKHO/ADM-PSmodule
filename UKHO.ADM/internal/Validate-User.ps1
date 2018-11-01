function Validate-User {
    [CmdletBinding()]
    param (
        $userConfig
    )
    begin {
        [ValidationContext]$ret = [ValidationContext]::new()
    }
    process {
        if ($UserConfig -eq $null) {
            $ret.ValidationResults += [ValidationResult]::new("UserConfig", "The UserConfigObject passed in was null. You must pass an non-null object.")      
        }
        else {
            if ([string]::IsNullOrEmpty($UserConfig.UserName)) {
                $ret.ValidationResults += [ValidationResult]::new("UserName", "The UserName is not set for the User. It must have a value.")
            }
            if ([string]::IsNullOrEmpty($UserConfig.Domain)) {
                $ret.ValidationResults += [ValidationResult]::new("Domain", "The Domain is not set for the User. It must have a value.")
            }
        }
    }
    end {
        $ret
    }
}