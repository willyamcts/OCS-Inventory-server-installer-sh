REM
REM Add this file to the GPO: Computer Settings> Windows Settings> Scripts> Startup:

@echo off
set FILE="%ProgramFiles%\OCS Inventory Agent\OcsService.exe"


if not exist %FILE% (

	echo Executado! >> C:\Users\User\Documents\a.txt
	
	REM Change installer path and server address:port;
	C:\Users\User\Documents\OCS-NG-Windows-Agent-Setup.exe /S /server=http://192.168.44.65:80/ocsinventory /proxy_type=0 /ca="cacert.pem" /NOW
)