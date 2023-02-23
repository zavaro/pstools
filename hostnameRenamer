### Preliminary stuff ###
# Prerequisite snap-ins
Add-PSSnapin Quest.ActiveRoles.ADManagement

# Suppress errors (disable to debug)
$ErrorActionPreference = 'SilentlyContinue'

# Function to center text
function Write-HostCenter { 
param($Message) Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message) 
}

# Clear screen
cls

# Blurb
Write-HostCenter "HostnameRenamer`n"
Write-HostCenter "Matthew Allbright // version 2023.01.13`n"

Write-HostCenter "This script can be used to quickly perform a"
Write-HostCenter "hostname change to targeted machines which"
Write-HostCenter "will then propagate to AD.`n"

# Stores name input
Write-Host "What computer are you working on? (Write BATCH for ALL machines following a prefix rule (e.g. `"" -NoNewLine;
Write-Host "1000" -ForegroundColor Red -NoNewLine;
$computer = Read-Host "XX001`"))"

if ($computer -eq "BATCH") {
	
	Write-Host "What is the prefix you would like to target? (e.g. `"" -NoNewLine;
	Write-Host "1000" -ForegroundColor Red -NoNewLine;
	$oldPrefix = Read-Host "XX001`"))"

	# Pulls computers in an array from AD
	$computerList = Get-QADComputer -Searchroot "{INPUT BUCKET HERE}" -sizelimit 10000 | Select ComputerName | Sort-Object ComputerName | ? {$_ -like "*$oldPrefix*"} | ? {$_ -notlike "*AZ8630*"}

} else {
	# Uses single machine for list
	$computerList = @(,$computer)

	$oldPrefix = $computer.SubString(0,4)

}

Write-Host "What is the prefix you would like to change it to? (e.g. `"" -NoNewLine;
Write-Host "1000" -ForegroundColor Red -NoNewLine;
$newPrefix = Read-Host "XX001`"))"

$confirmation = Read-Host "ARE YOU ABSOLUTELY SURE?"

if ($confirmation -like "*yes*") {

	# Runs a loop for every computer
	foreach ($hostname in $computerList) {
		
		# Get domain and user
		$username = whoami
		
		# Create new hostname
		$newHostname = $hostname -Replace "^[$oldPrefix]+","$newPrefix"
		
		# Rename computer with new hostname
		Rename-Computer -ComputerName $hostname -NewName $newHostname -DomainCredential $username
		Start-Sleep 3
	}
} else {
	Write-Host "Cancelling..."
	Start-Sleep 3
}
