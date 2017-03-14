Function GetDotNetVer {
    #https://gallery.technet.microsoft.com/scriptcenter/Detect-NET-Framework-120ec923
    #modified to work with this module
    [cmdletbinding()]
    param()
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



    if($regKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Default')) {
        if ($netRegKey = $regKey.OpenSubKey($dotNetRegistry)) {
            foreach ($versionKeyName in $netRegKey.GetSubKeyNames()) {
                if ($versionKeyName -match '^v[123]') {
                    $versionKey = $netRegKey.OpenSubKey($versionKeyName)
                    $version = [version]($versionKey.GetValue('Version', ''))
                    '{0}.{1}' -f $version.Major,$version.minor
                }
            }
        }

        if ($net4RegKey = $regKey.OpenSubKey($dotNet4Registry)) {
            if(-not ($net4Release = $net4RegKey.GetValue('Release'))) {
                $net4Release = 30319
            }
            $dotNet4Builds[$net4Release]

        }
    }#open reg key


}#end function
  

$installed_dotnetversion = GetDotNetVer -ErrorAction SilentlyContinue  | sort -Descending | Select-Object -First 1
$libpath_parent = join-path (Split-Path $PSScriptRoot -Parent) -ChildPath lib

if([string]::IsNullOrEmpty($installed_dotnetversion)) {
    $libpath = Join-Path $libpath_parent -ChildPath 'net40\AlphaFS.dll'
}
else {
    switch($installed_dotnetversion) {
        '3.5'    {$libpath = Join-Path $libpath_parent -ChildPath 'net35\AlphaFS.dll';break}
        '4.0'    {$libpath = Join-Path $libpath_parent -ChildPath 'net40\AlphaFS.dll';break}
        '4.5.0'  {$libpath = Join-Path $libpath_parent -ChildPath 'net45\AlphaFS.dll';break}
        '4.5.1'  {$libpath = Join-Path $libpath_parent -ChildPath 'net451\AlphaFS.dll';break}
        '4.5.2'  {$libpath = Join-Path $libpath_parent -ChildPath 'net452\AlphaFS.dll';break}
        '4.6.1'  {$libpath = Join-Path $libpath_parent -ChildPath 'net452\AlphaFS.dll';break}
        '4.6.2'  {$libpath = Join-Path $libpath_parent -ChildPath 'net452\AlphaFS.dll';break}
        default  {$libpath = Join-Path $libpath_parent -ChildPath 'net40\AlphaFS.dll'}
    }
    
}# if installed_dotnetversion


# Load the AlphaFS assembly
Add-Type -Path $libpath


Function FormatDriveLetter ([string]$DriveLetter) {
    #Format driveletter
    if($DriveLetter -notmatch '[aA-zZ]:\\') {
        $DriveLetter = "$DriveLetter`:\"
    }
    return $DriveLetter
}

Function CheckMappedDriveExists ([string]$DriveLetter, [String]$NetworkShare) {

    $DriveLetterFormatted = FormatDriveLetter $DriveLetter
    $isDrivePresent = [Alphaleonis.Win32.Filesystem.DriveInfo]::GetDrives() | Where-Object { ($_.DriveType -eq  'Network') -and ($_.DriveLetter -eq  $DriveLetterFormatted) -and ($_.UncPath -eq  $NetworkShare) }
    if ($isDrivePresent) {
        Write-Verbose "MappedDrive ['$DriveLetterFormatted'] for NetworkShare ['$NetworkShare'] exists."
        return $true
    }
    else {
        Write-Verbose "MappedDrive ['$DriveLetterFormatted'] for NetworkShare ['$NetworkShare'] does not exist."
        return $false
    }
}


# function to match file extensions
function CompareExtension([string[]]$Extension, $Filename) {
    foreach ($p in $Extension) {
        $wc = New-Object System.Management.Automation.WildcardPattern -ArgumentList ($p, [System.Management.Automation.WildcardOptions]::IgnoreCase) 
        if ($wc.IsMatch($Filename)) {return $true}
    }
    
}



