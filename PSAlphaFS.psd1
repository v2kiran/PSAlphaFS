#
# Module manifest for module 'PSAlphaFS'
#
# Generated by: Kiran Reddy
#
# Generated on: 9/06/2015
#

@{

# Script module or binary module file associated with this manifest.
 RootModule = 'PSAlphaFS.psm1'

# Version number of this module.
ModuleVersion = '2.0.0.0'

# ID used to uniquely identify this module
GUID = '436fc4df-d981-4e21-9d0c-a892c3bc9fb6'

# Author of this module
Author = 'Kiran Reddy'

# Company or vendor of this module
CompanyName = 'Personal'

# Copyright statement for this module
Copyright = '(c) 2016 Kiran Reddy. All rights reserved.'

# Description of the functionality provided by this module
 Description = 'Powershell AlphaFS Module'

# Minimum version of the Windows PowerShell engine required by this module
 PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
 DotNetFrameworkVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
 #RequiredAssemblies = @('lib\AlphaFS.dll')

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
 ScriptsToProcess = @('helpers\PSAlphaFSHelpers.ps1')

# Type files (.ps1xml) to be loaded when importing this module
 TypesToProcess = @('TypeData\PSAlphaFS.Types.ps1xml')

# Format files (.ps1xml) to be loaded when importing this module
 FormatsToProcess = @('TypeData\PSAlphaFS.Format.ps1xml')

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
#FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = @('Get-LongChildItem','Get-LongItem','Move-LongItem','Rename-LongItem',
'Copy-LongItem','Get-LongDirectorySize','Mount-LongShare','Dismount-LongShare',
'Get-LongMappedDrive','Get-LongFreeDriveLetter','Get-LongDiskDrive'
)

# Variables to export from this module
#VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = @('ldir')

# List of all modules packaged with this module.
ModuleList = @('PSAlphaFS.psm1')

# List of all files packaged with this module
 FileList = @('Alphafs.dll','PSAlphaFS.psm1','PSAlphaFS.psd1','PSAlphaFS.Types.ps1xml','PSAlphaFS.Format.ps1xml')

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{
    PSData = @{
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('AlphaFS', 'FileSystem', 'longfile', 'longfiles', 'MAX_PATH')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/v2kiran/PSAlphaFS/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/v2kiran/PSAlphaFS'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '
        v2.0.0.0
        - Major Release with numerous improvements and enhancements
        - Module is now compatible with PS v3
        - Module now uses Alphafs.dll v2.1.2(latest at the moent of this writing)
        - All cmdlets should now work with relative paths
        - New features\improvements in Existing Cmdlets
            - Get-LongChildItem
                - Lists directory items immediately and dosent wait until it is done enumerating the complete directory tree
                - By default ignores errors(access denied) encountered during directory enumeration.
                - Uses a simplified logic to enumerate the filesystem and work with include and exclude parameters                
                - Symlinks are now shown by default and the cmdlet optionally adds a switch parameter(-SkipSymbolicLink) to hide listing them.
                - The mode property now indicates whether a particular file or directory is a SymbolicLink
                - Additional properties added
                    - FileHash
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

        '
    } # End of PSData hashtable
} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

