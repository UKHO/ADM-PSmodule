$configData = $null

$configData = @{}

$items = Get-ChildItem $PSScriptRoot\Config\*
foreach($item in $items) {
    . $item.FullName
}