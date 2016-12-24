
#Define Alphafs Class Shortcuts
$DirObject = [Alphaleonis.Win32.Filesystem.Directory]
$FileObject = [Alphaleonis.Win32.Filesystem.File]
$FileinfoObject = [Alphaleonis.Win32.Filesystem.FileInfo]
$PathFSObject = [Alphaleonis.Win32.Filesystem.Path]
$PathFSFormatObject = [Alphaleonis.Win32.Filesystem.PathFormat]
$dirEnumOptionsFSObject = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]
$copyFsObject = [Alphaleonis.Win32.Filesystem.CopyOptions]
$linktype = [Alphaleonis.Win32.Filesystem.SymbolicLinkTarget]


# .ExternalHelp PSAlphafs.psm1-help.xml
function Get-LongChildItem
{
    [Alias('ldir','lgci')]
    [CmdletBinding(DefaultParameterSetName='All')]
    Param
    (
        # Specify the Path to the File or Folder
        [ValidateScript({ 
                    if( [Alphaleonis.Win32.Filesystem.Directory]::Exists($_) -or  [Alphaleonis.Win32.Filesystem.File]::Exists($_)  ) { $true}
                    Else{Write-warning ("Get-LongChildItem:`tPath '{0}' does not exist`n`n" -f $_) }
        })]
        [Parameter(Mandatory=$false,
                ValueFromPipelineByPropertyName=$true,
                ValueFromPipeline=$true,
        Position=0)]
        [String[]]
        $Path = $PWD,
        
        # Filter wildcard string 
        [Parameter(Mandatory=$false,Position=1)]   
        [String]
        $Filter = '*',        

        # Enumerate Subdirectories
        [Switch] 
        $Recurse,
        
        # Multiple string names to exclude    
        [String[] ]
        $Include,      
        
        # Multiple string names to include    
        [String[] ]
        $Exclude,            

        # Get Only Folders
        [Switch] 
        $Directory,
        
        # Get Only Files
        [Switch] 
        $File,
        
        # Get Only File or Folder Names
        [Switch] 
        $Name,

        # Dont show symbolic links 
        [Switch] 
        $SkipSymbolicLink        
                                    
   
    )    

    Begin
    {

        $dirEnumOptions = $dirEnumOptionsFSObject::ContinueOnException 
        $dirEnumOptions =  $dirEnumOptions -bor $dirEnumOptionsFSObject::BasicSearch
        $dirEnumOptions =  $dirEnumOptions -bor $dirEnumOptionsFSObject::LargeCache 

        if($PSBoundParameters.Containskey('Recurse') )
        {
             $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::Recursive 
        } 
        if($PSBoundParameters.Containskey('SkipSymbolicLink') )
        {
             $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::SkipReparsePoints 
        }             
        if($PSBoundParameters.Containskey('Directory') -and (-not($PSBoundParameters.Containskey('File'))))
        {
            $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::Folders 
        }
        if($PSBoundParameters.Containskey('file') -and (-not($PSBoundParameters.Containskey('Directory'))))
        {
            $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::Files 
        }
        if(-not($PSBoundParameters.Containskey('Directory')) -and (-not($PSBoundParameters.ContainsKey('File')) ))
        {
             $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::FilesAndFolders 
        }        
        if($PSBoundParameters.Containskey('Directory') -and $PSBoundParameters.ContainsKey('File') )
        {
             $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::FilesAndFolders 
        }  

        $dirEnumOptions = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]$dirEnumOptions
        $privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler([Alphaleonis.Win32.Security.Privilege]::Backup, $null)       
        
    }
    Process
    {
        foreach ($pItem in $Path)
        {
            
            $PathObject = New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $pItem, $PathFSFormatObject::FullPath
  
            if($PathObject.EntryInfo.IsDirectory)
            {
                $DirObject::EnumerateFileSystemEntries($pItem,$Filter,$dirEnumOptions) | 
		        ForEach-Object {
               
                    if ($include -and (-not(CompareExtension -Extension $include -Filename $PathFSObject::GetFileName($_))))
                    {
                        return
                    }
                    if ($exclude -and (CompareExtension -Extension $exclude -Filename $PathFSObject::GetFileName($_)))
                    {
                        return
                    }      
                    if($name)
                    {
                        $_.Replace($pitem,'') -replace '^\\'
                    }
                    Else
                    {
                                              
                        New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $_, $PathFSFormatObject::FullPath
                    }

                }#foreach filesystementry
            
            }#If path is a folder
            Else
            {
            
                if($Name)
                {
                    $PathObject | Select-Object -ExpandProperty Name                        
                }
                Else
                {
                    Write-Output -InputObject $PathObject
                         
                }   
                      
            }#if path is not a folder
            
        }#foreach path item
    }#Process
    end
    {
        If ($privilegeEnabler) 
        {
            $privilegeEnabler.Dispose() 
        }
    }#end
    
}#End Function



