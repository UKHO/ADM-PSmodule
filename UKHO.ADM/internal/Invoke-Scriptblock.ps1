# Invokes a scriptblock and if an exception is thrown applies an expectional backoff a set number of times (5 by default)
function Invoke-Scriptblock {
    [CmdletBinding()]
    param([scriptblock] $sb, 
        $totalAttempts = 5, 
        $attemptCount = 0
    )
    begin {}
    process {
        if ( $attemptCount -eq $totalAttempts + 1) {
            return;
        }

        if ( $attemptCount -ne 0) {
            $sleepingTime = [Math]::Pow(2, $attemptCount);
            Write-Host "Sleeping for $sleepingTime seconds and retrying last action. Attempt $attemptCount of $totalAttempts." -ForegroundColor DarkGray
            Start-Sleep -Seconds $sleepingTime;
        }    

        try {
            & $sb
            if ($attemptCount -ne 0) {
                Write-Host "Retrying caused action above to complete successfully" -ForegroundColor DarkGray
            }
        }
        catch {        
            $attemptCount++;
            Invoke-Scriptblock -sb $sb -attemptCount $attemptCount;
        }
    }
    end {}
}