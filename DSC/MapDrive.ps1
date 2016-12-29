	enum Ensure
	{
		Absent
		Present
	}
	
	[DscResource()]
	class cPSAlphaFSMapDrive
	{
		[DscProperty(Key)]
		[string] $DriveLetter

		[DscProperty(Mandatory)]
		[string] $NetworkShare

		[DscProperty()]
		[PSCredential] $Credential

		[DscProperty()]
		[Bool] $Force		

		[DscProperty(Mandatory)]
		[Ensure] $Ensure


		[cPSAlphaFSMapDrive] Get()
		{
			return $this			
		}# end get

		[void] Set()
		{

			$params = 
			@{
				DriveLetter = (FormatDriveLetter $this.DriveLetter)
				NetworkShare = $this.NetworkShare
				Ensure = $this.Ensure
			}
			if($this.Credential) {$params.Add('Credential', $this.Credential)}
			if($this.Force) {$params.Add('Force', $this.Force)}


			if ($this.Ensure -eq [Ensure]::Present)
			{
				'Force','Ensure' | ForEach-Object {$null = $params.Remove($_)}
				Mount-LongShare @Params
			}
			else
			{
				'Credential','NetworkShare','Ensure' | ForEach-Object {$null = $params.Remove($_)}
				DisMount-LongShare @Params
			}
		}# end set

		[bool] Test()
		{
			$DriveLetterFormatted = FormatDriveLetter $this.DriveLetter

			# present case
			if ($this.Ensure -eq [Ensure]::Present)
			{
				return CheckMappedDriveExists $DriveLetterFormatted $this.NetworkShare
			}
			# absent case
			else
			{
				return (-not (CheckMappedDriveExists $DriveLetterFormatted $this.NetworkShare))
			}
		}# end bool test



	}