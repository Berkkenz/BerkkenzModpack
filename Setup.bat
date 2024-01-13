@echo off
setlocal enabledelayedexpansion

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

if not exist %systemroot%\System32\curl.exe (
	echo Curl not installed. Contact Berkken mans.
	pause
	exit /b 1
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
		goto mcheck
	) else (
		cls
		echo Your local repository is up-to-date.
		timeout 3
		goto mcheck
	)
) else (
	cls
	echo Updates are available. Starting update...
	timeout 3
	
	git reset --hard origin/main
	
	git clean -fd
	echo Update installed, restarting
	echo UpdateFile > %temp%\updatefile.txt
	timeout 2.5 /nobreak
	goto start
)
:mcheck
cls
if not exist %appdata%\.minecraft (
	echo Minecraft is not installed on the C drive. Please install Minecraft!
	pause
	exit /b 1
)

echo Minecraft installed.
:javaone
if exist %programfiles%\Java\jre-1.8\bin\java.exe" (
	for /f "tokens=*" %%i in ('%programfiles%\Java\jre-1.8\bin\java.exe -version 2^>^%1') do set JAVA_VERSION=%%i
	echo %JAVA_VERSION% | findstr /C: "1.8.0_391" > nul
	if %errorlevel% == 0 (
		echo Java JRE 1.8.0_391 is installed.
	) else (
		echo Java JRE 1.8.0_391 is not installed or not the correct version.
	)
) else (
	echo Java JRE 1.8.0_391 Executable is not found.

:javatwo
if exist %ProgramFiles%Java\jdk-17\bin\java.exe
	echo Java 17.0.9 installed.
	goto versioncheck
) else (
	echo Downloading JDK 17.0.9...
	curl -o "%temp%" "https://download.oracle.com/java/17/archive/jdk-17.0.9_windows-x64_bin.exe"
	if %errorlevel% neq 0 (
		echo JDK 17.0.9 has failed download.
		pause
		exit /b 1
	)
	echo Installing JDK 17.0.9...
	start /wait %temp%\jdk-17.0.9_windows-x64_bin.exe /s
	if %errorlevel% neq 0 (
		echo JDK 17.0.9 has failed install.
		pause
		exit /b 1
	)
	del %temp%\jdk-17.0.9_windows-x64_bin.exe /s
	echo Java 17.0.9 has installed.
	timeout 2.5 /nobreak
	goto mcheck
)

:versioncheck
if exist %appdata%\.minecraft\versions\1.19.2 (
	echo Version installed.
	goto forgecheck
) else (
	echo Copying 1.19.2 folder to .minecraft...
	xcopy "%~dp0\Content\Folders\versions\1.19.2" "%appdata%\.minecraft\versions"
	if %errorlevel% neq 0 (
		echo Version install failed.
		pause
		exit /b 1
	)
	echo Version installed.
	timeout 2.5 /nobreak
	goto mcheck
)

:forgecheck
if exist "%appdata%\.minecraft\versions\1.19.2-forge-43.3.7" (
	echo Forge installed.
	goto install
) else (
	call "%~dp0\Content\Exe\forgefile.bat"
	if exist "%~dp0\forge-1.19.2-43.3.7-installer.jar.log" del "%~dp0\forge-1.19.2-43.3.7-installer.jar.log"
	if %errorlevel% neq 0 (
		echo Forge install failed.
		pause
		exit /b 1
	)
	
	echo Forge has installed.
	goto mcheck
)

:install
echo Deleting configs...
del /f /q "%appdata%\.minecraft\config"
echo Deleted configs.
echo Deleting mods...
del /f /q "%appdata%\.minecraft\mods"
echo Deleted mods
echo Deleting resourcepacks...
del /f /q "%appdata%\.minecraft\resourcepacks"
echo Deleted resourcepacks.
echo Deleting shaderpacks...
del /f /q "%appdata%\.minecraft\shaderpacks"
echo Deleted shaderpacks.
echo Copying configs...
xcopy /Y "%~dp0\Content\.minecraft\config" "%appdata%\.minecraft"
echo Copied configs.
echo Copying mods...
xcopy /Y "%~dp0\Content\.minecraft\mods" "%appdata%\.minecraft"
echo Copied mods.
echo Copying resourcepacks...
xcopy /Y "%~dp0\Content\.minecraft\resourcepacks" "%appdata%\.minecraft"
echo Copied resourcepacks.
echo Copying shaderpacks...
xcopy /Y "%~dp0\Content\.minecraft\shaderpacks" "%appdata%\.minecraft"
echo Copied shaderpacks.
cls
echo Install completed. Exiting...
timeout 3 /nobreak
exit /b 0