@echo off
setlocal

echo %cd%
pause

cd "%~dp0\Content\Exe"
java -jar forge-1.19.2-43.3.7-installer.jar
if %errorlevel% neq 0 (
	echo Forge failed to install.
	pause
	exit /b 1
)d