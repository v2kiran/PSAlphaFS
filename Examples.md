NAME
    Copy-LongItem
    
SYNOPSIS
    Copies an item from one location to another.
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Copy-LongItem -Path C:\temp\drivers.txt -Destination C:\temp\folder1 -Verbose
    
    
    This command copies the drivers.txt file to the C:\temp\folder1 directory. 'folder1' is created if it dosent exist.
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Copy-LongItem C:\temp\logfiles\ -Destination C:\temp\newlogs -Verbose
    
    
    This command copies the contents of the C:\Logfiles directory recursively to the C:\temp\newLogs directory. It creates the \newLogs subdirectory if it does not already exist.
        -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Copy-LongItem C:\temp\logfiles -Destination C:\temp\newlogs -Verbose
    
    
    This command copies the entire folder C:\Logfiles recursively to the C:\temp\newLogs. It creates the "newLogs" subdirectory if it does not already exist.
        -------------------------- EXAMPLE 4 --------------------------
    
      $params = 
     @{
            Path =                  'C:\temp\test-psalphafs\source\file-01.txt'
            Destination  =       'C:\temp\test-psalphafs\destination.dir1'
            Force  =               $false
            verbose =            $true
            destinationtype = 'Directory'
     }

    Copy-LongItem @params

    We use "splatting" to pass the parameters as a table to copy-longitem.  file 'file-01.txt' is copied to destination directory           'destination.dir1'. The destination directory 'destination.dir1' will be created if it dosent already exist.

    Note: The destination "destination.dir1" is a folder containing a period in its name and hence we also specify the "destinationtype"    parameter.
    If  destinationtype parameter is not specified the destination would be treated as a file.
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Copy-LongItem -Path C:\temp\win2012R2.iso -Destination C:\temp\2012R2.iso -Verbose -NoBuffering
    
    
    attempts to copy the iso file using unbuffered I/O

NAME
    DisMount-LongShare
    
SYNOPSIS
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>DisMount-LongShare -DriveLetter F:
    
    
    Unmounts any network share that is mounted on F:
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>DisMount-LongShare -DriveLetter G -Force
    
    
    Any open files or connections to the G drive are dropped and then the G drive is unmounted .

NAME
    Get-LongChildItem
    
