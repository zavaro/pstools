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
Write-HostCenter "softwareVersionCheck`n"
Write-HostCenter "Matthew Allbright // version 2023.01.20`n"

Write-HostCenter "This script can be used to quickly determine the"
Write-HostCenter "version of Genesys on computers in the environment.`n"

# Stores name input
$computer = Read-Host "What computer are you working on? (Write ALL for ALL TSSC machines)"

if ($computer -eq "ALL") {
	# Pulls computers in an array from AD
	$computerList = Get-QADComputer -Searchroot "{INPUT_BUCKET_HERE}" -sizelimit 10000 | select Computername | Sort-Object ComputerName

	# Remove VMs/Workstations
	$computerList = $computerList | ? {$_ -notlike '*SERVERPREFIX*'}
	
	# Clean array
	$computerList = $computerList.ComputerName -replace "[^a-zA-Z0-9]"
	
	# Sets log to desktop file
	$logFile = "C:\Users\Public\Documents\softwareversioncheck\softwareversioncheck.csv"
	
	# Clear csv file
	Clear-Content $logFile
	
} elseif ($computer -eq "TEST") {
	$computerList = @(
		"1000XX001",
		"1000XX002"
	)	

	$logFile = "C:\Users\Public\Documents\softwareversioncheck\softwareversioncheck.csv"

} else {
	# Uses single machine for list
	$computerList = @(,$computer)
	
	# Sets log to desktop file
	$logFile = "C:\Users\Public\Documents\softwareversioncheck\$computer.csv"
	
	# Clear csv file
	Clear-Content $logFile
}

#Get the temp path of the context user
$tempDirPath = "C:\temp\availabilityTemp"
New-Item -Path $tempDirPath -ItemType Directory

#Create Genesys-specific folder for output
$newDirPath = "C:\Users\Public\Documents\softwareversioncheck"
New-Item -Path $newDirPath -ItemType Directory

$tempFilePath = $null

# Parallel block
$block = {
    # Parallel identifiers
	Param([string]$computer,[string]$tempDirPath,[string]$tempFilePath,[string]$application)
	
	# Need to re-add snap-in for each parallel instance
	Add-PSSnapin Quest.ActiveRoles.ADManagement	
		
	### Viability ###
	
	# Check if SCCM is responding
	if ((Get-WMIObject -ComputerName $computer -Namespace root\ccm -Class SMS_Client).ClientVersion) {
		$sccm = "True"
	} else {
		$sccm = "False"
	}
	
	$restart = Invoke-WmiMethod -ComputerName $computer -Namespace "ROOT\ccm\ClientSDK" -Class "CCM_ClientUtilities" -Name DetermineIfRebootPending | Select-Object -ExpandProperty RebootPending
	
	# Checks application availability
    $appVersion = (Get-WmiObject -ComputerName $computer -Query "SELECT * FROM CIM_DataFile WHERE Drive ='C:' AND Path='\\PATH\\TO\\' AND FileName='FILE' AND Extension='exe'" | select -ExpandProperty Version)

	### Log stuff ###
	# Adds all earlier stuff to log in human readable format, each monitorID gets its own row
    $tempFilePath = Join-Path -Path $tempDirPath -ChildPath "$computer.txt"
    echo "$computer,$sccm,$appVersion,$restart" | Out-File $tempFilePath

}

# Remove all jobs
Get-Job | Remove-Job

# Set number of simultaneous jobs (higher doesn't necessarily mean better, can bog down system if too high)
$MaxThreads = 32

# Start the job for each computer
foreach ($computer in $computerList) {
	echo ("Analyzing " + $computer)
    while ($(Get-Job -state running).count -ge $MaxThreads) {
        Start-Sleep -Milliseconds 3
    }
	Start-Job -Name $computer -Scriptblock $block -ArgumentList $computer,$tempDirPath,$tempFilePath,$application | Out-Null
}

# Wait for all jobs to finish
while ($(Get-Job -State Running).count -gt 0) {
    start-sleep 1
}
# Get information from each job
foreach ($job in Get-Job) {
    $info= Receive-Job -Id ($job.Id)
}

# Adds header to csv file and clears logFile
echo "sep=," | Out-File $logFile
echo "ComputerName,SCCM,Version,PendingRestart" | Out-File $logFile -Append

# Merges all temp files and sorts
$tempFiles = Get-ChildItem -Path $tempDirPath



foreach ($tempFile in $tempFiles) {
	Get-Content -Path $tempFile.FullName | Out-File $logFile -Append
}

# Remove all jobs created.
Get-Job | Remove-Job

Remove-Item -Path $tempDirPath -Force -Recurse

echo "Finished."

start-sleep 5
