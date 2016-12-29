
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


    $DriveLetterFormatted = FormatDriveLetter $DriveLetter

    # present case
    if ($Ensure -eq 'Present')
    {
        return (CheckMappedDriveExists $DriveLetterFormatted $NetworkShare)
    }
    # absent case
    else
    {
        return (-not (CheckMappedDriveExists $DriveLetterFormatted $NetworkShare))
    }
}