SYNOPSIS
    Gets the items and child items in one or more specified locations.
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-LongChildItem -Path C:\temp -Filter d*.txt -Recurse
    
    
       Directory: C:\temp
    
    Mode                  LastWriteTime          Length Name                                                                         
    ----                  -------------          ------ ----                                                                         
    File            6/27/2015  11:44 AM            1488 drivers.txt                                                                  
    File             7/3/2015  12:30 PM              72 dupes.txt                                                                    
    
    
       Directory: C:\temp\folder4\DSC06252
    
    Mode                  LastWriteTime          Length Name                                                                         
    ----                  -------------          ------ ----                                                                         
    File            8/23/2015   6:24 PM              93 dupes.txt
    
    
    This command gets all of the files that begin with the letter 'd' followed by any character(s) but end with the extension 'TXT' in the path directory and its subdirectories. The Recurse parameter directs Windows 
    PowerShell to get objects recursively, and it indicates that the subject of the command is the specified directory and its contents.
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-LongChildItem –Path C:\temp -Include *.txt -Exclude A*,c*,e*
    
    
    This command lists the .txt files in the temp directory, except for those whose names start with the letter A or C or E.
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-LongChildItem –Path C:\windows\System32\WindowsPowerShell -Filter about*.txt  -Recurse -Name
    
    
    This command gets only the names of all Text files that begin with 'about' in the C:\windows\System32\WindowsPowerShell directory and its subdirectories.
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>Get-LongChildItem –Path C:\temp -Name -Directory -Recurse
    
    
    This command gets only the names of all directories in the C:\temp directory and its subdirectories.
    -------------------------- EXAMPLE 5 --------------------------
    
    PS C:\>Get-LongChildItem -Path C:\temp -Recurse | Where PathLength -gt 260
    
    
    This command gets all files and folders recursively. The output is then piped to Where-object which displays only those files whose length exceeds the windows API 260 character length limitation.
    -------------------------- EXAMPLE 6 --------------------------
    
    PS C:\>Get-LongChildItem -Path D:\Temp
    
    
       Directory: D:\Temp
    
    Mode                  LastWriteTime          Length Name                                                                                                                                         
    ----                  -------------          ------ ----                                                                                                                                         
    Directory      12/5/2016   9:44 PM                 123                                                                                                                                          
    File           12/23/2016   2:46 PM            9491 temp.ps1                                                                                                                                                           
           SymLink-f      12/7/2016   7:21 PM               0 MySymLinkFile.txt                                                                                                                            
    SymLink-f      12/17/2016  12:38 PM               0 MySymLinkFile2.txt                                                                                                                                                 
           SymLink-d      12/17/2016  12:47 PM                 symfolder1                                                                                                                                   
    SymLink-d      12/17/2016  12:49 PM                 symfolder2                                                                                                                                   
    File           12/25/2016   2:10 AM            4405 test.ps1                                                                                                                                     
    File           12/11/2016   1:52 PM               3 testfile1.txt                                                                                                                                
    Directory      12/11/2016   2:26 PM                 testmodule                                                                                                                                   
    File           12/11/2016   2:02 PM               3 thirdfile.txt
    
    
    The mode property now shows whether a file or folder is a symlink(symboliclink) and additionaly indicates whether the type is a file or a directory
    -------------------------- EXAMPLE 7 --------------------------
    
    PS C:\>Get-LongChildItem -Path D:\Temp -SkipSymbolicLink
    
    
       Directory: D:\Temp
    
    Mode                  LastWriteTime          Length Name                                                                                                                                         
    ----                  -------------          ------ ----                                                                                                                                         
    Directory      12/5/2016   9:44 PM                 123                                                                                                                                          
    File           12/23/2016   2:46 PM            9491 temp.ps1                                                                                                                                                           
           File           12/25/2016   2:10 AM            4405 test.ps1                                                                                                                                     
    File           12/11/2016   1:52 PM               3 testfile1.txt                                                                                                                                
    Directory      12/11/2016   2:26 PM                 testmodule                                                                                                                                   
    File           12/11/2016   2:02 PM               3 thirdfile.txt
    
    
    lists all items in d:\temp with the exception of symboliclinks
    -------------------------- EXAMPLE 8 --------------------------
    
    PS C:\temp>Get-LongChildItem testdir
    
    
    gets items from the folder 'testdir' located in c:\temp

NAME
    Get-LongDirectorySize
    
SYNOPSIS
    Gets the properties of a directory without following any symbolic links or mount points.
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-LongDirectorySize -Path c:\temp

Path        Size Directory File Hidden Count
----        ---- --------- ---- ------ -----
c:\temp 49337903        35   67      0   102
    
    
Gets the directory statistics for c:\temp. Since the Unit size parameter was not specified the size of the folder is in "bytes".
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-LongDirectorySize -Path c:\temp -Recurse -ContinueonError

Path          Size Directory File Hidden Count
----          ---- --------- ---- ------ -----
c:\temp 7855289946      2087 4985     18  7072
    
    
  List the aggregate size of all the files and folders in the temp directory, and will ignore any exceptions\errors that may arise due to access or other issues.
Warning: using the -ContinueonError may result in an incorrect directory size.

    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-LongDirectorySize -Path c:\temp -Recurse -IncludeSubfolder -Unit MB
    
Path                 Size Directory File Hidden Count
c:\temp              7491      2084 4978     18  7062
c:\temp\.vscode         0         0    2      0     2
c:\temp\123             0         3    0      0     3
c:\temp\234             0         2    1      0     3
c:\temp\alpha1          1         4    7      0    11

Recursively list the total size of the temp folder along with the sizes of all the subfolders. The size of the folders are calulated in megabytes.


NAME
    Get-LongDiskDrive
    
SYNOPSIS
    List local and mapped drives on the local machine along with their size,freespace and usedspace.
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-LongDiskDrive
    
    DriveLetter VolumeLabel FileSystem DriveType FreePercent UsedPercent    Free      Used     Size
    ----------- ----------- ---------- --------- ----------- -----------    ----      ----     ----
    A:\                     Unknown    Removable       0.00%       0.00%     0 B       0 B      0 B
    C:\                     NTFS       Fixed          19.83%      80.17% 9.84 GB  39.81 GB 49.66 GB
    D:\         Source      NTFS       Fixed          32.67%      67.33% 6.53 GB  13.46 GB    20 GB
    E:\         Pagefile    NTFS       Fixed          98.75%       1.25% 9.87 GB 128.41 MB    10 GB
    F:\                     Unknown    CDRom           0.00%       0.00%     0 B       0 B      0 B
    
    
    Lists disk drive stats such as disk space,free used percent etc.

