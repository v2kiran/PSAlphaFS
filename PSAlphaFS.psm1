# Import Private functions
. "$PSScriptRoot\Helpers\PSAlphaFSHelpers.ps1"

# Declare TypeShortcut variables
$DirObject = [Alphaleonis.Win32.Filesystem.Directory]
$FileObject = [Alphaleonis.Win32.Filesystem.File]
$FileinfoObject = [Alphaleonis.Win32.Filesystem.FileInfo]
$PathFSObject = [Alphaleonis.Win32.Filesystem.Path]
$PathFSFormatObject = [Alphaleonis.Win32.Filesystem.PathFormat]
$dirEnumOptionsFSObject = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]
$copyFsObject = [Alphaleonis.Win32.Filesystem.CopyOptions]
$linktype = [Alphaleonis.Win32.Filesystem.SymbolicLinkTarget]
$MoveOptions = [Alphaleonis.Win32.Filesystem.MoveOptions]



# .ExternalHelp PSAlphafs.psm1-help.xml
function Get-LongChildItem {
    [Alias('ldir','lgci')]
    [CmdletBinding(DefaultParameterSetName = 'All')]
    Param
    (
        # Specify the Path to the File or Folder
        [Parameter(ValueFromPipelineByPropertyName,
            ValueFromPipeline,
            Position = 0)]
        [String[]]
        $Path = $PWD,
        
        # Filter wildcard string 
        [Parameter(Position = 1)]   
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

    Begin {

        $dirEnumOptions = $dirEnumOptionsFSObject::ContinueOnException 
        $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::BasicSearch
        $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::LargeCache 

        if($PSBoundParameters.Containskey('Recurse') ) {
            $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::Recursive
        } 
        if($PSBoundParameters.Containskey('SkipSymbolicLink') ) {
            $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::SkipReparsePoints
        }             
        if($PSBoundParameters.Containskey('Directory') -and (-not($PSBoundParameters.Containskey('File')))) {
            $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::Folders
        }
        if($PSBoundParameters.Containskey('file') -and (-not($PSBoundParameters.Containskey('Directory')))) {
            $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::Files
        }
        if(-not($PSBoundParameters.Containskey('Directory')) -and (-not($PSBoundParameters.ContainsKey('File')) )) {
            $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::FilesAndFolders
        }        
        if($PSBoundParameters.Containskey('Directory') -and $PSBoundParameters.ContainsKey('File') ) {
            $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::FilesAndFolders
        }  

        $dirEnumOptions = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]$dirEnumOptions
        $privilegeEnabler = New-Object -TypeName Alphaleonis.Win32.Security.PrivilegeEnabler -ArgumentList ([Alphaleonis.Win32.Security.Privilege]::Backup, $null)       
        
    }
    Process {
        foreach ($pItem in $Path) {
            # Check if path is relative
            if(-not $PathFSObject::IsPathRooted($pItem, $true)) {
                $pItem = $PathFSObject::Combine($PWD, $pItem.TrimStart('.\'))
            }
	
            # Check if path exists on the filesystem
            if(-not ($FileObject::Exists($pItem) -or $DirObject::Exists($pItem))) {
                Write-Warning -Message ("Get-LongChildItem:`tPath '{0}' dosent exist." -f $pItem)
                continue
            }

            $PathObject = New-Object -TypeName Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $pItem, $PathFSFormatObject::FullPath
            $hasDirAttribute = ($PathObject.Attributes -band [System.IO.FileAttributes]::Directory) -eq 'Directory'
  
            if($PathObject.EntryInfo.IsDirectory -or  $hasDirAttribute ) {
                $DirObject::EnumerateFileSystemEntries($pItem,$Filter,$dirEnumOptions) | 
                    ForEach-Object -Process {
                    if ($Include -and (-not(CompareExtension -Extension $Include -Filename $PathFSObject::GetFileName($_)))) {
                        return
                    }
                    if ($Exclude -and (CompareExtension -Extension $Exclude -Filename $PathFSObject::GetFileName($_))) {
                        return
                    }      
                    if($Name) {
                        $_.Replace($pItem,'') -replace '^\\'
                    }
                    Else {
                        New-Object -TypeName Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $_, $PathFSFormatObject::FullPath
                    }
                }#foreach filesystementry
            }#If path is a folder
            Else {
                if($Name) {
                    $PathObject | Select-Object -ExpandProperty Name
                }
                Else {
                    Write-Output -InputObject $PathObject
                }
            }#if path is not a folder
        }#foreach path item
    }#Process
    end {
        If ($privilegeEnabler) {
            $privilegeEnabler.Dispose()
        }
    }#end
}#End Function



# .ExternalHelp PSAlphafs.psm1-help.xml
function Get-LongItem {
    [CmdletBinding()]
    Param
    (
        # Specify the Path to the File or Folder      
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline,
            Position = 0)]
        [String[]]
        $Path
          
    )    

    Begin {  
        $privilegeEnabler = New-Object -TypeName Alphaleonis.Win32.Security.PrivilegeEnabler -ArgumentList ([Alphaleonis.Win32.Security.Privilege]::Backup, $null)         
    }
    Process {
        foreach ($pItem in $Path) {
            # Check if path is relative
            if(-not $PathFSObject::IsPathRooted($Path, $true)) {
                $pItem = $PathFSObject::Combine($PWD, $pItem.TrimStart('.\'))
            }
	
            # Check if path exists on the filesystem
            if(-not ($FileObject::Exists($pItem) -or $DirObject::Exists($pItem))) {
                Write-Warning -Message ("Get-LongItem:`tPath '{0}' dosent exist." -f $pItem)
                continue
            }
			
            New-Object -TypeName Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $pItem, $PathFSFormatObject::FullPath
        }
        
    }#Process
    End {
        If ($privilegeEnabler) {
            $privilegeEnabler.Dispose()
        }
    }#end    
}#End Function



# .ExternalHelp PSAlphafs.psm1-help.xml
function Rename-LongItem {
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'High',DefaultParameterSetName = 'Name')]
    Param
    (
        # The Path to the File or Folder             
        [Alias('FullName')]
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline,
            Position = 0)]
        [String]
        $Path,
       
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Name',
            Position = 1)]       
        [String]
        $NewName,
		
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Extension',
            Position = 1)]       
        [String]
        $NewExtension,		
        
        #[parameter(ParameterSetName = 'Name')]
        [Switch]
        $Force        
        
          
    )

    Begin {
        $ReplaceExisting = $MoveOptions::ReplaceExisting
    }
    Process {       
		

        if(-not [Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($Path)) {
            $Path = $PathFSObject::Combine($PWD, $Path.TrimStart('.\'))
        }
		
        if(-not ($FileObject::Exists($Path) -or $DirObject::Exists($Path))) {
            Write-Warning -Message ("Rename-LongItem:`tPath '{0}' dosent exist." -f $Path)
            return
        }
		
        $PathObject = New-Object -TypeName Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $Path
		
        if($PathObject.EntryInfo.IsDirectory) {
            $isfile = $false
            $fsObject = $DirObject
			
        }
        else {
            $isfile = $true
            $fsObject = $FileObject
        }
					
        
        if($PSCmdlet.ParameterSetName -eq 'Name' ) {
			
            if(-not [Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($NewName)) {
                $NewPath = $PathFSObject::Combine($PWD, $NewName.TrimStart('.\'))
            }
            Else {
                $NewPath = $NewName
            }	
			
            if($Path -eq $NewPath) {
                Write-Warning ("Rename-LongItem:`t{0} and {1} are the same" -f $Path, $NewPath)
                return
            }					
			
            if($isfile) {
                # check if there is an existing folder with the same name as the file we are trying to create
                if($DirObject::Exists($NewPath)) {
                    Write-Warning ("Rename-LongItem: A Directory with the same name '{0}' already exists." -f $NewPath)
                    return
                }
                #Create a file
                if($FileObject::Exists($NewPath)) {
                    if($Force) {                          
						     
                        Write-Verbose -Message ("Rename-LongItem:`n {0} `n`t`t{1}`n" -f $Path, $NewPath)
                        $FileObject::Move($Path, $NewPath,$ReplaceExisting, $PathFSFormatObject::FullPath)
																				
                    }
                    Else {
                        Write-Warning -Message ("Rename-LongItem:`tAn item with the same name already exists at '{0}'.`nUse '-Force' to overwrite" -f $NewPath)
                    }
            
                }# file exists	
                Else {
                    if($PSCmdlet.ShouldProcess("Item:`t$path Destination:`t$NewName","Rename File")) {
                        Write-Verbose -Message ("Rename-LongItem:`n {0} `n`t`t{1}`n" -f $Path, $NewPath)
                        $FileObject::Move($Path, $NewPath, $PathFSFormatObject::FullPath)					
                    }
				
                }			
            }
            # if path is a file	
            Else {
                # check if there is an existing folder with the same name as the file we are trying to create
                if($FileObject::Exists($NewPath)) {
                    Write-Warning ("Rename-LongItem: A File with the same name '{0}' already exists." -f $NewPath)
                    return
                }
                #Create a file
                if($DirObject::Exists($NewPath)) {
                    if($Force) {                          
						     
                        Write-Verbose -Message ("Rename-LongItem:`n {0} `n`t`t{1}`n" -f $Path, $NewPath)
                        $DirObject::Move($Path, $NewPath,$ReplaceExisting, $PathFSFormatObject::FullPath)
																				
                    }
                    Else {
                        Write-Warning -Message ("Rename-LongItem:`tAn item with the same name already exists at '{0}'.`nUse '-Force' to overwrite" -f $NewPath)
                    }
            
                }# file exists	
                Else {
                    if($PSCmdlet.ShouldProcess("Item:`t$path Destination:`t$NewName","Rename File")) {
                        Write-Verbose -Message ("Rename-LongItem:`n {0} `n`t`t{1}`n" -f $Path, $NewPath)
                        $DirObject::Move($Path, $NewPath, $PathFSFormatObject::FullPath)					
                    }			
                }
                # Directory				
			
            }	
        }
        #set 
        if($PSCmdlet.ParameterSetName -eq 'Extension' ) {
            $NewPath = $PathFSObject::ChangeExtension($Path, $NewExtension)
            if($Path -eq $NewPath) {
                Write-Warning ("Rename-LongItem:`t{0} and {1} are the same" -f $Path, $NewPath)
                return
            }
			
            if($isfile) {
                # check if there is an existing folder with the same name as the file we are trying to create
                if($DirObject::Exists($NewPath)) {
                    Write-Warning ("New-LongItem: A Directory with the same name '{0}' already exists." -f $NewPath)
                    return
                }
                #Create a file
                if($FileObject::Exists($NewPath)) {
                    if($Force) {                          
						     
                        Write-Verbose -Message ("Rename-LongItem:`n {0} `n`t`t{1}`n" -f $Path, $NewPath)
                        $FileObject::Move($Path, $NewPath,$ReplaceExisting, $PathFSFormatObject::FullPath)
																				
                    }
                    Else {
                        Write-Warning -Message ("Rename-LongItem:`tAn item with the same name already exists at '{0}'.`nUse '-Force' to overwrite" -f $NewPath)
                    }
            
                }# file exists	
                Else {
                    if($PSCmdlet.ShouldProcess("Item:`t$Path`tDestination:`t$($PathFSObject::ChangeExtension($Path, $NewExtension))",'Changing Extension')) {
                        Write-Verbose -Message ("Rename-LongItem:`n {0} `n`t`t{1}`n" -f $Path, $NewPath)
                        $FileObject::Move($Path, $NewPath, $PathFSFormatObject::FullPath)					
                    }
				
                }			
            }
            # if path is a file	
            Else {
                # check if there is an existing folder with the same name as the file we are trying to create
                if($FileObject::Exists($NewPath)) {
                    Write-Warning ("New-LongItem: A File with the same name '{0}' already exists." -f $NewPath)
                    return
                }
                #Create a file
                if($DirObject::Exists($NewPath)) {
                    if($Force) {                          
						     
                        Write-Verbose -Message ("Rename-LongItem:`n {0} `n`t`t{1}`n" -f $Path, $NewPath)
                        $DirObject::Move($Path, $NewPath,$ReplaceExisting, $PathFSFormatObject::FullPath)
																				
                    }
                    Else {
                        Write-Warning -Message ("Rename-LongItem:`tAn item with the same name already exists at '{0}'.`nUse '-Force' to overwrite" -f $NewPath)
                    }
            
                }# file exists	
                Else {
                    if($PSCmdlet.ShouldProcess("Item:`t$Path`tDestination:`t$($PathFSObject::ChangeExtension($Path, $NewExtension))",'Changing Extension')) {
                        Write-Verbose -Message ("Rename-LongItem:`n {0} `n`t`t{1}`n" -f $Path, $NewPath)
                        $DirObject::Move($Path, $NewPath, $PathFSFormatObject::FullPath)					
                    }			
                }
                # Directory				
			
            }		
					
			

        }
        #set Extension		

    
    }#Process
    End {
    
    }
}#end function 


# .ExternalHelp PSAlphafs.psm1-help.xml
function Copy-LongItem {
    [CmdletBinding()]
    Param
    (
        # The Path to the File or Folder      
        [Alias('FullName')]
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline,
            Position = 0)]
        [String]
        $Path,
       
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 1)]       
        [String]
        $Destination,
        
        [Switch]
        $Force,
        
        [Validateset('File', 'Directory')]
        [String]
        $DestinationType,        

        # If the source file is a symbolic link, 
        # the destination file is also a symbolic link pointing to the same file that the source symbolic link is pointing to.
        #[Switch]
        #$CopySymbolicLink,

        # The copy operation is performed using unbuffered I/O, bypassing system I/O cache resources. Recommended for very large file transfers.
        [Switch]
        $NoBuffering,

        # An attempt to copy an encrypted file will succeed even if the destination copy cannot be encrypted.     
        [Switch]
        $AllowDecryptedDestination                              
    )

    Begin {
        $copyOptions = $copyFsObject::FailIfExists
        if ($PSBoundParameters.Containskey('CopySymbolicLink') ) {
            $copyOptions = $copyOptions -bor $copyFsObject::CopySymbolicLink
        }  
        if ($PSBoundParameters.Containskey('NoBuffering') ) {
            $copyOptions = $copyOptions -bor $copyFsObject::NoBuffering
        }  
        if ($PSBoundParameters.Containskey('AllowDecryptedDestination') ) {
            $copyOptions = $copyOptions -bor $copyFsObject::AllowDecryptedDestination
        }                       
        $copyOptions = [Alphaleonis.Win32.Filesystem.CopyOptions]$copyOptions
        $privilegeEnabler = New-Object -TypeName Alphaleonis.Win32.Security.PrivilegeEnabler -ArgumentList ([Alphaleonis.Win32.Security.Privilege]::CreateSymbolicLink, $null)
    }
    Process {       
	
        if (-not [Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($Path, $true)) {
            $Path = $PathFSObject::Combine($PWD, $Path.TrimStart('.\'))
        }
		
        if (-not ($FileObject::Exists($Path) -or $DirObject::Exists($Path))) {
            Write-Warning -Message ("Copy-LongItem:`tPath '{0}' dosent exist." -f $Path)
            return
        }
			
        $PathObject = New-Object -TypeName Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $Path, $PathFSFormatObject::FullPath
        
        $basename = $PathFSObject::GetFileName($Path)
        $dBasename = $PathFSObject::GetFileName($Destination)
        $dParent = $PathFSObject::GetDirectoryName($Destination)
        
        if ($DestinationType -eq 'File') {
            $isFile = $true
        }
        Elseif ($DestinationType -eq 'Directory') {
            $isFile = $false
        }
        Else {
            $isFile = if ($PathFSObject::HasExtension($dBasename) ) {
                $true
            }
            else {
                $false
            } 
                     
        }

        
        # Create the directory tree before the copy
        if ($isFile) {
            $Destination_isFile = $true
            if ( -not ( $DirObject::Exists($dParent))) {
                $null = $DirObject::CreateDirectory($dParent)
            }
        }#destination is a file
        Else {
            $Destination_isDirectory = $true
            if ( -not ( $DirObject::Exists($Destination))) {
                $null = $DirObject::CreateDirectory($Destination)
                $Destination = $PathFSObject::Combine($Destination, $basename)
            } 
            Else {
                $Destination = $PathFSObject::Combine($Destination, $basename)
            }
        }#destination is a folder
        

                
        if ($PathObject.EntryInfo.IsDirectory) {
            $fsObject = $DirObject
        }
        else {
            $fsObject = $FileObject
        }    

        # Perform the copy     
        try {
            Write-Verbose -Message ("Copy-LongItem:`tCopying '{0}' to '{1}'" -f $Path, $Destination)
            $fsObject::Copy($Path, $Destination, $copyOptions)
        }
        catch [Alphaleonis.Win32.Filesystem.AlreadyExistsException] {
            if ($Force) {
                # need to delete destination because the copy method dosent contain an overload that includes
                # both the overwrite and copyoptions parameters
                $fsObject::Delete($Destination, $true, $PathFSFormatObject::FullPath) 

                Start-Sleep -Milliseconds 300

                Write-Verbose -Message ("Copy-LongItem:`t Overwriting existing item...Copying '{0}' to '{1}'" -f $Path, $Destination)
                $fsObject::Copy($Path, $Destination, $copyOptions)               
            }
            Else {
                Write-Warning -Message ("Copy-LongItem:`tAn item with the same name already exists at '{0}'.`nUse '-Force' to overwrite" -f $Destination)
            }
        }
        Catch {
            throw $_
        }
    
    }#Process
    End {
        If ($privilegeEnabler) {
            $privilegeEnabler.Dispose()
        }    
    }
}#end function 


# .ExternalHelp PSAlphafs.psm1-help.xml
function Remove-LongItem {
    [CmdletBinding()]
    Param
    (
        # The Path to the File or Folder        
        [Alias('FullName')]
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline,
            Position = 0)]
        [String]
        $Path,
            
        [Switch]
        $Recurse,
        
        [Switch]
        $Force                  
    )

    Begin {

        $DirOptions = $dirEnumOptionsFSObject::FilesAndFolders
        $privilegeEnabler = New-Object -TypeName Alphaleonis.Win32.Security.PrivilegeEnabler -ArgumentList ([Alphaleonis.Win32.Security.Privilege]::Backup, $null)       
        
    }
    Process {      
	
        if(-not [Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($Path,$true)) {
            $Path = $PathFSObject::Combine($PWD, $Path.TrimStart('.\'))
        }
		
        if(-not ($FileObject::Exists($Path) -or $DirObject::Exists($Path))) {
            Write-Warning -Message ("Remove-LongItem:`tPath '{0}' dosent exist." -f $Path)
            return
        }
			 
        $PathObject = New-Object -TypeName Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $Path

        
  
        if($Recurse) {
            $RemoveAll = $true
            $Force = $true
        }
        else {
            $RemoveAll = $false 
        }
        if($Force) {
            $IgnoreReadOnly = $true
        }
        else {
            $IgnoreReadOnly = $false 
        }
            
        if($PathObject.EntryInfo.IsDirectory) {
            if($Recurse) {
                Write-Verbose -Message ("Remove-LongItem:`t Deleting directory '{0}' recursively" -f $Path)
                $DirObject::Delete($Path, $RemoveAll, $IgnoreReadOnly, $PathFSFormatObject::FullPath)            
            }
            Else {
                if( $DirObject::CountFileSystemObjects($Path,$DirOptions) -gt 0) {
                    Write-Warning -Message ("Remove-LongItem:`t The Directory '{0}' is not Empty.`nUse '-Recurse' to remove it." -f $Path)
                }
                Else {
                    Write-Verbose -Message ("Remove-LongItem:`t Deleting empty directory '{0}'" -f $Path)
                    $DirObject::Delete($Path, $RemoveAll, $IgnoreReadOnly, $PathFSFormatObject::FullPath)                
                }
            }#if not recurse 
        }
        Else {           
            try {
                Write-Verbose -Message ("Remove-LongItem:`t Deleting file '{0}'..." -f $Path)
                $FileObject::Delete($Path, $IgnoreReadOnly, $PathFSFormatObject::FullPath)  
            }
            catch [Alphaleonis.Win32.Filesystem.FileReadOnlyException] {
                Write-Warning -Message ("Remove-LongItem:`t The file '{0}' is ReadOnly.`nUse '-Force' to remove it." -f $Path)
            }
            catch {
                throw $_
            }
        }#If file        
            

    }#Process
    End {
        If ($privilegeEnabler) {
            $privilegeEnabler.Dispose()
        }    
    }
}#end function 


# .ExternalHelp PSAlphafs.psm1-help.xml
function New-LongItem {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    Param
    (
        # The Path to the File or Folder
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline,ParameterSetName = 'Path',
            Position = 0)]
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

    Begin {
	
        $privilegeEnabler = New-Object -TypeName Alphaleonis.Win32.Security.PrivilegeEnabler -ArgumentList ([Alphaleonis.Win32.Security.Privilege]::CreateSymbolicLink, $null)  

    }
    Process {       

        if($Path) {
            foreach ($pItem in $Path) {
                if($PSCmdlet.ParameterSetName -eq 'Path') {
                    if(-not [Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($pItem)) {
                        $pItem = $PathFSObject::Combine($PWD, $pItem)
                    }
				
                    $FilePath = $pItem
                }# pscmdlet Path
			
                if($PSCmdlet.ParameterSetName -eq 'Name') {
                    if($PathFSObject::IsPathRooted($Name) -and $PathFSObject::IsPathRooted($pItem)) {
                        Write-Warning -Message ("New-LongItem: The given path's format is not supported")
                        break
                    }
				

                    elseif([Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($pItem)) {
                        $FilePath = $PathFSObject::Combine($pItem, $Name)
                    }
                    Else {
                        $FilePath = $PathFSObject::Combine($PWD, $pItem, $Name)
                    }
                }#pscmdlet is Name	

				
                $params = 
                @{
                    Filename = $FilePath
                    itemtype = $ItemType
                    value    = $Value
                    Encoding = $Encoding
                }
                if($Force) {$params.Add('Force',$Force)}
                newlongitemhelper @params
				

            }#foreach pitem
        }# if path
        Else {
            if($PSCmdlet.ParameterSetName -eq 'Name') {
                if([Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($Name)) {
                    $FilePath = $Name
                }
                Else {
                    $FilePath = $PathFSObject::Combine($PWD, $Name)
                }
            }#pscmdlet is Name	

            $params = 
            @{
                Filename = $FilePath
                itemtype = $ItemType
                value    = $Value
                Encoding = $Encoding
            }
            if($Force) {$params.Add('Force',$Force)}
            newlongitemhelper @params
        }# if path is not specified            

    }#Process
    End {
        If ($privilegeEnabler) {
            $privilegeEnabler.Dispose()
        }    
    }
}#end function 



# .ExternalHelp PSAlphafs.psm1-help.xml
function Move-LongItem {
    [CmdletBinding()]
    Param
    (
        # The Path to the File or Folder    
        [ValidateScript({ 
                if( [Alphaleonis.Win32.Filesystem.Directory]::Exists($_) -or  [Alphaleonis.Win32.Filesystem.File]::Exists($_)  ) {
                    $true
                }
                Else {
                    Write-Warning -Message ("Rename-LongItem:`tPath '{0}' does not exist`n`n" -f $_) 
                }
            })]           
        [Alias('FullName')]
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline,
            Position = 0)]
        [String]
        $Path,
       
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 1)]       
        [String]
        $Destination,
        
        [Switch]
        $Force        
        
          
    )

    Begin {
        $ReplaceExisting = [Alphaleonis.Win32.Filesystem.MoveOptions]::ReplaceExisting
    }
    Process {       
        $Parent = $PathFSObject::GetDirectoryName($Path)
        $basename = $PathFSObject::GetFileName($Path)
        $dParent = $PathFSObject::GetDirectoryName($Destination)
        $dBasename = $PathFSObject::GetFileName($Destination)

        $isFile = if($PathFSObject::HasExtension($basename) ) {
            $true
        }
        else {
            $false
        } 
        $isFile_destination = if($PathFSObject::HasExtension($dBasename) ) {
            $true
        }
        else {
            $false
        } 
        
        if($isFile) {
            #Basename is a file so destination has to be a file
            $Basename_isFile = $true
            
            if ($isFile_destination) {
                $Destination_isFile = $true
                $NewPath = $Destination 
            }            
            Else {
                $Destination_isDirectory = $true
                $NewPath = $PathFSObject::Combine($Destination, $basename)
            }            
        }#basename is file
        Else {
            #basename is a folder so check the destination basename
            $Basename_isDirectory = $true
            if ($isFile_destination) {
                Write-Warning -Message ("Move-LongItem:`tThe source is a directory so please specify a directory as the destination")
                break
            }            
            Else {
                $Destination_isDirectory = $true

                if($DirObject::Exists($Destination )) {
                    $NewPath = $PathFSObject::Combine($Destination, $basename)
                }
                Else {
                    $NewPath = $Destination
                }
            }# destination is a directory             
        }#basename is a directory
        
        


        if($Path -ne $NewPath) {
            if ($Basename_isFile) {
                $Object = $FileObject
            }
            Elseif($Basename_isDirectory) {
                $Object = $DirectoryObject
            }
                
            if($Force) {
                Write-Verbose -Message ("Move-LongItem:`n {0} `n`t`t{1}`n" -f $Path, $NewPath)
                $Object::Move($Path, $NewPath,$ReplaceExisting)              
            }
            Else {
                try {
                    Write-Verbose -Message ("Move-LongItem:`n {0} `n`t`t{1}`n" -f $Path, $NewPath)
                    $Object::move($Path,$NewPath)
                }
                catch [Alphaleonis.Win32.Filesystem.AlreadyExistsException] {
                    Write-Warning -Message ("Move-LongItem:`tAn item named '{0}' already exists at the destination.`nUse '-Force' to overwrite" -f $NewPath)
                }
                Catch {
                    throw $_
                }
            }#no force
        }
        Else {
            Write-Warning -Message ("Move-LongItem:`tAn item cannot be moved to a destination that is same as the source")
        }
                
        
    
    }#Process
    End {
    
    }
}#end function 

# .ExternalHelp PSAlphafs.psm1-help.xml
function Mount-LongShare {
    [CmdletBinding(DefaultParameterSetName = 'Simple')]
    Param
    (
        # Specify the Local Drive the NetworkShare is to be Mapped to          
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0)]
        [String]
        $DriveLetter,
		
        # Specify the NetworkShare that is to be mapped   
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 1)]
        [String]
        $NetWorkShare,
		
        # Specify the NetworkShare that is to be mapped   
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Credential',
            Position = 2)]
        [pscredential]
        $Credential
		
			
				
          
    )    

    Begin {
     
    }
    Process {
        $DriveLetter = FormatDriveLetter $DriveLetter
		
        if(-not (Test-Path $DriveLetter)) {

            if(-not (CheckMappedDriveExists $DriveLetter $NetworkShare)) {
		
                if($PSCmdlet.ParameterSetName -eq 'Credential') {
                    $NetWorkCreds = New-Object -TypeName System.Net.NetworkCredential -ArgumentList @($Credential.UserName, $Credential.Password)
                    $Domain = $Credential.GetNetworkCredential().domain
					
                    if($Domain) {
                        $NetWorkCreds.Domain = $Domain
                    }

                    #map drive
                    try {
                        Write-Verbose -Message ("Mount-LongShare:`t Mapping NetWorkShare ['{0}'] to DriveLetter ['{1}'] with Credentials '[{2}']" -f $NetWorkShare, $DriveLetter, $Credential.UserName)
                        $MapDrive = [Alphaleonis.Win32.Network.Host]::ConnectDrive($DriveLetter, $NetWorkShare, $Credential, $false, $true, $true)
                    }
                    catch {
                        throw $_
                    }
                }# Parameterset Credential
				
                if($PSCmdlet.ParameterSetName -eq 'Simple') {
                    #map drive
                    try {
                        Write-Verbose -Message ("Mount-LongShare:`t Mapping NetWorkShare ['{0}'] to DriveLetter ['{1}']" -f $NetWorkShare, $DriveLetter)
                        $MapDrive = [Alphaleonis.Win32.Network.Host]::ConnectDrive($DriveLetter, $NetWorkShare)
                    }
                    catch {
                        throw $_
                    }
                }# Parameterset Simple

            }# check if share is already mapped	
            else {
                Write-Warning -Message ("Mount-LongShare:`t The Drive ['{0}'] is already mapped to share ['{1}']" -f $DriveLetter, $NetWorkShare) 
            }
        }
        else {
            Write-Warning -Message ("Mount-LongShare:`t The Drive ['{0}'] is in use" -f $DriveLetter)
        }

        
    }#Process
    End {

    }#end    
}#End Function

