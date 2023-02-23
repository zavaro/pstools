function Write-HostCenter { 
param($Message) Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message) 
}

cls

Write-HostCenter "SCCMInstallerAssistant`n"
Write-HostCenter "Matthew Allbright // version 2022.08.25`n"

Write-HostCenter "This script can be used to quickly send commands to"
Write-HostCenter "networked computers to install applications deployed"
Write-HostCenter "in the Microsoft Endpoint Software Center (SCCM)"
Write-HostCenter "system.`n"

# Stores name input
$computer = Read-Host "What computer are you working on?"

echo "Below is a list of programs to install."
$applicationsAvailable = $(Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_Application -ComputerName $computer | Where-Object { $_.EvaluationState -like "3" } | ForEach-Object { $_.Name })
echo "`n"
echo "---------------"
echo "`n"
foreach ($app in $applicationsAvailable) {
	echo $app
}
echo "What program would you like to install?"
echo "`n"
echo "---------------"
echo "`n"
$applicationName = Read-Host "Type a name or partial name"
		
$application = (Get-WmiObject -ClassName CCM_Application -Namespace "root\ccm\clientSDK" -ComputerName $computer | Where-Object {$_.Name -like "*$applicationName*" -and $_.EvaluationState -like "3"})
 
if ($application.IsMachineTarget -is [array]) {
    echo "Please be more specific with the software name, your current selection returns too many results."
} else {
    #$applicationArgs = @{EnforcePreference = [UINT32] 0
    #Id = "$($application.id)"
    #IsMachineTarget = $application.IsMachineTarget
    #IsRebootIfNeeded = $False
    #Priority = 'High'
    #Revision = "$($application.Revision)" }
		
    Invoke-WmiMethod -Namespace "root\ccm\clientSDK" -Class CCM_Application -ComputerName $computer -Name Install -ArgumentList @(0,$application.ID,$application.IsMachineTarget,$false,'High',$application.Revision)
}