NAME
    Get-LongFreeDriveLetter
    
SYNOPSIS
    List free or available drive letters on the local machine
    
    Get-LongFreeDriveLetter [-Last] [<CommonParameters>]
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-LongFreeDriveLetter -Verbose
    VERBOSE: Get-LongFreeDriveLetter:     Listing the first free DriveLetter
    G
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-LongFreeDriveLetter -Last -Verbose
    VERBOSE: Get-LongFreeDriveLetter:     Listing the Last free DriveLetter
    Z
    
    
    

NAME
    Get-LongItem
    
SYNOPSIS
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-LongItem C:\temp
    
    
    This command gets the 'fileinfo' for the directory C:\temp. The object that is retrieved represents only the directory, not its contents.

NAME
    Get-LongMappedDrive
    
SYNOPSIS
    List mapped drives
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Get-LongMappedDrive | fl *
    
    UncPath               : \\Contoso\Share1\
    DriveLetter           : H:\
    FileSystem            : NTFS
    FreePercent           : 11.61%
    UsedPercent           : 88.39%
    Free                  : 5.79 GB
    Used                  : 44.11 GB
    Size                  : 49.9 GB
    AvailableFreeSpace    : 6217994240
    DriveFormat           : NTFS
    DriveType             : Network
    IsReady               : True
    Name                  : H:\
    RootDirectory         : H:\
    TotalFreeSpace        : 6217994240
    TotalSize             : 53580132352
    VolumeLabel           : 
    DiskSpaceInfo         : H:\
    DosDeviceName         : H:
    IsDosDeviceSubstitute : False
    IsUnc                 : True
    IsVolume              : True
    VolumeInfo            :
    
    
    Lists any mapped drives on the local machine

NAME
    Mount-LongShare
    
SYNOPSIS
    Maps network drive
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Mount-LongShare -DriveLetter Z: -NetWorkShare \\contoso\share1 -Verbose
    
    
    Maps the network share named share1 to the local drive Z:
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Mount-LongShare -DriveLetter F: -NetWorkShare \\contoso\share1 -Credential (Get-Credential)
    
    
    the credential parameter is used to pass alternate credentials to access the network share "share1" and map it to drive F:
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>$cred = Get-Credential
    Mount-LongShare -DriveLetter G: -NetWorkShare \\contoso\share1 -Credential $cred
    
    
    the get-credential cmdlet is used to store credentials in the variable 'cred'
    the cred variable is then passed to the credential parameter in Mount-LongShare to map Share1 to Drive G:

NAME
    Move-LongItem
    
SYNOPSIS
    Move file\folders
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Move-LongItem -path C:\temp\test.txt -destination C:\Temp\folder1\tst.txt
    
    
    This command moves the Test.txt file from the C:\temp to the C:\Temp\folder1 directory and renames it from "test.txt" to "tst.txt".
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Move-LongItem  -Path C:\temp\logfiles -Destination C:\temp\newlogfiles
    
    
    This command moves the C:\Temp\logfiles directory and its contents to the C:\temp\newLogfiles directory. The logfiles directory, and all of its subdirectories and files, then appear in the newLogfiles directory.
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-LongChildItem -Path C:\temp -Filter *.csv -Recurse  | Move-longItem -Destination C:\temp\logs -Verbose
    
    
    This command moves all of the csv files from the c:\temp directory and all subdirectories, recursively, to the C:\temp\logs directory.
    
    The command uses the Get-LongChildItem cmdlet to get all of the child items in the temp directory and its subdirectories that have a *.csv file name extension. It uses the Recurse parameter to make the retrieval 
    recursive and the filter parameter to limit the retrieval to *.csv files.
    
    The pipeline operator (|) sends the results of this command to Move-LongItem, which moves the csv files to the logs directory.
    
    If files being moved to C:\temp\logs have the same name, Move-LongItem displays an warning and continues, but it moves only one file with each name to C:\temp\logs. The other files remain in their original 
    directories.
    
    If the logs directory (or any other element of the destination path) does not exist, the command fails. The missing directory is not created for you, even if you use the Force parameter.

NAME
    New-LongItem
    
