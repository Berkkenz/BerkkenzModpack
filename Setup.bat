@echo off
setlocal

:start
echo Checking if Git is installed...
git --version
echo %errorlevel%
if %errorlevel% equ 0 (
	echo Git is already installed.
	goto githubcheck
) else (
	echo Git is not installed. Downloading Git...
	powershell -command "Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.34.1.windows.1/Git-2.34.1-64-bit.exe' -OutFile 'GitInstaller.exe'"
	echo Installing Git...
	start /wait GitInstaller.exe /VERYSILENT /NORESTART
	del GitInstaller.exe
	if %errorlevel% neq 0 (
		echo Git install failed.
		pause
		exit /b 1
	) else (
		echo Git installed successfully.
		timeout 3 /nobreak
	)
)

:githubcheck
cls
cd /d %~dp0
if not exist ".git" (
	echo Initializing Git repository...
	git init
	git remote add origin https://github.com/Berkkenz/BerkkenzModpack.git
)

git fetch origin main

git diff --quiet HEAD origin/main
if %errorlevel% equ 0 (
	if exist %gitfile% (
		echo Update completed, continuing install...
		timeout 3 /nobreak
		goto install
	) else (
		echo Your local repository is up-to-date.
		timeout 3 /nobreak
		goto install
	)
) else (
	echo Updates are available. Starting update...
	git reset --hard origin/main
		echo Update installed, restarting
		set gitfile=%temp%\gitresetfile.txt
		timeout 2.5 /nobreak
		goto start
	)
	
	git clean -fd
	if %errorlevel% neq 0 (
		echo Git clean failed.
		pause
		exit /b 1
	)
)
