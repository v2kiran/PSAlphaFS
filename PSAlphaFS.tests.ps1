#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests. 
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

#define shortcuts
$DirObject = [Alphaleonis.Win32.Filesystem.Directory]
$FileObject = [Alphaleonis.Win32.Filesystem.File]
$FileinfoObject = [Alphaleonis.Win32.Filesystem.FileInfo]
$PathFSObject = [Alphaleonis.Win32.Filesystem.Path]
$PathFSFormatObject = [Alphaleonis.Win32.Filesystem.PathFormat]
$dirEnumOptionsFSObject = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]
$copyFsObject = [Alphaleonis.Win32.Filesystem.CopyOptions]
$linktype = [Alphaleonis.Win32.Filesystem.SymbolicLinkTarget]
$MoveOptions = [Alphaleonis.Win32.Filesystem.MoveOptions]


function CreateLongDirStructure
{
    param
    (
        [string] 
        $Dir = "c:\temp\pester\psalphafs",
		
        [int] 
        $Width = 265
    )

    1..$Width | % -begin {$d = $null} -process { $longdir = "c:\temp\pester\psalphafs$d"; $d += "\$_"} -end { New-LongItem -Path $longdir -ItemType Directory -Force }
}

#Create a directory tree that spans more than 255 chars
#$null = CreateLongDirStructure 


