PSAlphaFS
=======

PSAlphaFS is a wrapper for the ALphaFS .NET library providing useful powerShell functions that attempt to mimic the functionality of the following cmdlets shipped by microsoft.

* Get-ChildItem
* Get-Item
* Copy-Item
* Rename-Item
* Remove-Item
* New-Item
* Move-Item


## Version
Version 2.0.0.0  see [ChangeLog](https://github.com/v2kiran/PSAlphaFS/blob/master/Changelog.md)

## Installation

You have 2 choices:
* Download From [PowerShell Gallery](https://www.powershellgallery.com/packages/PSAlphaFS/1.0.0.0) (requires PowerShell V5).

```powershell
Install-Module PSAlphaFS -scope CurrentUser
```
* Download from Github [PSAlphaFS-master.zip](https://github.com/v2kiran/PSAlphaFS/archive/master.zip) and extract it to a folder named `PSAlphaFS` in any of your PowerShell module paths. (Run `$env:PSModulePath` to see your paths.)



## Configuration

Since this module runs on powershell V3 and above, you dont need any other configuration. Just follow the installation instructions above and you should be good to go.

## Usage

All cmdlets come with built-in help. To see sample usage of a cmdlet, just type:

```powershell
Get-Help Get-LongChildItem -Examples
```

you can also see the list of exmaples here: [Examples](https://github.com/v2kiran/PSAlphaFS/blob/master/Examples.md)


## About PSAlphaFS

### Maximum Path Length Limitation
In the Windows API, the maximum length for a path is MAX_PATH, which is defined as 260 characters. A local path is structured in the following order: drive letter, colon, backslash, name components separated by backslashes, and a terminating null character. For example, the maximum path on drive D is "D:\some 256-character path string<NUL>" where "<NUL>" represents the invisible terminating null character for the current system codepage. (The characters < > are used here for visual clarity and cannot be part of a valid path string.)

The AlphaFS library overcomes the MAX_PATH limitation of 260 characters and is provided as Open Source, licensed under the MIT license. AlphaFS provides a namespace (Alphaleonis.Win32.Filesystem) containing a number of classes. Most notable are replications of the System.IO.File, System.IO.Directory and System.IO.Path, all with support for the extended-length paths (up to 32.000 chars)

PSAlphaFS is a wrapper for the ALphaFS .NET library, providing a small subset of functions that overcome the long path limitations of the windows filesystem.

The cmdlets in this module have been prefixed with the word "long" to distinguish them from the cmdlets published by microsoft.

* Get-LongChildItem (alias ldir)
* Get-LongItem
* Copy-LongItem
* Rename-LongItem
* Move-LongItem
* Remove-LongItem
* New-LongItem

New in version 2.0
* DisMount-LongShare
* Get-LongDirectorySize
* Get-LongDiskDrive
* Get-LongFreeDriveLetter
* Get-LongMappedDrive
* Mount-LongShare



Links:

[MAX_PATH](https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx#maxpath)

[AlphaFS](https://github.com/alphaleonis/AlphaFS)

[Examples](https://github.com/v2kiran/PSAlphaFS/blob/master/Examples.md)

[ChangeLog](https://github.com/v2kiran/PSAlphaFS/blob/master/Changelog.md)


## Note

I do not work for or represent AlphaFS. This is a project that I made based on my own needs so feel free to fork and modify as needed. If you would like to suggest improvements please do, I will try to get to them as soon as I can.
