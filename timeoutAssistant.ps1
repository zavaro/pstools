function Write-HostCenter { 
param($Message) Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message) 
}

#cls

Write-HostCenter "TimeoutAssistant`n"
Write-HostCenter "Matthew Allbright // version 2022.12.22`n"

Write-HostCenter "Ping a computer and see when it fails.`n"

# Stores name input
$computer = Read-Host "What computer are you monitoring?"

ping -t $computer | Select-String "Request timed out" | Foreach{"{0} - {1}" -f (Get-Date),$_}