Describe "Get-LongChildItem" {
    Context "Parameters" {
        BeforeAll {
			$lastfolder = ldir C:\temp\pester\psalphafs -Recurse -Directory | where name -eq 264 | select -Last 1 -ExpandProperty FullName		
            $2ndlastfolder = ldir C:\temp\pester\psalphafs -Recurse -Directory | where name -eq 263 | select -ExpandProperty FullName
            $lastfile = 'file-264.txt'
            $2ndlastfile1 = "file-263-1.txt"
            $2ndlastfile2 = "file-263-2.txt"
            $2ndlastfile3 = "file-263-1.htm"
            $2ndlastfile4 = "file-263-2.htm"
            $null = New-LongItem -Path $lastfolder -Name $lastfile -Value "this is the last file" -ItemType File -Force
            "$2ndlastfolder\$2ndlastfile1", "$2ndlastfolder\$2ndlastfile2", "$2ndlastfolder\$2ndlastfile3", "$2ndlastfolder\$2ndlastfile4" | New-LongItem -ItemType File -Force | Out-Null
        }

        It "Should list long file and folder names correctly" {
            $lastfolderObj = Get-LongChildItem $lastfolder
            $lastfolderObj.Name | Should -Be file-264.txt
            $lastfolderObj.Directory.Name | Should -Be 264
            $lastfolderObj.Directory.Parent.name | should -Be 263
            $lastfolderObj.Mode | should -be File
            $lastfolderObj.Extension | should -be '.txt'
        }
		
        It "Should list files and folders in a given directory" {
            $2ndlastfolderObj = Get-LongChildItem $2ndlastfolder
            $2ndlastfolderObj.Count | Should -Be 5
            $2ndlastfolderObj.Mode | Should -Contain 'Directory' 
            $2ndlastfolderObj.Mode | Should -Contain 'File'
        }	
		
        It "-Recurse switch should work as expected" {
            $2ndlastfolderObj = Get-LongChildItem $2ndlastfolder -Recurse
            $2ndlastfolderObj.Count | Should -Be 6
            $2ndlastfolderObj.directory.name | Should -Contain 263 
            $2ndlastfolderObj.directory.name | Should -Contain 264
            $2ndlastfolderObj.Name | Should -Contain 'file-264.txt'
        }	
		
        It "-Filter switch should work as expected" {
            $2ndlastfolderTXTObj = Get-LongChildItem $2ndlastfolder -Filter *.txt
            $2ndlastfolderTXTObj.Count | Should -Be 2
            $2ndlastfolderTXTObj.Name | Should -BeExactly @('file-263-1.txt', 'file-263-2.txt')
            $2ndlastfolderHTMObj = Get-LongChildItem $2ndlastfolder -Filter *.htm
            $2ndlastfolderHTMObj.Count | Should -Be 2
            $2ndlastfolderHTMObj.Name | Should -BeExactly @('file-263-1.htm', 'file-263-2.htm')
            $2ndlastfolderMIXObj = Get-LongChildItem $2ndlastfolder -Filter file-263-1*
            $2ndlastfolderMIXObj.Count | Should -Be 2
            $2ndlastfolderMIXObj.Name | Should -BeExactly @('file-263-1.htm', 'file-263-1.txt')
            $2ndlastfolderRecurseObj = Get-LongChildItem $2ndlastfolder -Filter *.txt -Recurse
            $2ndlastfolderRecurseObj.Count | Should -Be 3
            $2ndlastfolderRecurseObj.Name | Should -BeExactly @('file-263-1.txt', 'file-263-2.txt', 'file-264.txt')
			
        }	
		
        It "-Include switch should work as expected" {
            $2ndlastfolderMIXObj = Get-LongChildItem $2ndlastfolder -Include *1.txt, *2.htm
            $2ndlastfolderMIXObj.Count | Should -Be 2
            $2ndlastfolderMIXObj.Name | Should -BeExactly @('file-263-1.txt', 'file-263-2.htm')
            $2ndlastfolderRecurseObj = Get-LongChildItem $2ndlastfolder -Include *264.txt, *2.htm -Recurse
            $2ndlastfolderRecurseObj.Count | Should -Be 2
            $2ndlastfolderRecurseObj.Name | Should -BeExactly @('file-263-2.htm', 'file-264.txt')			
        }	
		
        It "-Exclude switch should work as expected" {
            $2ndlastfolderMIXObj = Get-LongChildItem $2ndlastfolder -Exclude *1.txt, *2.htm
            $2ndlastfolderMIXObj.Count | Should -Be 3
            $2ndlastfolderMIXObj.Name | Should -BeExactly @('264', 'file-263-1.htm', 'file-263-2.txt')
            $2ndlastfolderRecurseObj = Get-LongChildItem $2ndlastfolder -Exclude *1.txt, *2.htm -Recurse
            $2ndlastfolderRecurseObj.Count | Should -Be 4
            $2ndlastfolderRecurseObj.Name | Should -BeExactly @('264', 'file-263-1.htm', 'file-263-2.txt', 'file-264.txt')			
        }
		
        It "-File switch should work as expected" {
            $2ndlastfolderMIXObj = Get-LongChildItem $2ndlastfolder -File
            $2ndlastfolderMIXObj.Count | Should -Be 4
            $2ndlastfolderMIXObj.Mode | Should -Not -Contain 'Directory'
            $2ndlastfolderRecurseObj = Get-LongChildItem $2ndlastfolder -File -Recurse
            $2ndlastfolderRecurseObj.Count | Should -Be 5
            			
        }
		
        It "-Directory switch should work as expected" {
            $2ndlastfolderMIXObj = Get-LongChildItem $2ndlastfolder -Directory
            $2ndlastfolderMIXObj.Count | Should -Be 1
            $2ndlastfolderMIXObj.Mode | Should -Not -Contain 'File'
            			
        }
		
        It "-Name switch should work as expected" {
            $2ndlastfolderMIXObj = Get-LongChildItem $2ndlastfolder -Name
            $2ndlastfolderMIXObj.Count | Should -Be 5
            $2ndlastfolderMIXObj | Should -BeExactly @('264', 'file-263-1.htm', 'file-263-1.txt', 'file-263-2.htm', 'file-263-2.txt')
            $2ndlastfolderMIXObj = Get-LongChildItem $2ndlastfolder -Name -Recurse
            $2ndlastfolderMIXObj.Count | Should -Be 6
            $2ndlastfolderMIXObj = Get-LongChildItem $2ndlastfolder -Name -Directory
            $2ndlastfolderMIXObj.Count | Should -Be 1
            $2ndlastfolderMIXObj = Get-LongChildItem $2ndlastfolder -Name -Filter *.txt
            $2ndlastfolderMIXObj.Count | Should -Be 2
            $2ndlastfolderMIXObj | Should -BeExactly @('file-263-1.txt', 'file-263-2.txt')	
            $2ndlastfolderMIXObj = Get-LongChildItem $2ndlastfolder -Name -Filter *.txt -Recurse
            $2ndlastfolderMIXObj.Count | Should -Be 3
            $2ndlastfolderMIXObj = Get-LongChildItem $2ndlastfolder -Include *.txt, *2.htm -Recurse -Name
            $2ndlastfolderMIXObj.Count | Should -Be 4
            $2ndlastfolderMIXObj | Should  -Contain '264\file-264.txt'
        }
    }
}

