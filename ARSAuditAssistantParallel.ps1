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
Write-HostCenter "ARSAuditAssistantParallel`n"
Write-HostCenter "Matthew Allbright // version 2023.01.20`n"

Write-HostCenter "This script can be used to quickly pull and sort"
Write-HostCenter "information based on Active Directory and networked"
Write-HostCenter "machines into a Excel compatible csv file on the"
Write-HostCenter "Public documents.`n"

# Stores name input
$computer = Read-Host "What computer are you working on? (Write ALL for ALL TSSC machines)"

if ($computer -eq "ALL") {
	# Pulls computers in an array from AD
	$bucket = "{INPUT BUCKET HERE}"
	$computerList = Get-QADComputer -Searchroot "$bucket" -sizelimit 10000 | select Computername | Sort-Object ComputerName

	# Remove VMs/Workstations
	$computerList = $computerList | ? {$_ -notlike '*AZ8630*'}
	
	# Clean array
	$computerList = $computerList.ComputerName -replace "[^a-zA-Z0-9]"
	
	# Sets log to desktop file
	$logFile = "C:\Users\Public\Documents\audit\audit.csv"
	
	# Clear csv file
	Clear-Content $logFile
	
} elseif ($computer -eq "TEST") {
	$computerList = @(
		"1730SS346",
		"1730SS019",
		"1730SS040"
	)	

	$logFile = "C:\Users\Public\Documents\audit\audit.csv"

} else {
	# Uses single machine for list
	$computerList = @(,$computer)
	
	# Sets log to desktop file
	$logFile = "C:\Users\Public\Documents\audit\$computer.csv"
	
	# Clear csv file
	Clear-Content $logFile
}

#Get the temp path of the context user
$tempDirPath = "C:\temp\auditTemp"
New-Item -Path $tempDirPath -ItemType Directory

$newAuditDir = "C:\Users\Public\Documents\audit"
New-Item -Path $newAuditDir -ItemType Directory

$tempFilePath = $null

