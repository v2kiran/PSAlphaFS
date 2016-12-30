
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $DriveLetter,
        
        [Parameter(Mandatory=$true)]
        [string]
        $NetworkShare,

        [Parameter()]
        [PSCredential]
        $Credential,    

        [Switch]
        $Force,  

        [Bool]
        $isMappedDrivePresent,                    
        
        [ValidateSet('Present','Absent')]
        [string]
        $Ensure = 'Present'
    )



    $MapDriveHash = New-Object System.Collections.Hashtable
    $null = $MapDriveHash.Add('DriveLetter',$DriveLetter)
    $null = $MapDriveHash.Add('NetworkShare',$NetworkShare)
    $DriveLetterFormatted = FormatDriveLetter $DriveLetter
    if (CheckMappedDriveExists $DriveLetterFormatted $NetworkShare) 
    {     
        $MapDriveHash.Add('isMappedDrivePresent',$true)
    } 
    else 
    {
        $MapDriveHash.Add('isMappedDrivePresent',$false)
    }
    return $MapDriveHash

}


function Set-TargetResource
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $DriveLetter,
        
        [Parameter(Mandatory=$true)]
        [string]
        $NetworkShare,

        [Parameter()]
        [PSCredential]
        $Credential,    

        [Switch]
        $Force,  

        [Bool]
        $isMappedDrivePresent,                    
        
        [ValidateSet('Present','Absent')]
        [string]
        $Ensure = 'Present'
    )


    $params = 
    @{
        DriveLetter = (FormatDriveLetter $DriveLetter)
        NetworkShare = $NetworkShare
        Ensure = $Ensure
        Verbose = $true
    }

    if($Credential) {$params.Add('Credential', $Credential)}
    if($Force) {$params.Add('Force', $Force)}

    if ($Ensure -eq 'Present')
    {
        'Force','Ensure' | ForEach-Object {$null = $params.Remove($_)}
        Mount-LongShare @Params
    }
    else
    {
        'Credential','NetworkShare','Ensure' | ForEach-Object {$null = $params.Remove($_)}
        DisMount-LongShare @Params
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $DriveLetter,
        
        [Parameter(Mandatory=$true)]
        [string]
        $NetworkShare,

        [Parameter()]
        [PSCredential]
        $Credential,    

        [Switch]
        $Force,  

        [Bool]
        $isMappedDrivePresent,                    
        
        [ValidateSet('Present','Absent')]
        [string]
        $Ensure = 'Present'
    )


    $DriveLetter = FormatDriveLetter $DriveLetter

    # present case
    if ($Ensure -eq 'Present')
    {
        if( (Test-Path $DriveLetter) -and (CheckMappedDriveExists $DriveLetter $NetworkShare)  )
        {
            return $true
        }
        else 
        {
            return $false    
        }
        
    }
    else     # absent case
    {
        if( (Test-Path $DriveLetter) -and (CheckMappedDriveExists $DriveLetter $NetworkShare)  )
        {
            return $false
        }
        else 
        {
            return $true    
        }
    }
}