# .ExternalHelp PSAlphafs.psm1-help.xml
function Get-LongItem
{

    [CmdletBinding()]
    Param
    (
        # Specify the Path to the File or Folder
        [ValidateScript({ 
                    if( [Alphaleonis.Win32.Filesystem.Directory]::Exists($_) -or  [Alphaleonis.Win32.Filesystem.File]::Exists($_)  ) { $true}
                    Else{Write-warning ("Get-LongItem:`tPath '{0}' does not exist`n`n" -f $_) }
        })]        
        [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                ValueFromPipeline=$true,
        Position=0)]
        [String[]]
        $Path
          
    )    

    Begin
    {  
        $privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler([Alphaleonis.Win32.Security.Privilege]::Backup, $null)         
    }
    Process
    {
        foreach ($PItem in $Path)
        {
            New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $PItem, $PathFSFormatObject::FullPath
        }
        
    }#Process
    End
    {
        If ($privilegeEnabler) 
        {
            $privilegeEnabler.Dispose()
        }
    }#end    
}#End Function



# .ExternalHelp PSAlphafs.psm1-help.xml
function Rename-LongItem
{
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact = 'High')]
    Param
    (
        # The Path to the File or Folder    
        [ValidateScript({ 
                    if( [Alphaleonis.Win32.Filesystem.Directory]::Exists($_) -or  [Alphaleonis.Win32.Filesystem.File]::Exists($_)  ) { $true}
                    Else{Write-warning ("Rename-LongItem:`tPath '{0}' does not exist`n`n" -f $_) }
        })]           
        [Alias('FullName')]
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [String]
        $Path,
       
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]       
        [String]
        $NewName,
        
        [Switch]
        $Force        
        
          
    )

    Begin
    {

    }
    Process
    {       
        $Parent = $PathFSObject::GetDirectoryName($Path)
        $NewPath = $PathFSObject::Combine($Parent, $NewName) 
        $ReplaceExisting = [Alphaleonis.Win32.Filesystem.MoveOptions]::ReplaceExisting
        
        if($PSCmdlet.ShouldProcess($NewPath,"Rename File: $Path") )
        {
            if($Force)
            {
                Write-Verbose ("Rename-LongItem:`n {0} `n`t`t{1}`n" -f $Path,$NewPath)
                $DirObject::Move($Path, $NewPath,$ReplaceExisting)              
            }
            Else
            {
                if($DirObject::Exists($NewPath))
                {
                    Write-Warning ("Rename-LongItem:`tAn item with the same name already exists at '{0}'.`nUse '-Force' to overwrite" -f $NewPath)
                }
                Else
                {
                    Write-Verbose ("Rename-LongItem:`n {0} `n`t`t{1}`n" -f $Path,$NewPath)
                    $DirObject::Move($Path, $NewPath)                 
                }

            }

        }

    
    }#Process
    End
    {
    
    }

}#end function 


