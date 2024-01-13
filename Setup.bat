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
	if exist "%temp%\updatefile.txt" (
		cls
		echo Update completed, continuing install...
		del %temp%\updatefile.txt
		timeout 3
		goto install
	) else (
		cls
		echo Your local repository is up-to-date.
		timeout 3
		goto install
	)
) else (
	echo Updates are available. Starting update...
	timeout 3
	
	git reset --hard origin/main
	
	git clean -fd
	echo Update installed, restarting
	echo UpdateFile > %temp%\updatefile.txt
	timeout 2.5 /nobreak
	goto start
)
	
:install

:javainstallone
set JAVA_VERSION=1.8.0_391

for /f "tokens=*" %%i in ('dir /b /s %SystemDrive%\^| findstr /i %JAVA_VERSION%') do (
    echo Java %JAVA_VERSION% is installed
    goto :found
)

echo Java %JAVA_VERSION% is not installed
goto :eof

:found
pause
exit /b 0