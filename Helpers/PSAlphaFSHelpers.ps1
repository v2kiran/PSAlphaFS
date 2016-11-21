function CompareExtension([string[]]$Extension, $Filename)
{
    foreach ($p in $Extension)
    {
        $wc = New-Object System.Management.Automation.WildcardPattern -ArgumentList ($p, [System.Management.Automation.WildcardOptions]::IgnoreCase) 
        if ($wc.IsMatch($Filename)) {return $true}
    }
    
}