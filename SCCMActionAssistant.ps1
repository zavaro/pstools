function Write-HostCenter { 
param($Message) Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message) 
}

cls

Write-HostCenter "SCCMActionAssistant`n"
Write-HostCenter "Matthew Allbright // version 2022.08.25`n"

Write-HostCenter "This script can be used to quickly send commands to"
Write-HostCenter "networked computers to run Configuration Manager"
Write-HostCenter "actions to update the Microsoft Endpoint Software"
Write-HostCenter "Center (SCCM) system.`n"

# Stores name input
$computer = Read-Host "What computer are you working on?"
	
echo "Running actions. This will take a while."
Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000121}"
Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000003}"
Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000010}"
echo "Still running..."
Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}"
Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"
Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}"
echo "Still running..."
Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000002}"
Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000031}"
Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000114}"
echo "Still running..."
Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000113}"
Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000111}"
#Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000026}"
#echo "Still running..."
#Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000027}"
Invoke-WMIMethod -ComputerName $computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000032}"
echo "Finished."
Start-Sleep -Seconds 5
