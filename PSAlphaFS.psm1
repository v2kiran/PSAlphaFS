
# .ExternalHelp PSAlphafs.psm1-help.xml
function Get-LongChildItem
{

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
        $Name
                                    
   
    )    

    Begin
    {
        $DirObject = [Alphaleonis.Win32.Filesystem.Directory]

        $dirEnumOptions = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::ContinueOnException 
        $dirEnumOptions =  $dirEnumOptions -bor [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::BasicSearch
        $dirEnumOptions =  $dirEnumOptions -bor [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::LargeCache 

        if($PSBoundParameters.Containskey('Recurse') )
        {
             $dirEnumOptions = $dirEnumOptions -bor [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::Recursive 
        }     
        if($PSBoundParameters.Containskey('Directory') -and (-not($PSBoundParameters.Containskey('File'))))
        {
            $dirEnumOptions = $dirEnumOptions -bor [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::Folders 
        }
        if($PSBoundParameters.Containskey('file') -and (-not($PSBoundParameters.Containskey('Directory'))))
        {
            $dirEnumOptions = $dirEnumOptions -bor [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::Files 
        }
        if(-not($PSBoundParameters.Containskey('Directory')) -and (-not($PSBoundParameters.ContainsKey('File')) ))
        {
             $dirEnumOptions = $dirEnumOptions -bor [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::FilesAndFolders 
        }        
        if($PSBoundParameters.Containskey('Directory') -and $PSBoundParameters.ContainsKey('File') )
        {
             $dirEnumOptions = $dirEnumOptions -bor [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::FilesAndFolders 
        }  

 
        $privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler([Alphaleonis.Win32.Security.Privilege]::Backup, $null)       
        
    }
    Process
    {
        foreach ($pItem in $Path)
        {
            
            $PathObject = New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $pItem
            $Attributes = ($PathObject.Attributes  -split ',').trim() 
    
            if($Attributes -contains 'Directory')
            {
                foreach ($N in @($DirObject::EnumerateFileSystemEntries($pItem,$Filter,$dirEnumOptions)))
                {
                    $filename = [Alphaleonis.Win32.Filesystem.Path]::GetFileName($N)
                    
                    if ($include -and (-not(CompareExtension -Extension $include -Filename $filename)))
                    {
                        continue
                    }
                    if ($exclude -and (CompareExtension -Extension $exclude -Filename $filename))
                    {
                        continue
                    }      
                    if($name)
                    {
                        $N.Replace($pitem,'') -replace '^\\'
                    }
                    Else
                    {
                        New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N
                    }
            }
            
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
        $DirObject = [Alphaleonis.Win32.Filesystem.Directory]    
        $privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler([Alphaleonis.Win32.Security.Privilege]::Backup, $null)         
    }
    Process
    {
        foreach ($PItem in $Path)
        {
            New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $PItem
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
        $DirObject = [Alphaleonis.Win32.Filesystem.Directory] 
        $PathFSObject = [Alphaleonis.Win32.Filesystem.Path]
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
        $DirObject = [Alphaleonis.Win32.Filesystem.Directory]
        $FileObject = [Alphaleonis.Win32.Filesystem.File]
        $PathFSObject = [Alphaleonis.Win32.Filesystem.Path]
        $copyFsObject = [Alphaleonis.Win32.Filesystem.CopyOptions]

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
        
    }
    Process
    {       
        $PathObject = New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $Path
        $Attributes = ($PathObject.Attributes  -split ',').trim() 
        
        $basename = $PathFSObject::GetFileName($Path)
        $dBasename = $PathFSObject::GetFileName($Destination)
        $dParent =  $PathFSObject::GetDirectoryName($Destination)
        
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
            
        if($Attributes -contains 'Directory')
        {
             
            $Destination = 
            try
             {
                 $DirObject::Copy($Path, $destination,$copyOptions)
             }
             catch [Alphaleonis.Win32.Filesystem.AlreadyExistsException]
             {
                 if($Force)
                 {
                     Write-Verbose ("Copy-LongItem:`t Overwriting existing directory...Copying '{0}' to '{1}'" -f $Path,$Destination)
                     $DirObject::Copy($Path, $Destination, $Overwrite)               
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
    
        }#Directory
        Else
        {           
             try
             {
                 $FileObject::Copy($Path, $destination, $copyOptions)
             }
             catch [Alphaleonis.Win32.Filesystem.AlreadyExistsException]
             {
                 if($Force)
                 {
                     Write-Verbose ("Copy-LongItem:`t Overwriting existing File...Copying '{0}' to '{1}'" -f $Path,$Destination)
                     $FileObject::Copy($Path, $Destination, $Overwrite)               
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
         
        
        }#file         
            

    }#Process
    End
    {
    
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
        $DirObject = [Alphaleonis.Win32.Filesystem.Directory]
        $FileObject = [Alphaleonis.Win32.Filesystem.File]
        $DirOptions = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::FilesAndFolders
        $privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler([Alphaleonis.Win32.Security.Privilege]::Backup, $null)       
        
    }
    Process
    {       
        $PathObject = New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $Path
        $Attributes = ($PathObject.Attributes  -split ',').trim() 
        
  
        if($Recurse){$RemoveAll = $true;$Force = $true}else{$RemoveAll = $false }
        if($Force){$IgnoreReadOnly = $true}else{$IgnoreReadOnly = $false }
            
        if($Attributes -contains 'Directory')
        {
            if($Recurse)
            {
                Write-Verbose ("Remove-LongItem:`t Deleting directory '{0}' recursively" -f $Path)
                $DirObject::Delete($Path, $RemoveAll, $IgnoreReadOnly, [Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)            
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
                    $DirObject::Delete($Path, $RemoveAll, $IgnoreReadOnly, [Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)                
                }
            
            
            }#if not recurse 
                 
        }
        Else
        {           
             try
             {
                 Write-Verbose ("Remove-LongItem:`t Deleting file '{0}'..." -f $Path)
                 $FileObject::Delete($Path, $IgnoreReadOnly, [Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)  
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
		[Parameter(Mandatory=$true,
				ValueFromPipelineByPropertyName=$true,
				ValueFromPipeline=$true,ParameterSetName = 'Path',
			 Position=0)]
		[String[]]
		[Parameter(ParameterSetName = 'Name',Mandatory = $false)]
		$Path = $pwd,
          
		[ValidateSet('Directory','File','SymbolicLink','HardLink')]
		[String]
		$ItemType,
		
		[Alias('Target','RealFile')]
		[Parameter()]
		[String]
		$Value,
		
		[Alias('LinkName','Link')]		
		[Parameter(Mandatory=$true,ParameterSetName = 'Name')]
		[String]
		$Name,
        
		[Switch]
		$Force                  
	)

	Begin
	{
		$DirObject = [Alphaleonis.Win32.Filesystem.Directory]
		$FileObject = [Alphaleonis.Win32.Filesystem.File]
		$FileinfoObject = [Alphaleonis.Win32.Filesystem.FileInfo]
		$PathFSObject = [Alphaleonis.Win32.Filesystem.Path]
		$linktype = [Alphaleonis.Win32.Filesystem.SymbolicLinkTarget]

		
		$privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler -ArgumentList ([Alphaleonis.Win32.Security.Privilege]::CreateSymbolicLink, $null)  

	}
	Process
	{       

        
		foreach ($pItem in $Path)
		{
         
        
			if($PSCmdlet.ParameterSetName -eq 'Path')
			{
				$Baseobj = $PathFSObject::GetFileName($pItem) 
				$Parent  = $PathFSObject::GetDirectoryName($pItem)
				$isFile = if($PathFSObject::HasExtension($Baseobj) ){$true}else {$false} 
				
				$RealFileBaseobj = $PathFSObject::GetFileName($value) 
				$RealFileParent  = $PathFSObject::GetDirectoryName($value)
				$isFile_Real = if($PathFSObject::HasExtension($RealFileBaseobj) ){$true}else {$false}				
				
			       
				if( ($ItemType -eq 'File') -and ($isFile) )
				{
					$FilePath = $pItem
                    
					if (-not ($DirObject::Exists($Parent)) )
					{
						$DirObject::CreateDirectory($Parent)
					}     
                               
					if($FileObject::Exists($FilePath))
					{
						if($Force)
						{                          
						     
							if ($Value)
							{
								$FileObject::WriteAllText($FilePath, $Value) 
							}
							Else
							{
								$FileObject::Create($FilePath) | Out-Null
								$FileinfoObject::new($FilePath)
							}
													
						}
						Else
						{
							Write-Warning ("New-LongItem: The file '{0}' already exists. Use '-Force' to overwrite" -f $FilePath)
						}
            
					}# file exists
					Else
					{
						     
						if ($Value)
						{
							$FileObject::WriteAllText($FilePath, $Value) 
						}
						Else
						{
							$FileObject::Create($FilePath) | Out-Null
							$FileinfoObject::new($FilePath)
						}
						
						          
					}
                     
				}#isFile
				Elseif( ($ItemType -eq 'Directory') -and  (-not $isFile) )
				{
					$FolderPath = $pItem
                
					if($DirObject::Exists($FolderPath))
					{
						if($Force)
						{
							$DirObject::CreateDirectory($FolderPath)
						}
						Else
						{
							Write-Warning ("New-LongItem: The Directory '{0}' already exists. Use '-Force' to overwrite" -f $FolderPath)
						}
            
					}# folder exists
					Else
					{
						$DirObject::CreateDirectory($FolderPath)                
					}
            
                        
				}# if directory
				Elseif( ($ItemType -eq 'SymbolicLink')  )
				{
					$FilePath = $pItem
					
					if($isFile) 
					{
						$linktarget = $linktype::File
						$checkfortarget = $FileObject::Exists($FilePath)
					}
					Else
					{
						$linktarget = $linktype::Directory
						$checkfortarget = $DirObject::Exists($FilePath)
					}
					                    
					if (-not ($DirObject::Exists($Parent)) )
					{
						$DirObject::CreateDirectory($Parent)
					}     
                               

					if($checkfortarget)
					{

						  Write-Warning ("New-LongItem: The SymbolicLink '{0}' already exists." -f $FilePath)
						
					}# file exists
					Else
					{  
						if( ($isFile_Real -and $isFile) -or ( (-not $isFile_Real) -and (-not $isFile)) )
						{
							Write-Verbose ("New-LongItem:`tCreating Symbolic Link ['{0}'] for ['{1}']" -f $FilePath,$Value)
							$FileObject::CreateSymbolicLink($FilePath, $value, $linktarget)   						
						}
						Else
						{
							Write-Warning ("New-LongItem: Type(Folder\File) Mismatch between The SymbolicLink '{0}' & Target '{1}'." -f $FilePath,$Value)
						}       
					}
					

 

                     
				}# if file and symboliclink	
				Elseif( ($ItemType -eq 'HardLink') -and  $isFile )
				{
					$FilePath = $pItem
					
                    
					if (-not ($DirObject::Exists($Parent)) )
					{
						$DirObject::CreateDirectory($Parent)
					}     
                               
					if($FileObject::Exists($FilePath))
					{

						Write-Warning ("New-LongItem: The HardLink '{0}' already exists." -f $FilePath)
						
					}# file exists
					Else
					{  
						try
						{
							if( ($isFile_Real -and $isFile) -or ( (-not $isFile_Real) -and (-not $isFile)) )
							{
								Write-Verbose ("New-LongItem:`tCreating Hard Link ['{0}'] for file ['{1}']" -f $FilePath,$Value)
								$FileObject::CreateHardlink($FilePath, $Value)  						
							}
							Else
							{
								Write-Warning ("New-LongItem: Type(Folder\File) Mismatch between The Hardlink '{0}' & Target '{1}'.`nThe hardlink and Target must both be files" -f $FilePath,$Value)
							}
						
						}
						catch
						{
							Throw $_.exception.innerexception
						}      
					}
                     
				}# if file and Hardlink	
				Elseif( ($ItemType -eq 'HardLink') -and  (-not $isFile) )	
				{
					$FilePath = $pItem
					Write-Warning ("New-LongItem: The Hardlink to be created cannot be a folder '{0}'" -f $FilePath) 
				}			
           
			}#pscmdlet is path
        
			if($PSCmdlet.ParameterSetName -eq 'Name')
			{
				if([Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($Name))
				{
					  $pItem = $Name
				}
				Else
				{
					  $pItem = $PathFSObject::Combine($pItem, $Name)
				}
				
				
				$Baseobj = $PathFSObject::GetFileName($pItem) 
				$Parent  = $PathFSObject::GetDirectoryName($pItem)
				$isFile = if($PathFSObject::HasExtension($Baseobj) ){$true}else {$false} 
				
				$RealFileBaseobj = $PathFSObject::GetFileName($value) 
				$RealFileParent  = $PathFSObject::GetDirectoryName($value)
				$isFile_Real = if($PathFSObject::HasExtension($RealFileBaseobj) ){$true}else {$false}				
				 
				if($ItemType -eq 'File')
				{
					$FilePath = $pItem
                    
					if (-not ($DirObject::Exists($Parent)) )
					{
						$DirObject::CreateDirectory($Parent)
					}                    
                
					if($FileObject::Exists($FilePath))
					{
						if($Force)
						{
							
						     
							if ($Value)
							{
								$FileObject::WriteAllText($FilePath, $Value) 
							}
							Else
							{
								$FileObject::Create($FilePath) | Out-Null
								$FileinfoObject::new($FilePath)
							}
													
						}
						Else
						{
							Write-Warning ("New-LongItem: The file '{0}' already exists. Use '-Force' to overwrite" -f $FilePath)
						}
            
					}# file exists
					Else
					{
						     
						if ($Value)
						{
							$FileObject::WriteAllText($FilePath, $Value) 
						}
						Else
						{
							$FileObject::Create($FilePath) | Out-Null
							$FileinfoObject::new($FilePath)
						}						        
					}
                     
				}#isFile
				Elseif($ItemType -eq 'Directory')
				{
					$FolderPath = $PathFSObject::Combine($pItem, $Name)
                
					if($DirObject::Exists($FolderPath))
					{
						if($Force)
						{
							$DirObject::CreateDirectory($FolderPath)
						}
						Else
						{
							Write-Warning ("New-LongItem: The Directory '{0}' already exists. Use '-Force' to overwrite" -f $FolderPath)
						}
            
					}# folder exists
					Else
					{
						$DirObject::CreateDirectory($FolderPath)                
					}
            
                        
				}# if directory  
				
				Elseif( ($ItemType -eq 'SymbolicLink') )
				{
					$FilePath = $pItem
					
					if($isFile) 
					{
						$linktarget = $linktype::File
						$checkfortarget = $FileObject::Exists($FilePath)
					}
					Else
					{
						$linktarget = $linktype::Directory
						$checkfortarget = $DirObject::Exists($FilePath)
					}					
				
                    
					if (-not ($DirObject::Exists($Parent)) )
					{
						$DirObject::CreateDirectory($Parent)
					}   
					
					  
                               
					if($checkfortarget)
					{

						Write-Warning ("New-LongItem: The SymbolicLink '{0}' already exists." -f $FilePath)
						
					}# file exists
					Else
					{  
						if( ($isFile_Real -and $isFile) -or ( (-not $isFile_Real) -and (-not $isFile)) )
						{
							Write-Verbose ("New-LongItem:`tCreating Symbolic Link ['{0}'] for ['{1}']" -f $FilePath,$Value)
							$FileObject::CreateSymbolicLink($FilePath, $value, $linktarget)   						
						}
						Else
						{
							Write-Warning ("New-LongItem: Type(Folder\File) Mismatch between The SymbolicLink '{0}' & Target '{1}'." -f $FilePath,$Value)
						}
						
     
					}
                     
				}# if file and symboliclink
				Elseif( ($ItemType -eq 'HardLink') -and  $isFile )
				{
					$FilePath = $pItem
					
                    
					if (-not ($DirObject::Exists($Parent)) )
					{
						$DirObject::CreateDirectory($Parent)
					}     
                               
					if($FileObject::Exists($FilePath))
					{

						Write-Warning ("New-LongItem: The HardLink '{0}' already exists." -f $FilePath)
						
					}# file exists
					Else
					{  
						try
						{
							
							if( ($isFile_Real -and $isFile) -or ( (-not $isFile_Real) -and (-not $isFile)) )
							{
								Write-Verbose ("New-LongItem:`tCreating Hard Link ['{0}'] for file ['{1}']" -f $FilePath,$Value)
								$FileObject::CreateHardlink($FilePath, $Value)  						
							}
							Else
							{
								Write-Warning ("New-LongItem: Type(Folder\File) Mismatch between The Hardlink '{0}' & Target '{1}'.`nThe hardlink and Target must both be files" -f $FilePath,$Value)
							}
						
													
 
						
						}
						catch
						{
							Throw $_.exception.innerexception
						}
						
					}
                     
				}# if file and Hardlink	
				Elseif( ($ItemType -eq 'HardLink') -and  (-not $isFile) )	
				{
					$FilePath = $pItem
					Write-Warning ("New-LongItem: The Hardlink to be created cannot be a folder '{0}'" -f $FilePath) 
				}				 
                 
			}#pscmdlet is Name
        
        
		}#foreach pitem
                        

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
        $FileObject = [Alphaleonis.Win32.Filesystem.File]
        $DirectoryObject = [Alphaleonis.Win32.Filesystem.Directory]
        $PathFSObject = [Alphaleonis.Win32.Filesystem.Path]
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
                $NewPath = Join-Path -Path $Destination -ChildPath $basename 
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

                if($DirectoryObject::Exists($Destination ))
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

function Mount-LongItem
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
			elseif($env:USERDOMAIN)
			{
				$NetWorkCreds.Domain = $env:USERDOMAIN
			}

			#map drive
			try
			{
				Write-Verbose ("Mount-LongItem:`t Mapping NetWorkShare ['{0}'] to DriveLetter ['{1}'] with Credentials '[{2}']" -f $NetWorkShare,$DriveLetter, $Credential.UserName)
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
				Write-Verbose ("Mount-LongItem:`t Mapping NetWorkShare ['{0}'] to DriveLetter ['{1}']" -f $NetWorkShare,$DriveLetter)
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


function DisMount-LongItem
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
				 
				Write-Verbose ("DisMount-LongItem:`t Force Detected...Closing open network connections and Removing Mapped Drive ['{0}']" -f $DriveLetter)
				$RemoveDrive = [Alphaleonis.Win32.Network.Host]::DisconnectDrive($DriveLetter, $true, $true)
			}
			Else
			{
				Write-Verbose ("DisMount-LongItem:`t Removing Mapped Drive ['{0}']" -f $DriveLetter)   
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


function Get-LongMappedDrives
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

function Get-LongDiskSpace
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



Set-Alias -Name ldir -Value Get-LongChildItem
Set-Alias -Name lgci -Value Get-LongChildItem