SYNOPSIS
    Creates new file,folder,symboliclink or hardlink items.
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>New-Longitem -path c:\temp -name logfiles -itemtype directory
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>New-LongItem -ItemType File  -path 'c:\temp\test.txt', 'c:\temp\logs\test.log'
    
    
    This command uses the New-LongItem cmdlet to create files in two different directories. Because the Path parameter takes multiple strings, you can use it to create multiple items.
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>New-LongItem -Path C:\temp\123\456\hello.txt -Verbose
    
    
    The New-LongItem cmdlet is used to create the directory tree '123'\'456' which dosent exist and then finally a text file 'hello.txt' inside the '456' directory.
    -------------------------- EXAMPLE 4 --------------------------
    
    PS C:\>New-LongItem -Path c:\temp\test.txt -ItemType File -Force -Value "1st Line","2nd Line" -Encoding UTF8
    
    
    Create a text file named test.txt and write 2 lines separated by a line break with UTF8 encoding.
    -------------------------- EXAMPLE 5 --------------------------
    
    PS C:\>New-LongItem -Name test -ItemType Directory
    
    
    a directory named test is created in the current working directory
    -------------------------- EXAMPLE 6 --------------------------
    
    PS C:\>New-LongItem -Name c:\temp\test.txt
    
    
    we use the name parameter instead of path to create a text file named test.
    -------------------------- EXAMPLE 7 --------------------------
    
    PS C:\>New-LongItem -Path C:\temp\MySymlink.txt -Value C:\temp\test.txt -ItemType SymbolicLink
    
    
    a symbolic link named mysymlink.txt is created for an existing file named test located at c:\temp
    -------------------------- EXAMPLE 8 --------------------------
    
    PS C:\>New-LongItem -Name MySymlink -Value C:\temp -ItemType SymbolicLink -Force
    
    
    a symboliclink named mysymlink is created for c:\temp in the current directory. 
    Note: since the -Force switch is used any existing symlink named mysymlink will be overwritten.
    -------------------------- EXAMPLE 9 --------------------------
    
    PS C:\>New-LongItem -Path C:\temp\MyHardlink.txt -Value C:\temp\test.txt -ItemType HardLink
    
    
    a hardlink named myhardlink is created for the existing file at c:\temp\test.txt

NAME
    Remove-LongItem
    
SYNOPSIS
    Deletes specified item.
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Remove-LongItem -Path C:\temp\folder3\drivers.txt -force
    
    
    This command deletes a file that is read-only. It uses the Path parameter to specify the file. It uses the Force parameter to give permission to delete it. Without Force, you cannot delete read-only files.
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Remove-LongItem -path C:\temp\folder7\filenames -Recurse
    
    
    This command deletes the folder 'filenames' including all files and sub-folders.

NAME
    Rename-LongItem
    
SYNOPSIS
    Renames an item in a AlphaFS FileSystem provider namespace.
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Rename-LongItem -path C:\temp\drivers.txt -NewName d1.txt -Verbose -Confirm:$false
    
    
    This command renames the file drivers.txt to d1.txt
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Get-LongChildItem -Path C:\temp\drivers.txt |
        Rename-LongItem -NewName {'prefix' + $_.basename + 'Suffix' + $_.extension }
    
    
    the file 'drivers.txt' is renamed by piping the output of 'Get-LongChildItem' to Rename-LongItem. The newfilename is created by adding a prefix and a suffix to the filename resulting in the following newname: 
    'PrefixdriversSuffix.txt'.
    -------------------------- EXAMPLE 3 --------------------------
    
    PS C:\>Get-ChildItem -Path C:\temp -Filter *.txt | Rename-LongItem -NewExtension log -Confirm:$false
    
    VERBOSE: Performing the operation "Changing Extension" on target "Item:    C:\temp\d1.txt    Destination:    C:\temp\d1.log".
    VERBOSE: Rename-LongItem:
     C:\temp\d1.txt 
            C:\temp\d1.log
    
    VERBOSE: Performing the operation "Changing Extension" on target "Item:    C:\temp\d2.txt    Destination:    C:\temp\d2.log".
    VERBOSE: Rename-LongItem:
     C:\temp\d2.txt 
            C:\temp\d2.log
    
    
    This command gets all the text files in c:\temp and pipes them to Rename-LongItem which then renames each text file extension from *.txt to *.log
    Note: the name os the file is retained(in other words remains unchanged)
