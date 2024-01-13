@echo off
setlocal

echo Checking if Git is installed...
git --version
echo %errorlevel%
if %errorlevel% equ 0 (
	echo Git is already installed.
	goto githubcheck
)

echo Git is not installed. Downloading Git...
powershell -command "Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.34.1.windows.1/Git-2.34.1-64-bit.exe' -OutFile 'GitInstaller.exe'"
echo Installing Git...
start /wait GitInstaller.exe /VERYSILENT /NORESTART
del GitInstaller.exe
echo Git installed successfully.
goto end_script

:githubcheck
cls
cd /d %~dp0
if not exist ".git" (
	echo Initializing Git repository...
	git init
	git remote add origin https://github.com\Berkkenz\BerkkenzModpack.git
)

git fetch
git diff --quiet HEAD origin/main

if %errorlevel% equ 0 (
    echo No updates are available.
    pause
    exit /b
) else (
    echo Updates are available. Downloading...
	git pull
)



:end_script
pause
exit /b
