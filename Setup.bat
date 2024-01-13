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
		goto mcheck
	) else (
		cls
		echo Your local repository is up-to-date.
		timeout 3
		goto mcheck
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
:mcheck
if not exist %appdata%\.minecraft (
	echo Minecraft is not installed on the C drive. Please install Minecraft!
	pause
	exit /b 1
)
echo Minecraft installed.
pause
:javaone
if exist %ProgramFiles%\Java\jre-1.8\bin\java.exe" (
	echo Java 1.8 installed
	pause
	goto javatwo
) else (
	start /wait %~dp0\Content\Exe\jre-8u391-windows-x64.exe /s
	if %errorlevel% neq 0 (
		cls
		echo Java 1.8 install failed.
		pause
		exit /b 1
	)
	echo Java 1.8 installed.
	timeout 2.5 /nobreak
	goto mcheck
)

:javatwo
if exist %ProgramFiles%Java\jdk-17\bin\java.exe
	echo Java 17.0.9 installed.
	pause
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
	pause
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
if exist %appdata%\.minecraft\versions\forge-1.19.2-43.3.7
	echo Forge installed.
	pause
	goto install
) else (
	java -jar %~dp0\Content\Folders\Exe\forge-1.19.2-43.3.7-installer.jar --installClient
	if %errorlevel% neq 0 (
		echo Forge failed to install.
		pause
		exit /b 1
	)
	echo Forge has installed.
	goto mcheck
)

:install
echo Deleting configs...
del "%appdata%\.minecraft\config" /s
echo Deleted configs.
echo Deleting mods...
del "%appdata%\.minecraft\mods" /s
echo Deleted mods
echo Deleting resourcepacks...
del "%appdata%\.minecraft\resourcepacks" /s
echo Deleted resourcepacks.
echo Deleting shaderpacks...
del "%appdata%\.minecraft\shaderpacks" /s
echo Deleted shaderpacks.
echo Copying configs...
copy "%~dp0\Content\.minecraft\config" "%appdata%\.minecraft"
echo Copied configs.
echo Copying mods...
copy "%~dp0\Content\.minecraft\mods" "%appdata%\.minecraft"
echo Copied mods.
echo Copying resourcepacks...
copy "%~dp0\Content\.minecraft\resourcepacks" "%appdata%\.minecraft"
echo Copied resourcepacks.
echo Copying shaderpacks...
copy "%~dp0\Content\.minecraft\shaderpacks" "%appdata%\.minecraft"
echo Copied shaderpacks.
cls
echo Install completed.
timeout 3 /nobreak
pause
exit /b 0