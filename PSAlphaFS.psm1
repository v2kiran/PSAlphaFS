
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
        if($PSBoundParameters.Containskey('Include') )
        {
            $Include | ForEach-Object {$Include_string += "`$_.Name -like '$_' -or " }
            $Include_string = $Include_string -replace '-or\s$',''        
        }
        if($PSBoundParameters.Containskey('Exclude') )
        {
            $Exclude | ForEach-Object {$Exclude_string += "`$_.Name -notlike '$_' -and " }
            $Exclude_string = $Exclude_string -replace '-and\s$',''      
        }
        if($PSBoundParameters.Containskey('Include') -and $PSBoundParameters.ContainsKey('Exclude') )
        {
            $Inc_Exc_String = '(' + $Include_string + ')' + ' -AND ' +  '(' + $Exclude_string + ')'     
        }        


 
        $privilege = [Alphaleonis.Win32.Security.Privilege]::Backup
        $privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler($privilege)       
        
    }
    Process
    {
        foreach ($pItem in $Path)
        {
            
            $PathObject = New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $pItem
            $Attributes = ($PathObject.Attributes  -split ',').trim() 
    
            if($Attributes -contains 'Directory')
            {
                if ($Directory)
                {
                     $dirEnumOptions = $dirEnumOptions -bor [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::Folders 

                    foreach ($N in @($DirObject::EnumerateFileSystemEntries($pItem, $FIlter, $dirEnumOptions)))
                    {
                        if($Include -and (-not $Exclude) )
                        {     
                            if($Name)
                            {
                                if($Recurse)
                                {
                                    $newpath = $pItem -Replace '\\','\\'

                                    (New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Include_string) } $_ ) |
                                    Select-Object -ExpandProperty FullName )  -replace "$newpath\\" , ''                                   
                                }
                                Else
                                {
                                    New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                    Where-Object (& {[scriptblock]::create($Include_string) } $_ ) |
                                    Select-Object -ExpandProperty Name                                  
                                }

                            }
                            Else
                            {
                                New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                Where-Object (& {[scriptblock]::create($Include_string) } $_ )                         
                            }        
                        

                        }
                        elseif($Exclude -and (-not $Include) )
                        {   
                            if($Name)
                            {
                                     if($Recurse)
                                    {
                                        $newpath = $pItem -Replace '\\','\\'

                                        (New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Exclude_string) } $_ ) |
                                        Select-Object -ExpandProperty FullName )  -replace "$newpath\\" , ''                                   
                                    }
                                    Else
                                    {
                                        New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Exclude_string) } $_ ) |
                                        Select-Object -ExpandProperty Name                                  
                                    }                       
                            }
                            Else
                            {
                                New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                Where-Object (& {[scriptblock]::create($Exclude_string) } $_ )                         
                            }                                       
                
                        } 
                        Elseif($Include -and $Exclude)
                        {   
                            if($Name)
                            {
                                     if($Recurse)
                                    {
                                        $newpath = $pItem -Replace '\\','\\'

                                        (New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Inc_Exc_String) } $_ ) |
                                        Select-Object -ExpandProperty FullName )  -replace "$newpath\\" , ''                                   
                                    }
                                    Else
                                    {
                                        New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Inc_Exc_String) } $_ ) |
                                        Select-Object -ExpandProperty Name                                  
                                    }                       
                            }
                            Else
                            {
                                New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                Where-Object (& {[scriptblock]::create($Inc_Exc_String) } $_ )                         
                            }                                       
                
                        }                          
                        Else
                        {
                            if($Name)
                            {
                                    if($Recurse)
                                    {
                                        $newpath = $pItem -Replace '\\','\\'

                                        (New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Select-Object -ExpandProperty FullName )  -replace "$newpath\\" , ''                                   
                                    }
                                    Else
                                    {
                                        New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Select-Object -ExpandProperty Name                                  
                                    }                      
                            }
                            Else
                            {
                                New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N
                         
                            }                     
                        
                        }#if not include or exclude
                    
                    }#foreach file or folder
            
                }#if folder
                Elseif($File)
                {
                    $dirEnumOptions = $dirEnumOptions -bor [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::Files 
                   foreach ($N in @($DirObject::EnumerateFileSystemEntries($pItem, $FIlter, $dirEnumOptions)))
                    {
                        if($Include -and (-not $Exclude) )
                        {                 
                            if($Name)
                            {
                                     if($Recurse)
                                    {
                                        $newpath = $pItem -Replace '\\','\\'

                                        (New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Include_string) } $_ ) |
                                        Select-Object -ExpandProperty FullName )  -replace "$newpath\\" , ''                                   
                                    }
                                    Else
                                    {
                                        New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Include_string) } $_ ) |
                                        Select-Object -ExpandProperty Name                                  
                                    }                      
                            }
                            Else
                            {
                                New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                Where-Object (& {[scriptblock]::create($Include_string) } $_ )                         
                            }                         

                        }
                        elseif($Exclude -and (-not $Include) )
                        {                     
                            if($Name)
                            {
                                     if($Recurse)
                                    {
                                        $newpath = $pItem -Replace '\\','\\'

                                        (New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Exclude_string) } $_ ) |
                                        Select-Object -ExpandProperty FullName )  -replace "$newpath\\" , ''                                   
                                    }
                                    Else
                                    {
                                        New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Exclude_string) } $_ ) |
                                        Select-Object -ExpandProperty Name                                  
                                    }                      
                            }
                            Else
                            {
                                New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                Where-Object (& {[scriptblock]::create($Exclude_string) } $_ )                         
                            }                
                        } 
                        Elseif($Include -and $Exclude)
                        {   
                            if($Name)
                            {
                                     if($Recurse)
                                    {
                                        $newpath = $pItem -Replace '\\','\\'

                                        (New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Inc_Exc_String) } $_ ) |
                                        Select-Object -ExpandProperty FullName )  -replace "$newpath\\" , ''                                   
                                    }
                                    Else
                                    {
                                        New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Inc_Exc_String) } $_ ) |
                                        Select-Object -ExpandProperty Name                                  
                                    }                        
                            }
                            Else
                            {
                                New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                Where-Object (& {[scriptblock]::create($Inc_Exc_String) } $_ )                         
                            }                                       
                
                        }                                             
                        Else
                        {
                            if($Name)
                            {
                                if($Recurse)
                                {
                                    $newpath = $pItem -Replace '\\','\\'

                                    (New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                    Select-Object -ExpandProperty FullName )  -replace "$newpath\\" , ''                                   
                                }
                                Else
                                {
                                    New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                    Select-Object -ExpandProperty Name                                  
                                }                       
                            }
                            Else
                            {
                                New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N.fullpath
                         
                            } 
                        }
                    }#foreach name            
                }#else file
                Else
                {
                    $dirEnumOptions = $dirEnumOptions -bor [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::FilesAndFolders 

                    foreach ($N in @($DirObject::EnumerateFileSystemEntries($pItem, $FIlter, $dirEnumOptions)))
                    {
                            if($Include -and (-not $Exclude) )
                            {                 
                                if($Name)
                                {
                                     if($Recurse)
                                    {
                                        $newpath = $pItem -Replace '\\','\\'

                                        (New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                            Where-Object (& {[scriptblock]::create($Include_string) } $_ ) |
                                        Select-Object -ExpandProperty FullName )  -replace "$newpath\\" , ''                                   
                                    }
                                    Else
                                    {
                                        New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Include_string) } $_ ) |
                                        Select-Object -ExpandProperty Name                                  
                                    }
                       
                                }
                                Else
                                {
                                    New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                    Where-Object (& {[scriptblock]::create($Include_string) } $_ )                         
                                }                           

                            }
                            elseif($Exclude -and (-not $Include) )
                            {                     
                                if($Name)
                                {                                   
                                     if($Recurse)
                                    {
                                        $newpath = $pItem -Replace '\\','\\'

                                        (New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                            Where-Object (& {[scriptblock]::create($Exclude_string) } $_ ) |
                                        Select-Object -ExpandProperty FullName )  -replace "$newpath\\" , ''                                   
                                    }
                                    Else
                                    {
                                        New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Exclude_string) } $_ ) |
                                        Select-Object -ExpandProperty Name                                  
                                    }                                     
                                                                                           
                                }
                                Else
                                {
                                    New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                    Where-Object (& {[scriptblock]::create($Exclude_string) } $_ )                         
                                }                
                            }
                            Elseif($Include -and $Exclude)
                            {   
                                if($Name)
                                {
 
                                     if($Recurse)
                                    {
                                        $newpath = $pItem -Replace '\\','\\'

                                        (New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                            Where-Object (& {[scriptblock]::create($Inc_Exc_String) } $_ ) |
                                        Select-Object -ExpandProperty FullName )  -replace "$newpath\\" , ''                                   
                                    }
                                    Else
                                    {
                                        New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Where-Object (& {[scriptblock]::create($Inc_Exc_String) } $_ ) |
                                        Select-Object -ExpandProperty Name                                  
                                    }                                   
                                                        
                                }
                                Else
                                {
                                    New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                    Where-Object (& {[scriptblock]::create($Inc_Exc_String) } $_ )                         
                                }                                       
                
                            }                                                  
                            Else
                            {
                                if($Name)
                                {
                                    if($Recurse)
                                    {
                                        $newpath = $pItem -Replace '\\','\\'

                                        (New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Select-Object -ExpandProperty FullName )  -replace "$newpath\\" , ''                                   
                                    }
                                    Else
                                    {
                                        New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N | 
                                        Select-Object -ExpandProperty Name                                  
                                    }
                                                     
                                }
                                Else
                                {
                                    New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $N
                               
                                } 
                        
                            }
                        }#foreach name 
               
                }#else process both files & folders
            
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
        $privilege = [Alphaleonis.Win32.Security.Privilege]::Backup
        $privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler($privilege)         
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
    }
    Process
    {       
        $Parent = Split-Path -Path $Path -Parent
        $NewPath = Join-Path -Path $Parent -ChildPath $NewName
        $ReplaceExisting = [Alphaleonis.Win32.Filesystem.MoveOptions]::ReplaceExisting
        
        if($PSCmdlet.ShouldProcess($NewPath,"Rename File: $Path") )
        {
            if($Force)
            {
                Write-Verbose ("Rename-LongItem:`n {0} `n`t`t{1}`n" -f $Path,$NewPath)
                [Alphaleonis.Win32.Filesystem.Directory]::Move($Path, $NewPath,$ReplaceExisting)              
            }
            Else
            {
                if([Alphaleonis.Win32.Filesystem.Directory]::Exists($NewPath))
                {
                    Write-Warning ("Rename-LongItem:`tAn item with the same name already exists at '{0}'.`nUse '-Force' to overwrite" -f $NewPath)
                }
                Else
                {
                    Write-Verbose ("Rename-LongItem:`n {0} `n`t`t{1}`n" -f $Path,$NewPath)
                    [Alphaleonis.Win32.Filesystem.Directory]::Move($Path, $NewPath)                 
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
        $Force                  
    )

    Begin
    {
        $DirObject = [Alphaleonis.Win32.Filesystem.Directory]
        $FileObject = [Alphaleonis.Win32.Filesystem.File]
        $copyOptions = [Alphaleonis.Win32.Filesystem.CopyOptions]::FailIfExists
    }
    Process
    {       
        $PathObject = New-Object Alphaleonis.Win32.Filesystem.FileInfo -ArgumentList $Path
        $Attributes = ($PathObject.Attributes  -split ',').trim() 
        
        $basename = Split-Path -Path $Path -Leaf 
        $dBasename = Split-Path -Path $Destination -Leaf
        $dParent =  Split-Path -Path $Destination -Parent
        
        
        
        if($dBasename -match '.*\.\w{2,4}$')
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
                $Destination = Join-Path -Path $Destination -ChildPath $basename  
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
        $privilege = [Alphaleonis.Win32.Security.Privilege]::Backup
        $privilegeEnabler = New-Object Alphaleonis.Win32.Security.PrivilegeEnabler($privilege)       
        
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
                $DirObject::Delete($Path, $RemoveAll, $IgnoreReadOnly)            
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
                    $DirObject::Delete($Path, $RemoveAll, $IgnoreReadOnly)                
                }
            
            
            }#if not recurse 
                 
        }
        Else
        {           
             try
             {
                 Write-Verbose ("Remove-LongItem:`t Deleting file '{0}'..." -f $Path)
                 $FileObject::Delete($Path, $IgnoreReadOnly)  
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
          
        [ValidateSet('Directory','File')]
        [String]
        $ItemType,

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

    }
    Process
    {       

        
        foreach ($pItem in $Path)
        {
            $Baseobj = Split-Path -Path $pItem -Leaf 
            $Parent  = Split-Path -Path $pItem -Parent
            $isFile = [regex]::Match($Baseobj , '\.\w{2,4}$') | Select-Object -ExpandProperty Success            
        
            if($PSCmdlet.ParameterSetName -eq 'Path')
            {
         
                if( ($ItemType -eq 'File') -or ($isFile) )
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
                            $FileObject::Create($FilePath) | Out-Null
                            $FileinfoObject::new($FilePath)
                        }
                        Else
                        {
                            Write-Warning ("New-LongItem: The file '{0}' already exists. Use '-Force' to overwrite" -f $FilePath)
                        }
            
                    }# file exists
                    Else
                    {
                        $FileObject::Create($FilePath)   | Out-Null
                        $FileinfoObject::new($FilePath)             
                    }
                     
                }#isFile
                Elseif( ($ItemType -eq 'Directory') -or  (-not $isFile) )
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
           
            }#pscmdlet is path
        
            if($PSCmdlet.ParameterSetName -eq 'Name')
            {
 
                if($ItemType -eq 'File')
                {
                    $FilePath = Join-Path -Path $pItem -ChildPath $Name
                    
                    if (-not ($DirObject::Exists($Parent)) )
                    {
                        $DirObject::CreateDirectory($Parent)
                    }                    
                
                    if($FileObject::Exists($FilePath))
                    {
                        if($Force)
                        {
                            $FileObject::Create($FilePath) | Out-Null
                            $FileinfoObject::new($FilePath)
                        }
                        Else
                        {
                            Write-Warning ("New-LongItem: The file '{0}' already exists. Use '-Force' to overwrite" -f $FilePath)
                        }
            
                    }# file exists
                    Else
                    {
                        $FileObject::Create($FilePath)  | Out-Null
                        $FileinfoObject::new($FilePath)             
                    }
                     
                }#isFile
                Elseif($ItemType -eq 'Directory')
                {
                    $FolderPath = Join-Path -Path $pItem -ChildPath $Name
                
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
                 
            }#pscmdlet is Name
        
        
        }#foreach pitem
                        

    }#Process
    End
    {
    
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
    }
    Process
    {       
        $Parent = Split-Path -Path $Path -Parent
        $basename = Split-Path -Path $Path -Leaf
        $dParent = Split-Path -Path $Destination -Parent
        $dBasename = Split-Path -Path $Destination -Leaf
        
        if($Basename -match '\.\w{2,4}$')
        {
            #Basename is a file so destination has to be a file
            $Basename_isFile = $true
            
            if ($dBasename -match '\.\w{2,4}$')
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
            if ($dBasename -match '\.\w{2,4}$')
            {
                Write-Warning ("Move-LongItem:`tThe source is a directory so please specify a directory as the destination")
                break

            }            
            Else
            {
                
                $Destination_isDirectory = $true

                if($DirectoryObject::Exists($Destination ))
                {
                    $NewPath = Join-Path -Path $Destination -ChildPath $basename 
                }
                Else
                {
                    $NewPath = $Destination
                }
                
                
                
            }             
            


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



Set-Alias -Name ldir -Value Get-LongChildItem
Set-Alias -Name lgci -Value Get-LongChildItem