# .ExternalHelp PSAlphafs.psm1-help.xml
function Copy-LongItem
{
    [CmdletBinding()]
    Param
    (
        # The Path to the File or Folder
        [ValidateScript({ 
                    if( [Alphaleonis.Win32.Filesystem.Directory]::Exists($_) -or  [Alphaleonis.Win32.Filesystem.File]::Exists($_)  ) { $true}
                    Else{Write-warning ("Copy-LongItem:`tPath '{0}' does not exist`n`n" -f $_) }
        })]        
        [Alias('FullName')]
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [String]
        $Path,
       
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]       
        [String]
        $Destination,
        
        [Switch]
        $Force,

        # If the source file is a symbolic link, 
        # the destination file is also a symbolic link pointing to the same file that the source symbolic link is pointing to.
        [Switch]
        $CopySymbolicLink,

        # The copy operation is performed using unbuffered I/O, bypassing system I/O cache resources. Recommended for very large file transfers.
        [Switch]
        $NoBuffering,

        # An attempt to copy an encrypted file will succeed even if the destination copy cannot be encrypted.     
        [Switch]
        $AllowDecryptedDestination                              
    )

    Begin
    {
        $copyOptions = $copyFsObject::FailIfExists
        if($PSBoundParameters.Containskey('CopySymbolicLink') )
        {
             $copyOptions = $copyOptions -bor $copyFsObject::CopySymbolicLink
        }  
        if($PSBoundParameters.Containskey('NoBuffering') )
        {
             $copyOptions = $copyOptions -bor $copyFsObject::NoBuffering
        }  
        if($PSBoundParameters.Containskey('AllowDecryptedDestination') )
        {
             $copyOptions = $copyOptions -bor $copyFsObject::AllowDecryptedDestination
        }                       
        $copyOptions = [Alphaleonis.Win32.Filesystem.CopyOptions]$copyOptions
        $privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler([Alphaleonis.Win32.Security.Privilege]::CreateSymbolicLink, $null)
    }
    Process
    {       
        $PathObject = New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $Path, $PathFSFormatObject::FullPath
        
        $basename = $PathFSObject::GetFileName($Path)
        $dBasename = $PathFSObject::GetFileName($Destination)
        $dParent =  $PathFSObject::GetDirectoryName($Destination)
        
        $dBasenameObj = New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $dBasename
        $isFile = if($PathFSObject::HasExtension($dBasename) ){$true}else {$false} 
        
        # Create the directory tree before the copy
        if($isFile)
        {
            $Destination_isFile = $true
            if( -not ( $DirObject::Exists($dParent)))
            {
                $DirObject::CreateDirectory($dParent) | Out-Null
            } 
            
        }#destination is a file
        Else
        {
            $Destination_isDirectory = $true
            if( -not ( $DirObject::Exists($Destination)))
            {
                $DirObject::CreateDirectory($Destination) | Out-Null
            } 
            Else
            {
                $Destination = $PathFSObject::Combine($Destination, $basename) 
                
            }
                                   
        }#destination is a folder
        

                 
        if($Force){$Overwrite = $true}else{$Overwrite = $false }
        if($PathObject.EntryInfo.IsDirectory)
        {
            $fsObject = $DirObject
        }
        else
        {
            $fsObject = $FileObject
        }    

        # Perform the copy     
        try
        {
            $fsObject::Copy($Path, $destination,$copyOptions)
        }
        catch [Alphaleonis.Win32.Filesystem.AlreadyExistsException]
        {
            if($Force)
            {
                # need to delete destination because the copy method dosent contain an overload that includes
                # both the overwrite and copyoptions parameters
                $DirObject::Delete($destination, $true, $true, $PathFSFormatObject::FullPath) 

                Write-Verbose ("Copy-LongItem:`t Overwriting existing item...Copying '{0}' to '{1}'" -f $Path,$Destination)
                $fsObject::Copy($Path, $Destination, $copyOptions)               
            }
            Else
            {
                Write-Warning ("Copy-LongItem:`tAn item with the same name already exists at '{0}'.`nUse '-Force' to overwrite" -f $Destination)                 
            }                  
    
        }
        Catch
        {
            throw $_
        }
    
        
        

    }#Process
    End
    {
        If ($privilegeEnabler) 
        {
            $privilegeEnabler.Dispose() 
        }    
    }

}#end function 


