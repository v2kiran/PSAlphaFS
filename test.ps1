cls
#remove-item 'C:\temp\Procedures\' -Include '*' -Recurse -Force -ErrorAction SilentlyContinue

$env:PSModulePath = $env:PSModulePath + ';' + 'C:\Users\dwork\LocalRepositories\'

Remove-Module -Name PSAlphaFS -Force
Import-Module -Name PSAlphaFS 

#gci -Path 'D:\Scripts\PSModules\PSAlphaFS' -Include '*.dll' -Recurse -File | 

#Get-LongChildItem -Path '\\sharedocs\sites\pso\Procedures\TNSP Procedures and Contingency Plans\AusNet Services (Vic)\Operational Agreement between Vencorp (now AEMO TS) and SECV' -File -Recurse -Include '*.*' | select -First 1

$temp = $null
try {
  $source = '\\sharedocs\sites\pso\Procedures\TNSP Procedures and Contingency Plans\AusNet Services (Vic)\Operational Agreement between Vencorp (now AEMO TS) and SECV\Letter_Agreement_-_SECV_and_VENCorp_-_January_2007_-_Connection_of_Portland_Windfarm_to_Alcoa_Portland_Switchyard.PDF'
  #$source = '\\sharedocs\sites\pso\Procedures\TNSP Procedures and Contingency Plans\AusNet Services (Vic)\Operational Agreement between Vencorp (now AEMO TS) and SECV\'
  $destination = 'C:\temp\Procedures\TNSP Procedures and Contingency Plans\AusNet Services (Vic)\Operational Agreement between Vencorp (now AEMO TS) and SECV\'
  #$destination = 'C:\temp\Procedures\TNSP Procedures and Contingency Plans\AusNet Services (Vic)\Operational Agreement between Vencorp (now AEMO TS) and SECV\Letter_Agreement_-_SECV_and_VENCorp_-_January_2007_-_Connection_of_Portland_Windfarm_to_Alcoa_Portland_Switchyard.PDF'
  Copy-LongItem $source -Destination $destination -Force -Verbose
}
catch {
  $temp = $_
  throw $_
}