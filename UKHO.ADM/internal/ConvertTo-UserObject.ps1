function ConvertTo-UserObject {
    [CmdletBinding()]
    param(
        $UserConfig,
        [ADDomain]$Domain
    )
    begin {}
    process {
        $validation = (Validate-User -userConfig $userConfig)

        if ($validation.IsValid()) {
            $user = [ADUserAccount]::new($userConfig.UserName, $Domain)
        }
        else {
            Write-ErrorsAndTerminate -ValidationContext $validation
        }
    }
    end {
        $user
    }
}