# .ExternalHelp PSAlphafs.psm1-help.xml
function DisMount-LongShare {
    [CmdletBinding()]
    Param
    (
        # Specify the Local Drive the NetworkShare is to be Mapped to    	
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline,
            Position = 0)]
        [String]
        $DriveLetter,
		
        # Specify if the existing Connections to a share are to be closed
        [Switch]
        $Force
      
    )    

    Begin {
     
    }
    Process {
		
        $DriveLetter = FormatDriveLetter $DriveLetter
        if( -not (Test-path $DriveLetter )) { 
            Write-warning ("DisMount-LongShare:`tPath '{0}' does not exist`n`n" -f $DriveLetter)
            return
        }
		
					
        #map drive
        try {
            if($Force) {
                Write-Verbose -Message ("DisMount-LongShare:`t Force Detected...Closing open network connections and Removing Mapped Drive ['{0}']" -f $DriveLetter)
                $RemoveDrive = [Alphaleonis.Win32.Network.Host]::DisconnectDrive($DriveLetter, $true, $true)
            }
            Else {
                Write-Verbose -Message ("DisMount-LongShare:`t Removing Mapped Drive ['{0}']" -f $DriveLetter)   
                $RemoveDrive = [Alphaleonis.Win32.Network.Host]::DisconnectDrive($DriveLetter, $false, $true)
            }
        }
        catch {
            if($_.Exception.InnerException -match 'This network connection has files open or requests pending') {
                throw 'This network connection has files open or requests pending...use the "-Force" switch to close existing connections without warning'
            }
            else {
                throw $_
            }
        }
			
	   
    }#Process
    End {

    }#end    
}#End Function

