function Split-UserDistinguishedName {
    [CmdletBinding()]
    param(
        [string]$distinguishedName
    )

    begin {

    }
    
    process {
        $splits = $distinguishedName.Split(",")
        $CN = $splits[0].Split("=")[1];        

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