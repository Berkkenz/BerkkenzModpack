@echo off
setlocal

java -jar %~dp0\forge-1.19.2-43.3.7-installer.jar
if %errorlevel% neq 0 (
	echo Forge failed to install.
	pause
	exit /b 1
) else (
	echo Forge installed!
	timeout 3
	exit /b 0
)