# .ExternalHelp PSAlphafs.psm1-help.xml
function Get-LongMappedDrive {
    [CmdletBinding()]
    Param
    (   
    )    

    Begin {
     
    }
    Process {
					
        #map drive
        try {
            [Alphaleonis.Win32.Filesystem.DriveInfo]::GetDrives() | Where-Object -Property DriveType -EQ -Value 'Network'
        }
        catch {
            throw $_
        }
			
		
        
    }#Process
    End {

    }#end    
}#End Function

# .ExternalHelp PSAlphafs.psm1-help.xml
function Get-LongFreeDriveLetter {
    [CmdletBinding(DefaultParameterSetName = 'First')]
    Param
    (  
        # get the last available drive letter.   
        [Parameter(ParameterSetName = 'Last')]
        [Switch]
        $Last	 
    )    

    Begin {
     
    }
    Process {
					
        if($PSCmdlet.ParameterSetName -eq 'First') {
            #map drive
            try {
                Write-Verbose -Message ("Get-LongFreeDriveLetter:`t Listing the first free DriveLetter")
                [Alphaleonis.Win32.Filesystem.DriveInfo]::GetFreeDriveLetter()
            }
            catch {
                throw $_
            }
        }# Parameterset First
		
        if($PSCmdlet.ParameterSetName -eq 'Last') {
            #map drive
            try {
                Write-Verbose -Message ("Get-LongFreeDriveLetter:`t Listing the Last free DriveLetter")
                [Alphaleonis.Win32.Filesystem.DriveInfo]::GetFreeDriveLetter($true)
            }
            catch {
                throw $_
            }
        }# Parameterset Last		
			
		
        
    }#Process
    End {

    }#end    
}#End Function

