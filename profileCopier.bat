@echo off

echo "This program copies over the user directory files from one machine to the next. It grabs things like the Desktop and Documents folder."

set /p arg1="What is the source (e.g. 1000XX325)? "
set /p arg2="What is the destination (e.g. 1000XX346)? " 
set /p arg4="What is the source username (e.g. zavaro)? "
set /p arg3="What is the destination username (e.g. zavaro)? "

title %arg3%

echo "Copying Desktop..."
timeout 3

robocopy \\%arg1%\c$\Users\%arg4%\Desktop\ \\%arg2%\c$\Users\%arg3%\Desktop\ /XA:SH /E /R:0 /W:0

robocopy \\%arg1%\c$\Users\%arg4%\Contacts\ \\%arg2%\c$\Users\%arg3%\Contacts\ /XA:SH /E /R:0 /W:0

echo "Copying Documents without the IBM folder..."
timeout 3

robocopy \\%arg1%\c$\Users\%arg4%\Documents\ \\%arg2%\c$\Users\%arg3%\Documents /XA:SH /E /R:0 /W:0 /XD "\\%arg1%\c$\Users\%arg3%\Documents\IBM"

echo "Copying Downloads back to December 1st, 2021..."
timeout 3

robocopy \\%arg1%\c$\Users\%arg4%\Downloads\ \\%arg2%\c$\Users\%arg3%\Downloads /XA:SH /E /R:0 /W:0 /maxage:20211201

robocopy \\%arg1%\c$\Users\%arg4%\Links\ \\%arg2%\c$\Users\%arg3%\Links\ /XA:SH /E /R:0 /W:0

echo "Copying Windows favorites..."
timeout 3

robocopy \\%arg1%\c$\Users\%arg4%\Favorites\ \\%arg2%\c$\Users\%arg3%\Favorites\ /XA:SH /E /R:0 /W:0

robocopy \\%arg1%\c$\Users\%arg4%\Music\ \\%arg2%\c$\Users\%arg3%\Music\ /XA:SH /E /R:0 /W:0

robocopy \\%arg1%\c$\Users\%arg4%\OneDrive\ \\%arg2%\c$\Users\%arg3%\OneDrive\ /XA:SH /E /R:0 /W:0

robocopy \\%arg1%\c$\Users\%arg4%\Pictures\ \\%arg2%\c$\Users\%arg3%\Pictures\ /XA:SH /E /R:0 /W:0

robocopy \\%arg1%\c$\Users\%arg4%\Videos\ \\%arg2%\c$\Users\%arg3%\Videos\ /XA:SH /E /R:0 /W:0

echo "Copying Chrome bookmarks..."
timeout 3

md "\\%arg2%\c$\Users\%arg3%\AppData\Local\Google\Chrome\User Data\Default"

xcopy "\\%arg1%\c$\Users\%arg4%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" "\\%arg2%\c$\Users\%arg3%\AppData\Local\Google\Chrome\User Data\Default\"

xcopy "\\%arg1%\c$\Users\%arg4%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks.bak" "\\%arg2%\c$\Users\%arg3%\AppData\Local\Google\Chrome\User Data\Default\"

if exist "\\%arg1%\c$\Users\%arg4%\AppData\Local\Google\Chrome\User Data\Profile 1\" (
	echo "Additional Chrome profile found." 
	md "\\%arg2%\c$\Users\%arg3%\AppData\Local\Google\Chrome\User Data\Default"

	xcopy "\\%arg1%\c$\Users\%arg4%\AppData\Local\Google\Chrome\User Data\Profile 1\Bookmarks" "\\%arg2%\c$\Users\%arg3%\AppData\Local\Google\Chrome\User Data\Profile 1\"

	xcopy "\\%arg1%\c$\Users\%arg4%\AppData\Local\Google\Chrome\User Data\Profile 1\Bookmarks.bak" "\\%arg2%\c$\Users\%arg3%\AppData\Local\Google\Chrome\User Data\Profile 1\"
) else (
	echo "Default Chrome profile only."
)

echo "Copied all files successfully."

timeout 5
