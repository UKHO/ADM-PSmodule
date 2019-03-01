function Split-UserDistinguishedName {
    [CmdletBinding()]
    param(
        [string]$distinguishedName
    )

    begin {

    }
    
    process {
        $splits = $distinguishedName.Split(",")
        
        $splits | ForEach-Object -begin {$CN = ""} -process { 
            $split = $_
            if($split -like "CN=*") {
                $seq = $split.Split("=")[1];
                if($CN -eq "") {
                    $CN = $seq
                }             
                else {          
                    $CN += ".$seq"
                }
            }        
        }

        $splits | ForEach-Object -begin {$DC = ""} -process { 
            $split = $_
            if($split -like "DC=*") {
                $seq = $split.Split("=")[1];
                if($DC -eq "") {
                    $DC = $seq
                }             
                else {          
                    $DC += ".$seq"
                }
            }        
        }
    }

    end {
        @{"CN" = $CN; "DC" = $DC; }
    }
}