Describe "Copy-LongItem" {
    $lastfolder = ldir C:\temp\pester\psalphafs -Recurse -Directory | where name -eq 264 | select -Last 1 -ExpandProperty FullName		
	$2ndlastfolder = ldir C:\temp\pester\psalphafs -Recurse -Directory | where name -eq 263 | select -ExpandProperty FullName
    $lastfile = 'file-264.txt'
    $3rdfolder = ldir C:\temp\pester\psalphafs -Recurse -Directory | where name -eq 251 | select -Last 1 -ExpandProperty FullName 
    $4thfolder = ldir C:\temp\pester\psalphafs -Recurse -Directory | where name -eq 250 | select -Last 1 -ExpandProperty FullName
	
	
    it "File Copy" {
        $source = "{0}\{1}" -f $lastfolder, $lastfile
        $destination = "{0}\{1}" -f $3rdfolder, $lastfile
        Copy-LongItem -Path $source -Destination $3rdfolder -Force
        $sourceitem = Get-LongItem $source
        $copieditem = Get-LongItem $destination
        $copieditem.Name | should -Be $lastfile
		
        # Validate file Length
        $copieditem.Length | Should -Be  $sourceitem.Length
		
        # Validate LastWriteTime
        $copieditem.LastWriteTime | Should -Be  $sourceitem.LastWriteTime
        $copieditem.LastWriteTimeUtc | Should -Be  $sourceitem.LastWriteTimeUtc

        # Validate Attributes
        $copieditem.Attributes.value__ | Should -Be $sourceitem.Attributes.value__
       
    }
	
    it "Folder Contents Copy" {
        $source = "$2ndlastfolder\"
        $destination = $4thfolder
        Copy-LongItem -Path $source -Destination $destination -Force
        $copieditem = Get-LongChildItem $destination
        $copieditem.Name | should -Contain 264
        $copieditem.Name | should -Contain file-263-2.txt
        $DirObject::Exists("$destination\264") | should -be $true
        (Get-LongChildItem $destination\264).Name | should -Be file-264.txt
        (Get-LongChildItem $destination\264).Length | Should -Be  (Get-LongChildItem $lastfolder).Length

       
    }
	
    <#
    it "Folder  Copy" {
        $source = "$2ndlastfolder\"
        $destination = $4thlastfolder
        Copy-LongItem -Path $source -Destination $destination -Force
        $copieditem = Get-LongChildItem $destination
        $copieditem.Name | should -Contain 264
        $copieditem.Name | should -Contain file-263-2.txt
        (Get-LongChildItem $destination\264).Name | should -Be file-264.txt
        (Get-LongChildItem $destination\264).Length | Should -Be  (Get-LongChildItem $lastfolder).Length
        $DirObject::Exists($Path)
        $DirObject::GetProperties( $pItem, $dirEnumOptionsFSObject::Recursive, $PathFSFormatObject::FullPath)

       
    }
	#>
   
}


#Remove-LongItem -Path C:\temp\pester\psalphafs\1 -Recurse -Force