# .ExternalHelp PSAlphafs.psm1-help.xml
function Get-LongDiskDrive {
    [CmdletBinding()]
    Param
    (   
    )    

    Begin {
     
    }
    Process {
					
        #List drive
        try {
            [Alphaleonis.Win32.Filesystem.DriveInfo]::GetDrives()
        }
        catch {
            throw $_
        }
			
		
        
    }#Process
    End {

    }#end    
}#End Function

# .ExternalHelp PSAlphafs.psm1-help.xml
function Get-LongDirectorySize {
    [CmdletBinding()]
    Param
    (
        # Specify the Path to a Folder      
        [Alias('FullName')]
        [Parameter(
            ValueFromPipelineByPropertyName,
            ValueFromPipeline,
            Position = 0)]
        [String]
        $Path = $pwd,

        [Parameter(
            ValueFromPipelineByPropertyName,
            Position = 1)]
        [String]
        [ValidateSet('KB', 'MB', 'GB', 'TB', 'PB', 'Bytes')]
        $Unit = 'Bytes',        

        # Enumerate Subdirectories
        [Switch] 
        $Recurse,

        # Include folder sizes for subfolders
        [Switch] 
        $IncludeSubfolder,        

        # Enumerate Subdirectories
        [Switch] 
        $ContinueonError                
          
    )    

    Begin {  
        $privilegeEnabler = New-Object -TypeName Alphaleonis.Win32.Security.PrivilegeEnabler -ArgumentList ([Alphaleonis.Win32.Security.Privilege]::Backup, $null)
        $dirEnumOptions = $dirEnumOptionsFSObject::SkipReparsePoints

        if ($PSBoundParameters.Containskey('Recurse') ) {
            $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::Recursive
        } 
        if ($PSBoundParameters.Containskey('ContinueonError') ) {
            $dirEnumOptions = $dirEnumOptions -bor $dirEnumOptionsFSObject::ContinueOnException
        }         
        $dirEnumOptions = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]$dirEnumOptions 
    }
    Process {

        if (-not [Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($Path)) {
            $Path = $PathFSObject::Combine($PWD, $Path.TrimStart('.\'))
        }
		
        if (-not $DirObject::Exists($Path)) {
            return
        }

        if ($IncludeSubfolder) {
            $foldernames = New-Object System.Collections.ArrayList
            $foldernames.Add($path) | Out-Null
            $DirObject::EnumerateFileSystemEntries($Path, '*', $dirEnumOptionsFSObject::Folders) | ForEach-Object {$null = $foldernames.Add($_)}

            $foldernames | 
                ForEach-Object -Process {
                $pItem = $_
                $ResultHash = $DirObject::GetProperties( $pItem, $dirEnumOptions, $PathFSFormatObject::FullPath)
                $size = $ResultHash.Size


                if ($Unit -eq 'bytes') {
                    $Size_header = 'Size'
                }
                Else {
                    $size = [System.Math]::Round($size / "1$Unit")
                    $Size_header = "Size($Unit)"
                }

                Write-Verbose -Message ("The size of the folder '{0}' is '{1} {2}'" -f $pItem, $size, $Unit)
                [PSCustomObject]@{
                    pstypename = 'PSAlphaFS.DirectorySize'
                    Path = $pItem
                    Size = $size
                    Directory = $ResultHash.Directory
                    FIle = $ResultHash.File
                    Hidden = $ResultHash.Hidden
                    Count = $ResultHash.Total                    
                    DirectoryStats = $ResultHash
                }

            }
        }
        Else {
            $PathObject = New-Object -TypeName Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $Path
		
            if (-not $PathObject.EntryInfo.IsDirectory) {
                return			
            } 
		

            $ResultHash = $DirObject::GetProperties( $Path, $dirEnumOptions, $PathFSFormatObject::FullPath)
            $size = $ResultHash.Size


            if ($Unit -eq 'bytes') {
                $Size_header = 'Size'
            }
            Else {
                $size = [System.Math]::Round($size / "1$Unit")
                $Size_header = "Size($Unit)"
            }

            Write-Verbose -Message ("The size of the folder '{0}' is '{1} {2}'" -f $Path, $size, $Unit)
            [PSCustomObject]@{
                pstypename = 'PSAlphaFS.DirectorySize'
                Path = $Path
                Size = $size
                Directory = $ResultHash.Directory
                FIle = $ResultHash.File
                Hidden = $ResultHash.Hidden
                Count = $ResultHash.Total
                DirectoryStats = $ResultHash
            }

        }
        #if not includesubfolders	      
    }#Process
    End {
        If ($privilegeEnabler) {
            $privilegeEnabler.Dispose()
        }
    }#end    
}#End Function


Set-Alias -Name ldir -Value Get-LongChildItem
