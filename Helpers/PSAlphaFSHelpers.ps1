Function GetDotNetVer {
    #https://gallery.technet.microsoft.com/scriptcenter/Detect-NET-Framework-120ec923
    #modified to work with this module
    $dotNetRegistry  = 'SOFTWARE\Microsoft\NET Framework Setup\NDP'
    $dotNet4Registry = 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    $dotNet4Builds = 
    @{
      30319  = '4.0'
      378389 = '4.5'
      378675 = '4.5.1'
      378758 = '4.5.1'
      379893 = '4.5.2'
      380042 = '4.5'
      393295 = '4.6'
      393297 = '4.6'
      394254 = '4.6.1'
      394271 = '4.6.1'
      394802 = '4.6.2'
      394806 = '4.6.2'
    }



  if($regKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Default')) 
  {
      if ($netRegKey = $regKey.OpenSubKey($dotNetRegistry)) {
        foreach ($versionKeyName in $netRegKey.GetSubKeyNames()) 
        {
          if ($versionKeyName -match '^v[123]') 
          {
            $versionKey = $netRegKey.OpenSubKey($versionKeyName)
            $version = [version]($versionKey.GetValue('Version', ''))
            '{0}.{1}' -f $version.Major,$version.minor
          }
        }
      }

      if ($net4RegKey = $regKey.OpenSubKey($dotNet4Registry)) 
      {
        if(-not ($net4Release = $net4RegKey.GetValue('Release'))) 
        {
          $net4Release = 30319
        }
        $dotNet4Builds[$net4Release]

      }
  }#open reg key


  }#end function
  

$installed_dotnetversion = GetDotNetVer | sort -Descending | Select-Object -First 1
$libpath_parent = join-path (Split-Path $PSScriptRoot -Parent) -ChildPath lib

switch($installed_dotnetversion)
{
    '3.5'    {$libpath = Join-Path $libpath_parent -ChildPath 'net35\AlphaFS.dll';break}
    '4.0'    {$libpath = Join-Path $libpath_parent -ChildPath 'net40\AlphaFS.dll';break}
    '4.5.0'  {$libpath = Join-Path $libpath_parent -ChildPath 'net45\AlphaFS.dll';break}
    '4.5.1'  {$libpath = Join-Path $libpath_parent -ChildPath 'net451\AlphaFS.dll';break}
    '4.5.2'  {$libpath = Join-Path $libpath_parent -ChildPath 'net452\AlphaFS.dll';break}
    '4.6.1'  {$libpath = Join-Path $libpath_parent -ChildPath 'net452\AlphaFS.dll';break}
    '4.6.2'  {$libpath = Join-Path $libpath_parent -ChildPath 'net452\AlphaFS.dll';break}
    default  {$libpath = Join-Path $libpath_parent -ChildPath 'net40\AlphaFS.dll'}
}

Write-Verbose "Highest installed version of dot net:`t$installed_dotnetversion"
# Load the AlphaFS assembly
Add-Type -Path $libpath


# function to match file extensions
function CompareExtension([string[]]$Extension, $Filename)
{
    foreach ($p in $Extension)
    {
        $wc = New-Object System.Management.Automation.WildcardPattern -ArgumentList ($p, [System.Management.Automation.WildcardOptions]::IgnoreCase) 
        if ($wc.IsMatch($Filename)) {return $true}
    }
    
}

