function Write-ErrorsAndTerminate {
    [CmdletBinding()]
    param(
        [ValidationContext]$ValidationContext
    )
    begin {}
    process {
        $ValidationContext.ValidationResults | ForEach-Object {
            Write-Warning ("{0} - {1}" -f $_.PropertyName, $_.Message)
        }
        Throw "Errors occurred. Terminating."
    }
    end {}
}