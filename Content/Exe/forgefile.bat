@echo off
setlocal

echo %cd%
pause

java -jar "%~dp0\Content\Folders\Exe\forge-1.19.2-43.3.7-installer.jar" --installClient
if %errorlevel% neq 0 (
	echo Forge failed to install.
	pause
	exit /b 1
)