# .ExternalHelp PSAlphafs.psm1-help.xml
function Remove-LongItem
{
    [CmdletBinding()]
    Param
    (
        # The Path to the File or Folder
        [ValidateScript({ 
                    if( [Alphaleonis.Win32.Filesystem.Directory]::Exists($_) -or  [Alphaleonis.Win32.Filesystem.File]::Exists($_)  ) { $true}
                    Else{Write-warning ("Remove-LongItem:`tPath '{0}' does not exist`n`n" -f $_) }
        })]         
        [Alias('FullName')]
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [String]
        $Path,
            
        [Switch]
        $Recurse,
        
        [Switch]
        $Force                  
    )

    Begin
    {

        $DirOptions = $dirEnumOptionsFSObject::FilesAndFolders
        $privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler([Alphaleonis.Win32.Security.Privilege]::Backup, $null)       
        
    }
    Process
    {       
        $PathObject = New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $Path

        
  
        if($Recurse){$RemoveAll = $true;$Force = $true}else{$RemoveAll = $false }
        if($Force){$IgnoreReadOnly = $true}else{$IgnoreReadOnly = $false }
            
        if($PathObject.EntryInfo.IsDirectory)
        {
            if($Recurse)
            {
                Write-Verbose ("Remove-LongItem:`t Deleting directory '{0}' recursively" -f $Path)
                $DirObject::Delete($Path, $RemoveAll, $IgnoreReadOnly, $PathFSFormatObject::FullPath)            
            }
            Else
            {
                if( $DirObject::CountFileSystemObjects($path,$DirOptions) -gt 0)
                {
                    Write-Warning ("Remove-LongItem:`t The Directory '{0}' is not Empty.`nUse '-Recurse' to remove it." -f $Path)               
                }
                Else
                {
                    Write-Verbose ("Remove-LongItem:`t Deleting empty directory '{0}'" -f $Path)
                    $DirObject::Delete($Path, $RemoveAll, $IgnoreReadOnly, $PathFSFormatObject::FullPath)                
                }
            
            
            }#if not recurse 
                 
        }
        Else
        {           
             try
             {
                 Write-Verbose ("Remove-LongItem:`t Deleting file '{0}'..." -f $Path)
                 $FileObject::Delete($Path, $IgnoreReadOnly, $PathFSFormatObject::FullPath)  
             }
             catch [Alphaleonis.Win32.Filesystem.FileReadOnlyException]
             {
                 Write-Warning ("Remove-LongItem:`t The file '{0}' is ReadOnly.`nUse '-Force' to remove it." -f $Path)               
             }
             catch
             {
                 throw $_
             }

                
        }#If file        
            

    }#Process
    End
    {
        If ($privilegeEnabler) 
        {
            $privilegeEnabler.Dispose()
        }    
    }

}#end function 


