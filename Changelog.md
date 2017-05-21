2.0.0.1

Sunday, May 21, 2017

    -Copy-LongItem
     -DestinationType
        Specify whether the destination is a file or a folder. If this parameter is not specified the destination type is  inferred by           checking whether the destination item has an extension or not.
        If the destination has an extension then we assume it is a file and folder if not. As you can tell this is not always correct            because there can be folders with a period in them which can then be incorrectly inferred as a file.
        Hence it is important to specify this parameter to get accurate results.
    -Get-LongDirectorySize
        -Changed output object from a hashtable to custom PSOBJECT.
        -Unit
            -Specify the unit type for folder size : ('KB', 'MB', 'GB', 'TB', 'PB', 'Bytes' )
        -IncludeSubfolder
            -Specify this parameter to list the sizes of the subfolders including the parent

    Feature Requests:
        Issue 9 - List Size of all sub directories in Get-LongDirectorySize

    Fixed Issues:
        Issue 3 - Copy-LongItem over the top of an existing file
        Issue 4 - Copy-LongItem when destination is a folder path
        Issue 6 - You cannot call a method on a null-valued expression


        v2.0.0.0
        - Major Release with numerous improvements and enhancements
        - Module is now compatible with PS v3
        - Module now uses Alphafs.dll v2.1.2(latest at the moment of this writing)
        - All cmdlets work with relative paths
        - New features\improvements in Existing Cmdlets
            - Get-LongChildItem
                - Lists directory items immediately and dosent wait until it is done enumerating the complete directory tree
                - By default ignores errors(access denied) encountered during directory enumeration.
                - Uses a simplified logic to enumerate the filesystem and work with include and exclude parameters                
                - Symlinks are now shown by default and the cmdlet optionally adds a switch parameter(-SkipSymbolicLink) to hide listing them.
                - The mode property now indicates whether a particular file or directory is a SymbolicLink
                - filehash algorith SHA256
                - Additional properties added
                    - FileHash
                    - Target
                    - PSIsContainer
                    - LinkType                      
                    - IsPathLong        
                    - IsSymbolicLink    
                    - IsDirectory       
                    - IsCompressed      
                    - IsHidden          
                    - IsEncrypted       
                    - IsMountPoint      
                    - IsOffline      
            - New-LongItem
                - Create Symbolic Links for files and folders
                - Create HardLinks for files 
                - Create text files and optionally add text content( can be an array of strings) with user specified encoding                   
            - Remove-LongItem
                - Added the ability to remove a file or folder with a trailing space in the name    
            - Rename-LongItem
                - Added the ability to rename\change file extension while retaining the file name.(-NewExtension Parameter)                               
            - Copy-LongChildItem
                - New Switch Parameters
                    - CopySymbolicLink 
                        - (If the source file is a symbolic link, destination is also a symbolic link pointing to the same file)
                        - Not working at this moment.(github issue raised - https://github.com/alphaleonis/AlphaFS/issues/292)
                    - NoBuffering  
                        - (copy is performed using unbuffered I/O. Recommended for very large file transfers.)   
                    - AllowDecryptedDestination
                        - (An attempt to copy an encrypted file will succeed even if the destination copy cannot be encrypted.)                                    
        - New Cmdlets    
            - Mount-LongShare
                - Map Network share with or without credentials.  
            - DisMount-LongShare
                - Remove mapped drive.                                 
            - Get-LongMappedDrive
                - List mapped drives on localmachine. 
                - use format-list to view the UncPath property which shows the sharepath 
            - Get-LongFreeDriveLetter
                - Be default gets the first free driveletter and with the -last parameter will list the last free drive letter.  
            - Get-LongDiskDrive
                - Gets diskspace stats(used\free\percent).  
            - Get-LongDirectorySize
                - Gets the size of a folder.    
                - Specify -Recurse to include subfolders and files  
                - Specify -ContinueonError to ignore errors(may result in an incorrect directory size)   