# Parallel block
$block = {
    # Parallel identifiers
	Param([string]$computer,[string]$tempDirPath,[string]$tempFilePath)
	
	# Need to re-add snap-in for each parallel instance
	Add-PSSnapin Quest.ActiveRoles.ADManagement	
	
	$computerClean = $computer
	
	# Get computer serial
	$computerSerial = Get-WMIObject Win32_Bios -ComputerName $computerClean | select SerialNumber
	$serialClean = $computerSerial -replace "[$]","" -replace '@{SerialNumber=',"" -replace "[}]",""
	
	### Monitor stuff ###
	# Automatically sets monitor value to default state (Blank)
	$mon0 = $null
	$mon1 = $null
	$mon2 = $null
	
	# Pulls monitors in an array from AD
	$monitors = Get-WmiObject wmiMonitorID -NameSpace root\wmi -ComputerName $computerClean | ForEach-Object {$([System.Text.Encoding]::Ascii.GetString($($_.SerialNumberID)))}

	# Sets monitor values from array position (0 is first value in array), three monitors is a rarity
	$mon0 = $monitors[0]
	$mon1 = $monitors[1]
	$mon2 = $monitors[2]
	$mon3 = $monitors[3]
	
	# Cleans up monitor by removing all non alphanumeric character
	$mon0 = $mon0 -replace "[^a-zA-Z0-9]"
	$mon1 = $mon1 -replace "[^a-zA-Z0-9]"
	$mon2 = $mon2 -replace "[^a-zA-Z0-9]"
	$mon3 = $mon3 -replace "[^a-zA-Z0-9]"
	
	### Device Serial check ###
	$deviceSerial = (Get-WMIObject -ComputerName $computerClean Win32_USBControllerDevice |%{[wmi]($_.Dependent)} | Where-Object {($_.DeviceID -like '*USB\VID_0801&PID_3004\*')}).DeviceID
	$deviceSerialClean = $creditSerial -replace "USB\\VID_0801&PID_3004\\",""
	
	### Location stuff ###
	# Grabs location from description in AD
	$location = Get-QADComputer "$bucket/$computerClean" | select Description
	$locationClean = $location -replace "[$]","" -replace '@{Description=',"" -replace '; ',"," -replace '}',""  -replace ' - Sup',"" -replace ' - Dir',"" -replace ' - Mgr',"" -replace ' - Lead',"" -replace ' - PM',"" -replace ' - FA',"" -replace ' - FC',"" -replace ' - ',","
	
	### Viability ###
	
	# Return packet test
	if (Test-Connection -Quiet $computerClean) {
		$connection = "Success"
	} else {
		$connection = "Not responding"
	}
	
	# Check if SCCM is responding
	if ((Get-WMIObject -ComputerName $computerClean -Namespace root\ccm -Class SMS_Client).ClientVersion) {
		$sccm = "True"
	} else {
		$sccm = "False"
	}
	
	
	# Checks BitLocker encryption
	$encryptionStatus = manage-bde -status -cn $computerClean | Select-String "100.0%"
	if ($encryptionStatus) {
		$encrypted = "TRUE"
	} else {
		$encrypted = "FALSE"
	}
	
	### Windows version stuff ###
	
	# Clear variable
	$windowsVersionClean = $null
	
	# Pulls raw Windows versions from AD
	$windowsVersion = Get-QADComputer "$bucket/$computerClean" | select OperatingSystemVersion
	$windowsVersionClean = $windowsVersion -replace "[$]","" -replace '@{operatingSystemVersion=',"" -replace '; ',"," -replace '}',""
	
	# Checks raw version against chart to determine colloquial
	if ($windowsVersionClean -eq '10.0 (19042)') {
		$windowsVersionCol = 'Windows10,20H2'
	} elseif ($windowsVersionClean -eq '10.0 (19043)') {
		$windowsVersionCol = 'Windows10,21H1'
	} elseif ($windowsVersionClean -eq '10.0 (19044)') {
		$windowsVersionCol = 'Windows10,21H2'
	} else {
		# If version is too old, it will appear with these
		$windowsVersionCol = 'Legacy,RequiresUpdate'
	}
	
	# Reset value of $username for cleanup
	$username = $null
	
	### Names and usernames ###
	# Pulls usernames from last known user in AD
	$username = Get-QADComputer "$bucket/$computerClean" -IncludedProperties SamAccountName,extensionAttribute8 | select extensionAttribute8
	$usernameClean = $username -replace "[$]","" -replace '@{extensionAttribute8=',"" -replace "[}]",""
	
	# Reset value of $nameOfUser for cleanup
	$nameOfUser = $null
	
	# If username isn't blank, proceed with determining user's full name
	if ($usernameClean) {
		# Uses username to grab full name from AD
		$nameOfUser = Get-QADUser -Identity $usernameClean | select Name,DisplayName
		$nameOfUserClean = $nameOfUser -replace "[$]","" -replace '@{Name=',"" -replace 'DisplayName=',"" -replace '; ',"," -replace "[}]",""

	} else {
		# If user cannot be determined, makes it blank
		$nameOfUserClean = ',,'
	}
	
	# Checks if computer belongs to Nessus group
	if ((Get-QADComputer $computerClean).MemberOf -like "*nessus*") {
		$nessusStatus = "Member"
	} else {
		$nessusStatus = "Not a member"
	}
	
	# Checks Office version according to groups
	if ((Get-QADComputer $computerClean).MemberOf -like "*OFFICE_GROUP*") {
		$officeVersion = "OffSTD2013"
	} elseif ((Get-QADComputer $computerClean).MemberOf -like "*OFFICE_GROUP*") {
		$officeVersion = "OffProPlus2013"
	} else {
		$officeVersion = "Unknown"
	}
	
	### Drive Type ###
	$DriveTypeNum = (Get-WmiObject -Class MSFT_PhysicalDisk -ComputerName $computerClean -Namespace root\Microsoft\Windows\Storage).mediatype
	
	# Determine drive type
	if ($DriveTypeNum -eq 3) {
		$driveType = "HDD"
	} elseif ($DriveTypeNum -eq 4) {
		$driveType =  "SSD"
	} else {
		$driveType = "Unknown"
	}

	### Log stuff ###
	# Adds all earlier stuff to log in human readable format, each monitorID gets its own row
    $tempFilePath = Join-Path -Path $tempDirPath -ChildPath "$computerClean.txt"
    echo "$computerClean,$serialClean,$nameOfUserClean,$locationClean,$connection,$sccm,$encrypted,$windowsVersionCol,$officeVersion,$creditSerialClean,$nessusStatus,$driveType,$mon0,$mon1,$mon2,$mon3" | Out-File $tempFilePath

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
	Start-Job -Name $computer -Scriptblock $block -ArgumentList $computer,$tempDirPath,$tempFilePath | Out-Null
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
echo "ComputerName,SerialClean,Username,LastName,FirstName,Department,Location,IsOnline,SCCMResponding,BitLockerEncryptedOperatingSystem,OperatingSystem,OperatingSystemVersion,OfficeVersion,CreditCardReaderSerial,NessusStatus,DriveType,MonitorSerial0,MonitorSerial1,MonitorSerial2,MonitorSerial3" | Out-File $logFile -Append

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