Function newlongitemhelper {
    #[cmdletbinding()]
    param
    (
        [string]$Filename,
        [String]$itemtype,
        $value,
        [String]$Encoding,
        [Switch]$Force
    )

		
    $FilePath = $Filename
    $Leaf = $PathFSObject::GetFileName($FilePath) 
    $Parent  = $PathFSObject::GetDirectoryName($FilePath)
    $isFile = if($PathFSObject::HasExtension($Leaf) ){$true}else {$false} 	
				
				
				
    # Create the parent
    if (-not ($DirObject::Exists($Parent)) ) {
        $DirObject::CreateDirectory($Parent) | Out-Null
    } 						
			
    if($ItemType -eq 'File') {
        # check if there is an existing folder with the same name as the file we are trying to create
        if($DirObject::Exists($FilePath)) {
            Write-Warning ("New-LongItem: A Directory with the same name '{0}' already exists." -f $FilePath)
            return
        }				
        #Create a file
        if($FileObject::Exists($FilePath)) {
            if($Force) {                          
						     
                if ($Value) {
                    $FileObject::WriteAllLines($FilePath, $value, [System.Text.Encoding]::$Encoding, $PathFSFormatObject::FullPath)
                }
                Else {
                    $FileObject::Create($FilePath, $PathFSFormatObject::FullPath) | Out-Null
                }
							
                New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $FilePath, $PathFSFormatObject::FullPath
													
            }
            Else {
                Write-Warning ("New-LongItem: The file '{0}' already exists. Use '-Force' to overwrite" -f $FilePath)
            }
            
        }# file exists
        Else {
						     
            if ($Value) {
                $FileObject::WriteAllLines($FilePath, $value, [System.Text.Encoding]::$Encoding, $PathFSFormatObject::FullPath)
            }
            Else {
                $FileObject::Create($FilePath, $PathFSFormatObject::FullPath) | Out-Null
            }
							
            New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $FilePath, $PathFSFormatObject::FullPath
						
						          
        }# if file dosent exist
					  
    }# if itemtype is file
    Elseif($ItemType -eq 'Directory') {
					
        if($FileObject::Exists($FilePath)) {
            Write-Warning ("New-LongItem: A file with the same name '{0}' already exists." -f $FilePath)
            return
        }
        if($DirObject::Exists($FilePath)) {
            if($Force) {
                $DirObject::CreateDirectory($FilePath)
            }
            Else {
                Write-Warning ("New-LongItem: The Directory '{0}' already exists. Use '-Force' to overwrite" -f $FilePath)
            }
            
        }# folder exists
        Else {
            $DirObject::CreateDirectory($FilePath)                
        }				
    }# itemtype is directory	
    Elseif($ItemType -eq 'HardLink') {
				
        if($Value) {
					
            if(-not [Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($value)) {
                $value = $PathFSObject::Combine($PWD, $value.TrimStart('.\'))
            }
				
            $ExistingFile_Leaf = $PathFSObject::GetFileName($value) 
            $ExistingFile_info = New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $Value
            $ExistingDirectory_info = New-Object Alphaleonis.Win32.Filesystem.DirectoryInfo -ArgumentList $Value
						  
            if(-not $ExistingFile_info.Exists) {
                if($ExistingDirectory_info.Exists) {
                    Write-Warning ("New-LongItem: The Hardlink to be created cannot be a folder '{0}'" -f $FilePath) 
                    return
                }
                Else {
                    Write-warning ("New-LongItem:`tHardLink Link Target '{0}' does not exist" -f $Value)
                    return
								  
                }

            }#if the target does not exist						  					  
						  						
							
            if($FileObject::Exists($FilePath)) {
                if($Force) {
                    $FileObject::Delete($FilePath, $true, $PathFSFormatObject::FullPath)
                    $FileObject::CreateHardlink($FilePath, $value) 								
                }
                Else {
                    Write-Warning ("New-LongItem: The Hardlink '{0}' already exists. Use -Force to overwrite" -f $FilePath)
                    return									
                }	
							  

						
            }# file exists								
            else {
                Write-Verbose ("New-LongItem:`tCreating Symbolic Link ['{0}'] for ['{1}']" -f $FilePath,$Value)
                $FileObject::CreateHardlink($FilePath, $value)   						
            }
								   						
        }
        Else {
            Write-Warning ("New-LongItem: Please provide the target for The Hardlink '{0}' " -f $FilePath)
								  
        }# if no value is provided					
                     
    }# if Hardlink				
			
    Elseif($ItemType -eq 'SymbolicLink') {	
					
        if($Value) {
					
            if(-not [Alphaleonis.Win32.Filesystem.Path]::IsPathRooted($value)) {
                $value = $PathFSObject::Combine($PWD, $value.TrimStart('.\'))
            }
				
            $ExistingFile_Leaf = $PathFSObject::GetFileName($value) 
            $ExistingFile_info = New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $Value
            $ExistingDirectory_info = New-Object Alphaleonis.Win32.Filesystem.DirectoryInfo -ArgumentList $Value
						  
            if( (-not $ExistingFile_info.Exists) -and (-not $ExistingDirectory_info.Exists) ) {
                Write-warning ("New-LongItem:`tSymbolic Link Target '{0}' does not exist" -f $Value)
                return
            }						  					  
						  
            $isFile_Real = if($ExistingFile_info.EntryInfo.IsDirectory){$false}else {$true}
							
            if($isFile_Real) {
                $linktarget = $linktype::File
								
            }
            Else {
                $linktarget = $linktype::Directory
								
            }							
							
            $checkfortarget_file = $FileObject::Exists($FilePath)
            $checkfortarget_dir = $DirObject::Exists($FilePath)
						  
            if($checkfortarget_file -or $checkfortarget_dir) {
								
                if($Force) {
                    try {
                        $FileObject::Delete($FilePath, $true, $PathFSFormatObject::FullPath)
                    }
                    Catch {
                        try {
                            $DirObject::Delete($FilePath, $true, $PathFSFormatObject::FullPath)
                        }
                        catch {
                            throw $_
                        }
										
                    }
                    $FileObject::CreateSymbolicLink($FilePath, $value, $linktarget) 								
                }
                Else {
                    Write-Warning ("New-LongItem: The SymbolicLink '{0}' already exists.Use -Force to overwrite" -f $FilePath)
                    return									
                }								
						
            }# file exists								
            else {
                Write-Verbose ("New-LongItem:`tCreating Symbolic Link ['{0}'] for ['{1}']" -f $FilePath,$Value)
                $FileObject::CreateSymbolicLink($FilePath, $value, $linktarget)   						
            }
								   						
        }
        Else {
            Write-Warning ("New-LongItem: Please provide the target for The SymbolicLink '{0}' " -f $FilePath)
								  
        }# if no value is provided
							
					
    }# if itemtype is symboliclink
    Else {
        #best effort to create a file or directory
        if($isFile) {
					
            # check if there is an existing folder with the same name as the file we are trying to create
            if($DirObject::Exists($FilePath)) {
                Write-Warning ("New-LongItem: A Directory with the same name '{0}' already exists." -f $FilePath)
                return
            }				
            #Create a file
            if($FileObject::Exists($FilePath)) {
                if($Force) {                          
						     
                    if ($Value) {
                        $FileObject::WriteAllLines($FilePath, $value, [System.Text.Encoding]::$Encoding, $PathFSFormatObject::FullPath)
                    }
                    Else {
                        $FileObject::Create($FilePath, $PathFSFormatObject::FullPath) | Out-Null
                    }
							
                    New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $FilePath, $PathFSFormatObject::FullPath
													
                }
                Else {
                    Write-Warning ("New-LongItem: The file '{0}' already exists. Use '-Force' to overwrite" -f $FilePath)
                }
            
            }# file exists
            Else {
						     
                if ($Value) {
                    $FileObject::WriteAllLines($FilePath, $value, [System.Text.Encoding]::$Encoding, $PathFSFormatObject::FullPath)
                }
                Else {
                    $FileObject::Create($FilePath, $PathFSFormatObject::FullPath) | Out-Null
                }
							
                New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $FilePath, $PathFSFormatObject::FullPath
						
						          
            }# if file dosent exist					
					    
        }# if file
        else {
            if($FileObject::Exists($FilePath)) {
                Write-Warning ("New-LongItem: A file with the same name '{0}' already exists." -f $FilePath)
                return
            }
            if($DirObject::Exists($FilePath)) {
                if($Force) {
                    $DirObject::CreateDirectory($FilePath)
                }
                Else {
                    Write-Warning ("New-LongItem: The Directory '{0}' already exists. Use '-Force' to overwrite" -f $FilePath)
                }
            
            }# folder exists
            Else {
                $DirObject::CreateDirectory($FilePath)                
            }	
					
					
        }# if not file but a folder
					
				
    }#if itemtype is not specified

}
	
