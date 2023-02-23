add-PSSnapin quest.activeroles.admanagement

Get-QADUser -SizeLimit 0 -SearchRoot 'us.chs.net/SSC/TucsonAZ-SSC/Users' -IncludedProperties DisplayName, SamAccountName, passwordexpires| 
select-object DisplayName, SamAccountName, passwordexpires | Export-csv -path "C:\Users\$env:USERNAME\desktop\ExpiredPass.csv" -NoTypeInformation
