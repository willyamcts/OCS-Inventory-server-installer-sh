@echo off

if exist "%programfiles%/OCS Inventory Agent/OCSInventory.exe" (
	"%programfiles%/OCS Inventory Agent/OCSInventory.exe" /server=http://192.168.1.1:80/ocsinventory
	pause
)

if exist "%programfiles(x86)%/OCS Inventory Agent/OCSInventory.exe" (
	"%programfiles(x86)%/OCS Inventory Agent/OCSInventory.exe" /server=http://192.168.1.1:80/ocsinventory
	pause
)

