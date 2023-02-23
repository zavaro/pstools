# Function to center text
function Write-HostCenter { 
param($Message) Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message) 
}

cls
Write-HostCenter "UpdateAssistant`n"
Write-HostCenter "Matthew Allbright // version 2022.08.26`n"

Write-HostCenter "This script can be used to quickly send commands to"
Write-HostCenter "networked computers to install Windows updates using"
Write-HostCenter "the Microsoft Endpoint Software Center (SCCM) system.`n"

# Stores name input
$computer = Read-Host "What computer are you working on?"
	
$updateArgs = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $computer | Where-Object { $_.EvaluationState -like "*$($AppEvalState0)*" -or $_.EvaluationState -like "*$($AppEvalState1)*"})
Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$updateArgs) -Namespace root\ccm\clientsdk -ComputerName $computer