# .ExternalHelp PSAlphafs.psm1-help.xml
function New-LongItem
{
	[CmdletBinding(DefaultParameterSetName = 'Path')]
	Param
	(
		# The Path to the File or Folder
		[Parameter(Mandatory,
				ValueFromPipelineByPropertyName,
				ValueFromPipeline,ParameterSetName = 'Path',
			 Position=0)]
		[String[]]
		[Parameter(ParameterSetName = 'Name')]
		$Path,
          
		
		[Alias('Type')]
		[ValidateSet('Directory','File','SymbolicLink','HardLink')]
		[String]
		$ItemType,
		
		[Alias('Target')]
		[Parameter()]
		$Value,
		
		[ValidateSet('ASCII','BigEndianUnicode','Unicode','UTF32','UTF7','UTF8')]
		[Parameter()]
		[String]
		$Encoding = 'Default',		
		
		[Alias('LinkName')]		
		[Parameter(Mandatory,ParameterSetName = 'Name')]
		[String]
		$Name,
        
		[Switch]
		$Force                  
	)

	Begin
	{
	
		$privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler -ArgumentList ([Alphaleonis.Win32.Security.Privilege]::CreateSymbolicLink, $null)  

	}
	Process
	{       

		if($Path)
		{
		
		
			foreach ($pItem in $Path)
			{
		
				if($PSCmdlet.ParameterSetName -eq 'Path')
				{
					if(-not [Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($pItem))
					{
						$pItem = $PathFSObject::Combine($pwd, $pItem)
					}
				
					$FilePath = $pItem
				
				}# pscmdlet Path
			
				if($PSCmdlet.ParameterSetName -eq 'Name')
				{
				
					if($PathFSObject::IsPathRooted($Name) -and $PathFSObject::IsPathRooted($pItem))
					{
						Write-Warning ("New-LongItem: The given path's format is not supported")
						break
					}
				

					elseif([Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($pItem))
					{
						  $filepath =$PathFSObject::Combine($pItem, $Name)
					}
					Else
					{
						  $filepath =$PathFSObject::Combine($pwd, $pItem, $Name)
					}
										

				}#pscmdlet is Name	

		
				newlongitemhelper -Filename $FilePath -itemtype $ItemType -value $Value -Encoding $Encoding

        

        
        
			}#foreach pitem
		}# if path
		Else
		{

			
				if($PSCmdlet.ParameterSetName -eq 'Name')
				{
				
					  if([Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($Name))
					  {
							$FilePath = $Name
					  }
					  Else
					  {
							$filepath =$PathFSObject::Combine($pwd, $Name)
					  }	
									

				}#pscmdlet is Name	

				newlongitemhelper -Filename $FilePath -itemtype $ItemType -value $Value -Encoding $Encoding
				
				
		
		
		}# if path is not specified            

	}#Process
	End
	{
		If ($privilegeEnabler) 
		{
			$privilegeEnabler.Dispose() 
		}    
	}

}#end function 



# .ExternalHelp PSAlphafs.psm1-help.xml
function Move-LongItem
{
    [CmdletBinding()]
    Param
    (
        # The Path to the File or Folder    
        [ValidateScript({ 
                    if( [Alphaleonis.Win32.Filesystem.Directory]::Exists($_) -or  [Alphaleonis.Win32.Filesystem.File]::Exists($_)  ) { $true}
                    Else{Write-warning ("Rename-LongItem:`tPath '{0}' does not exist`n`n" -f $_) }
        })]           
        [Alias('FullName')]
        [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                ValueFromPipeline=$true,
        Position=0)]
        [String]
        $Path,
       
        [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
        Position=1)]       
        [String]
        $Destination,
        
        [Switch]
        $Force        
        
          
    )

    Begin
    {
        $ReplaceExisting = [Alphaleonis.Win32.Filesystem.MoveOptions]::ReplaceExisting
    }
    Process
    {       
        $Parent = $PathFSObject::GetDirectoryName($Path)
        $basename = $PathFSObject::GetFileName($Path)
        $dParent = $PathFSObject::GetDirectoryName($Destination)
        $dBasename = $PathFSObject::GetFileName($Destination)

        $isFile = if($PathFSObject::HasExtension($Basename) ){$true}else {$false} 
        $isFile_destination = if($PathFSObject::HasExtension($dBasename) ){$true}else {$false} 
        
        if($isFile)
        {
            #Basename is a file so destination has to be a file
            $Basename_isFile = $true
            
            if ($isFile_destination)
            {
                $Destination_isFile = $true
                $NewPath = $Destination 
            }            
            Else
            {
                $Destination_isDirectory = $true
                $NewPath = $PathFSObject::Combine($Destination, $basename)
            }            
        }#basename is file
        Else
        {
            #basename is a folder so check the destination basename
            $Basename_isDirectory = $true
            if ($isFile_destination)
            {
                Write-Warning ("Move-LongItem:`tThe source is a directory so please specify a directory as the destination")
                break

            }            
            Else
            {
                
                $Destination_isDirectory = $true

                if($DirObject::Exists($Destination ))
                {
                    $NewPath = $PathFSObject::Combine($destination, $basename) 
                }
                Else
                {
                    $NewPath = $Destination
                }
                               
            }# destination is a directory             
            
        }#basename is a directory
        
        


        if($Path -ne $NewPath)
        {
            
            if ($Basename_isFile)
            {
                $Object = $FileObject
            }
            Elseif($Basename_isDirectory)
            {
                $Object = $DirectoryObject
            }
                
            if($Force)
            {
                Write-Verbose ("Move-LongItem:`n {0} `n`t`t{1}`n" -f $Path,$NewPath)
                $Object::Move($Path, $NewPath,$ReplaceExisting)              
            }
            Else
            {
            
                try
                {
                    Write-Verbose ("Move-LongItem:`n {0} `n`t`t{1}`n" -f $Path,$NewPath)
                    $Object::move($path,$NewPath)
                }
                catch [Alphaleonis.Win32.Filesystem.AlreadyExistsException]
                {
                    Write-Warning ("Move-LongItem:`tAn item named '{0}' already exists at the destination.`nUse '-Force' to overwrite" -f $NewPath)
                }
                Catch
                {
                    throw $_
                }
        
            }#no force
        }
        Else
        {
            Write-Warning ("Move-LongItem:`tAn item cannot be moved to a destination that is same as the source")
        }
                
        
    
    }#Process
    End
    {
    
    }

}#end function 

function Mount-LongShare
{

	[CmdletBinding(DefaultParameterSetName = 'Simple')]
	Param
	(
		# Specify the Local Drive the NetworkShare is to be Mapped to          
		[Parameter(Mandatory=$true,
				ValueFromPipelineByPropertyName=$true,
		Position=0)]
		[String]
		$DriveLetter,
		
		# Specify the NetworkShare that is to be mapped   
		[Parameter(Mandatory=$true,
				ValueFromPipelineByPropertyName=$true,
		Position=1)]
		[String]
		$NetWorkShare,
		
		# Specify the NetworkShare that is to be mapped   
		[Parameter(Mandatory=$true,
				ValueFromPipelineByPropertyName=$true,
				ParameterSetName = 'Credential',
		Position=2)]
		[System.Management.Automation.PSCredential]
		$Credential
		
			
				
          
	)    

	Begin
	{
     
	}
	Process
	{
		if($DriveLetter -notmatch '[aA-zZ]:'){$DriveLetter = "$DriveLetter`:"}
		
		if($PSCmdlet.ParameterSetName -eq 'Credential')
		{
			$NetWorkCreds = New-Object System.Net.NetworkCredential -ArgumentList @($Credential.UserName, $Credential.Password)
			$Domain = $Credential.GetNetworkCredential().domain
			
			if($Domain)
			{
				$NetWorkCreds.Domain = $Domain
			}

			#map drive
			try
			{
				Write-Verbose ("Mount-LongShare:`t Mapping NetWorkShare ['{0}'] to DriveLetter ['{1}'] with Credentials '[{2}']" -f $NetWorkShare,$DriveLetter, $Credential.UserName)
				$MapDrive = [Alphaleonis.Win32.Network.Host]::ConnectDrive($DriveLetter, $NetWorkShare, $Credential, $false, $true, $true)
			
			}
			catch
			{
				throw $_.exception.innerexception	 
			}
			
			
			
		}# Parameterset Credential
		
		if($PSCmdlet.ParameterSetName -eq 'Simple')
		{
			#map drive
			try
			{
				Write-Verbose ("Mount-LongShare:`t Mapping NetWorkShare ['{0}'] to DriveLetter ['{1}']" -f $NetWorkShare,$DriveLetter)
				$MapDrive = [Alphaleonis.Win32.Network.Host]::ConnectDrive($DriveLetter, $NetWorkShare)
			
			}
			catch
			{

				throw $_.exception.innerexception
				 
			}
			
		}# Parameterset Simple
        
	}#Process
	End
	{

	}#end    
}#End Function


function DisMount-LongShare
{

	[CmdletBinding()]
	Param
	(
		# Specify the Local Drive the NetworkShare is to be Mapped to    
		[Parameter(Mandatory=$true,
				ValueFromPipelineByPropertyName=$true,
				ValueFromPipeline = $true,
		Position=0)]
		[String]
		$DriveLetter,
		
		# Specify if the existing Connections to a share are to be closed
		[Switch]
		$Force
      
	)    

	Begin
	{
     
	}
	Process
	{
		if($DriveLetter -notmatch '[aA-zZ]:'){$DriveLetter = "$DriveLetter`:"}
					
		#map drive
		try
		{

			if($Force)
			{
				 
				Write-Verbose ("DisMount-LongShare:`t Force Detected...Closing open network connections and Removing Mapped Drive ['{0}']" -f $DriveLetter)
				$RemoveDrive = [Alphaleonis.Win32.Network.Host]::DisconnectDrive($DriveLetter, $true, $true)
			}
			Else
			{
				Write-Verbose ("DisMount-LongShare:`t Removing Mapped Drive ['{0}']" -f $DriveLetter)   
				$RemoveDrive = [Alphaleonis.Win32.Network.Host]::DisconnectDrive($DriveLetter, $false, $true)
			}
			
		}
		catch
		{
			  if($_.Exception.InnerException -match 'This network connection has files open or requests pending')
			  {
					throw 'This network connection has files open or requests pending...use the "-Force" switch to close existing connections without warning'
			  }
			  else
			  {
					throw $_.Exception.InnerException
			  }

		}
			
	   
	}#Process
	End
	{

	}#end    
}#End Function


function Get-LongMappedDrive
{

	[CmdletBinding()]
	Param
	(   
	)    

	Begin
	{
     
	}
	Process
	{
					
		#map drive
		try
		{

			  [Alphaleonis.Win32.Filesystem.DriveInfo]::GetDrives() | Where-Object DriveType -eq 'Network'
			
		}
		catch
		{

			 throw $_.Exception.InnerException
			  
		}
			
		
        
	}#Process
	End
	{

	}#end    
}#End Function

function Get-LongFreeDriveLetter
{

	[CmdletBinding(DefaultParameterSetName = 'First')]
	Param
	(  
		# get the last available drive letter.   
		[Parameter(ParameterSetName = 'Last')]
		[Switch]
		$Last	 
	)    

	Begin
	{
     
	}
	Process
	{
					
		if($PSCmdlet.ParameterSetName -eq 'First')
		{
			#map drive
			try
			{
				Write-Verbose ("Get-FreeDriveLetter:`t Listing the first free DriveLetter")
				[Alphaleonis.Win32.Filesystem.DriveInfo]::GetFreeDriveLetter()
			
			}
			catch
			{

				throw $_.exception.innerexception
				 
			}
			
		}# Parameterset First
		
		if($PSCmdlet.ParameterSetName -eq 'Last')
		{
			#map drive
			try
			{
				Write-Verbose ("Get-FreeDriveLetter:`t Listing the Last free DriveLetter")
				[Alphaleonis.Win32.Filesystem.DriveInfo]::GetFreeDriveLetter($true)
			
			}
			catch
			{

				throw $_.exception.innerexception
				 
			}
			
		}# Parameterset Last		
			
		
        
	}#Process
	End
	{

	}#end    
}#End Function

function Get-LongDiskDrive
{

	[CmdletBinding()]
	Param
	(   
	)    

	Begin
	{
     
	}
	Process
	{
					
		#List drive
		try
		{

			  [Alphaleonis.Win32.Filesystem.DriveInfo]::GetDrives()
			
		}
		catch
		{

			 throw $_.Exception.InnerException
			  
		}
			
		
        
	}#Process
	End
	{

	}#end    
}#End Function


function Get-LongDirectorySize
{

    [CmdletBinding()]
    Param
    (
        # Specify the Path to a Folder
        [ValidateScript({ 
                    if( [Alphaleonis.Win32.Filesystem.Directory]::Exists($_) ) { $true}
                    Else{Write-warning ("Get-LongDirectorySize:`tDirectory '{0}' does not exist`n`n" -f $_) }
        })]        
        [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                ValueFromPipeline=$true,
        Position=0)]
        [String]
        $Path,

        # Enumerate Subdirectories
        [Switch] 
        $Recurse,

        # Enumerate Subdirectories
        [Switch] 
        $ContinueonError                
          
    )    

    Begin
    {  
        $privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler([Alphaleonis.Win32.Security.Privilege]::Backup, $null)
        $dirEnumOptions = $dirEnumOptionsFSObject::SkipReparsePoints 

        if($PSBoundParameters.Containskey('Recurse') )
        {
             $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::Recursive 
        } 
        if($PSBoundParameters.Containskey('ContinueonError') )
        {
             $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::ContinueOnException 
        }         
        $dirEnumOptions = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]$dirEnumOptions 
    }
    Process
    {

            $ResultHash = $DirObject::GetProperties( $Path, $dirEnumOptions, $PathFSFormatObject::FullPath)
            $size = $ResultHash.Size
            
            if($size)
            {
                $postfixes = @( "Bytes", "KB", "MB", "GB", "TB", "PB" )
                for ($i=0; $size -ge 1024 -and $i -lt $postfixes.Length - 1; $i++) 
                { 
                    $size = $size / 1024
                }
                $rounded_size = [System.Math]::Round($size,2)
                $ResultHash.Add("Sizein$($postfixes[$i])", $rounded_size) | Out-Null
                Write-Verbose ("The size of the folder '{0}' is '{1} {2}'" -f $Path,$rounded_size, $postfixes[$i])
                
            }
            Write-Output $ResultHash


        
        
    }#Process
    End
    {
        If ($privilegeEnabler) 
        {
            $privilegeEnabler.Dispose()
        }
    }#end    
}#End Function

#Export-ModuleMember *
#Export-ModuleMember -Alias ldir,lgci -Function Get-LongChildItem
#Set-Alias -Name ldir -Value Get-LongChildItem
#Set-Alias -Name lgci -Value Get-LongChildItem

