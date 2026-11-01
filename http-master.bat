@echo off
rem http-master - start an HTTP or HTTPS server for any folder from a small menu.
rem Windows 10/11. macOS and Linux: http-master.sh. Same menu, same options.
rem Server: Node.js http-server. Missing dependencies are installed with winget on request,
rem HTTPS certificates are generated locally with openssl.
setlocal EnableExtensions EnableDelayedExpansion

set "VERSION=10.0.0"
set "REPO=adm1nsys/http-master"
set "SERVERMASTER_URL=https://adm1nsys.github.io/ServerMaster/"
set "HTTP_SERVER_PKG=http-server@14"
set "WINDOW_TITLE=http-master server"

set "CONFIG_DIR=%APPDATA%\http-master"
set "CONFIG_FILE=%CONFIG_DIR%\config.txt"
set "CERT_DIR=%CONFIG_DIR%\certs"
set "LOG_FILE=%CONFIG_DIR%\server.log"

set "ROOT=%CD%"
set "PORT=8080"
set "ACCESS=local"
set "PROTO=http"
set "ASSUME_YES=0"
set "ACTION=menu"

call :load_config

rem ---------- arguments ----------
:args
if "%~1"=="" goto run
if /i "%~1"=="--serve" (
  set "ACTION=serve"
  set "NEXT=%~2"
  if defined NEXT if not "!NEXT:~0,1!"=="-" (
    set "ROOT=%~f2"
    shift
  )
  goto next_arg
)
if /i "%~1"=="--port" ( set "PORT=%~2" & shift & goto next_arg )
if /i "%~1"=="--https" ( set "PROTO=https" & goto next_arg )
if /i "%~1"=="--network" ( set "ACCESS=network" & goto next_arg )
if /i "%~1"=="--yes" ( set "ASSUME_YES=1" & goto next_arg )
if /i "%~1"=="--gen-cert" ( set "ACTION=gen-cert" & goto next_arg )
if /i "%~1"=="--install-deps" ( set "ACTION=install" & goto next_arg )
if /i "%~1"=="--check-update" ( set "ACTION=update" & goto next_arg )
if /i "%~1"=="--version" ( echo http-master %VERSION% & exit /b 0 )
if /i "%~1"=="--help" ( call :usage & exit /b 0 )
echo Unknown option: %~1
call :usage
exit /b 2
:next_arg
shift
goto args

:run
if "%ACTION%"=="serve" ( call :serve_foreground & exit /b !errorlevel! )
if "%ACTION%"=="gen-cert" ( call :generate_cert & exit /b !errorlevel! )
if "%ACTION%"=="install" ( call :install_dependencies & exit /b !errorlevel! )
if "%ACTION%"=="update" ( call :check_update & exit /b !errorlevel! )

rem ---------- menu ----------
:menu
cls
call :header
set "CERT_STATE=not created yet"
if exist "%CERT_DIR%\localhost.crt" set "CERT_STATE=ready"
set "ACCESS_TEXT=this computer only"
if "%ACCESS%"=="network" set "ACCESS_TEXT=local network"
echo   Folder             %ROOT%
echo   Port               %PORT%
echo   Access             %ACCESS_TEXT%
echo   HTTPS certificate  %CERT_STATE%
echo.
echo   [1] Start HTTP            [2] Start HTTPS
echo   [3] Choose folder         [4] Change port         [5] Toggle access
echo   [6] Generate certificate  [7] Install dependencies
echo   [8] Check for updates     [9] Open ServerMaster   [0] Quit
choice /c 1234567890 /n >nul
set "PICK=%errorlevel%"
if "%PICK%"=="1" ( set "PROTO=http" & call :start_server )
if "%PICK%"=="2" ( set "PROTO=https" & call :start_server )
if "%PICK%"=="3" call :choose_folder
if "%PICK%"=="4" call :set_port
if "%PICK%"=="5" call :toggle_access
if "%PICK%"=="6" ( call :generate_cert & pause )
if "%PICK%"=="7" ( call :install_dependencies & pause )
if "%PICK%"=="8" ( call :check_update & pause )
if "%PICK%"=="9" start "" "%SERVERMASTER_URL%"
if "%PICK%"=="10" exit /b 0
if defined QUIT exit /b 0
goto menu

:toggle_access
if "%ACCESS%"=="local" ( set "ACCESS=network" ) else ( set "ACCESS=local" )
call :save_config
exit /b 0

:header
echo http-master %VERSION% - static HTTP/HTTPS server for any folder
echo Need PHP, Node.js apps or a database? -^> ServerMaster: %SERVERMASTER_URL%
echo.
exit /b 0

rem ---------- config ----------
:load_config
if not exist "%CONFIG_FILE%" exit /b 0
for /f "usebackq tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
  if /i "%%A"=="ROOT" if exist "%%B\" set "ROOT=%%B"
  if /i "%%A"=="PORT" set "PORT=%%B"
  if /i "%%A"=="ACCESS" set "ACCESS=%%B"
  if /i "%%A"=="PROTO" set "PROTO=%%B"
)
exit /b 0

:save_config
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"
> "%CONFIG_FILE%" (
  echo ROOT=%ROOT%
  echo PORT=%PORT%
  echo ACCESS=%ACCESS%
  echo PROTO=%PROTO%
)
exit /b 0

rem ---------- helpers ----------
:confirm
rem call :confirm "Question"  -> errorlevel 0 = yes
if "%ASSUME_YES%"=="1" exit /b 0
choice /c YN /n /m "%~1 [Y/N] "
if errorlevel 2 exit /b 1
exit /b 0

:lan_ip
set "LAN_IP="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp,Manual -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike '169.*' -and $_.IPAddress -ne '127.0.0.1' } | Select-Object -First 1).IPAddress"`) do set "LAN_IP=%%I"
exit /b 0

:find_openssl
set "OPENSSL="
for %%X in (openssl.exe) do if not "%%~$PATH:X"=="" set "OPENSSL=%%~$PATH:X"
if not defined OPENSSL if exist "%ProgramFiles%\Git\usr\bin\openssl.exe" set "OPENSSL=%ProgramFiles%\Git\usr\bin\openssl.exe"
if not defined OPENSSL if exist "%ProgramFiles%\OpenSSL-Win64\bin\openssl.exe" set "OPENSSL=%ProgramFiles%\OpenSSL-Win64\bin\openssl.exe"
exit /b 0

:port_in_use
rem call :port_in_use 8080 -> errorlevel 0 when something listens on it
netstat -ano -p tcp | findstr /r /c:":%~1 .*LISTENING" >nul
exit /b %errorlevel%

rem ---------- dependencies ----------
:ensure_node
where npx >nul 2>&1 && exit /b 0
echo ! Node.js is not installed - http-master runs the server with Node's http-server.
call :confirm "Install Node.js LTS with winget now?" || ( echo Get it from https://nodejs.org & exit /b 1 )
winget install -e --id OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements || exit /b 1
echo Node.js installed - open a new terminal window so it is on your PATH, then start http-master again.
exit /b 1

:ensure_openssl
call :find_openssl
if defined OPENSSL exit /b 0
echo ! openssl is needed to generate a certificate for HTTPS.
call :confirm "Install OpenSSL with winget now?" || exit /b 1
winget install -e --id ShiningLight.OpenSSL.Light --accept-package-agreements --accept-source-agreements || exit /b 1
call :find_openssl
if defined OPENSSL exit /b 0
exit /b 1

:install_dependencies
call :ensure_node || exit /b 1
where http-server >nul 2>&1 && ( echo + http-server is installed ) || (
  call :confirm "Install http-server globally with npm (otherwise npx downloads it on first start)?" && call npm install -g %HTTP_SERVER_PKG%
)
call :ensure_openssl && echo + openssl is available
exit /b 0

rem ---------- certificates ----------
:generate_cert
call :ensure_openssl || exit /b 1
if not exist "%CERT_DIR%" mkdir "%CERT_DIR%"
call :lan_ip
set "SAN=DNS:localhost,IP:127.0.0.1"
if defined LAN_IP set "SAN=%SAN%,IP:%LAN_IP%"
set "CNF=%TEMP%\http-master-%RANDOM%.cnf"
> "%CNF%" (
  echo [req]
  echo distinguished_name = dn
  echo x509_extensions = ext
  echo prompt = no
  echo [dn]
  echo CN = localhost
  echo O = http-master
  echo [ext]
  echo subjectAltName = %SAN%
  echo basicConstraints = critical,CA:FALSE
  echo keyUsage = critical,digitalSignature,keyEncipherment
  echo extendedKeyUsage = serverAuth
)
"%OPENSSL%" req -x509 -newkey rsa:2048 -nodes -sha256 -days 825 -keyout "%CERT_DIR%\localhost.key" -out "%CERT_DIR%\localhost.crt" -config "%CNF%" >nul 2>&1
set "RC=%errorlevel%"
del "%CNF%" >nul 2>&1
if not "%RC%"=="0" ( echo x openssl could not create the certificate. & exit /b 1 )
echo + Certificate created for %SAN%
echo   Stored in %CERT_DIR% - browsers will warn once, because it is self-signed.
exit /b 0

rem ---------- updates ----------
:check_update
set "LATEST="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "try { $t=(Invoke-RestMethod -TimeoutSec 8 https://api.github.com/repos/%REPO%/releases/latest).tag_name; ([regex]::Matches($t,'\d+\.\d+\.\d+') | Select-Object -Last 1).Value } catch {}"`) do set "LATEST=%%V"
if not defined LATEST ( echo ! Could not reach GitHub to check for updates. & exit /b 1 )
for /f "usebackq delims=" %%R in (`powershell -NoProfile -Command "[version]'%LATEST%' -gt [version]'%VERSION%'"`) do set "NEWER=%%R"
if /i not "%NEWER%"=="True" ( echo + You have the latest version ^(%VERSION%^). & exit /b 0 )
echo Version %LATEST% is available ^(you have %VERSION%^).
call :confirm "Update now?" || exit /b 0
powershell -NoProfile -Command "Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/%REPO%/v%LATEST%/http-master.bat -OutFile '%~f0.new'" || ( echo x Update failed. & exit /b 1 )
rem replace this file after cmd has finished reading it
start "" /b cmd /c "timeout /t 1 >nul & move /y "%~f0.new" "%~f0" >nul & echo + Updated to %LATEST% - start http-master again."
set "QUIT=1"
exit /b 0

rem ---------- server ----------
:prepare_start
if not exist "%ROOT%\" ( echo x Folder not found: %ROOT% & exit /b 1 )
call :ensure_node || exit /b 1
if "%PROTO%"=="https" if not exist "%CERT_DIR%\localhost.crt" (
  echo No certificate yet - generating one for HTTPS.
  call :generate_cert || exit /b 1
)
:port_check
call :port_in_use %PORT%
if not errorlevel 1 (
  echo ! Port %PORT% is busy - trying the next one.
  set /a PORT+=1
  goto port_check
)
set "BIND=127.0.0.1"
if "%ACCESS%"=="network" set "BIND=0.0.0.0"
set "HS=npx --yes %HTTP_SERVER_PKG%"
where http-server >nul 2>&1 && set "HS=http-server"
set "TLS="
if "%PROTO%"=="https" set "TLS=-S -C "%CERT_DIR%\localhost.crt" -K "%CERT_DIR%\localhost.key""
exit /b 0

:show_urls
echo   %PROTO%://localhost:%PORT%
if "%ACCESS%"=="network" (
  call :lan_ip
  if defined LAN_IP echo   %PROTO%://!LAN_IP!:%PORT%   ^(other devices in your network^)
)
exit /b 0

:start_server
call :prepare_start || ( pause & exit /b 1 )
call :save_config
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"
echo Starting %PROTO% server for %ROOT% ...
start "%WINDOW_TITLE%" /min cmd /c "%HS% "%ROOT%" -p %PORT% -a %BIND% -c-1 %TLS% > "%LOG_FILE%" 2>&1"
set /a WAITED=0
:wait_up
timeout /t 1 /nobreak >nul
call :port_in_use %PORT%
if not errorlevel 1 goto running
set /a WAITED+=1
if %WAITED% lss 30 goto wait_up
echo x The server did not start. Log: %LOG_FILE%
type "%LOG_FILE%"
call :stop_server
pause
exit /b 1

:running
cls
call :header
echo + Serving %ROOT%
call :show_urls
echo.
echo   [O] Open in browser    [L] Show log    [S] Stop and back    [Q] Stop and quit
choice /c OLSQ /n >nul
set "PICK=%errorlevel%"
if "%PICK%"=="1" start "" "%PROTO%://localhost:%PORT%"
if "%PICK%"=="2" ( cls & type "%LOG_FILE%" & pause )
if "%PICK%"=="3" ( call :stop_server & exit /b 0 )
if "%PICK%"=="4" ( call :stop_server & set "QUIT=1" & exit /b 0 )
goto running

:stop_server
taskkill /fi "WINDOWTITLE eq %WINDOW_TITLE%*" /t /f >nul 2>&1
exit /b 0

:serve_foreground
call :prepare_start || exit /b 1
echo Serving %ROOT%
call :show_urls
call %HS% "%ROOT%" -p %PORT% -a %BIND% -c-1 %TLS%
exit /b %errorlevel%

:choose_folder
echo   [1] Type a path    [2] Use the current folder    [3] Pick in a dialog
choice /c 123 /n >nul
set "PICK=%errorlevel%"
set "PICKED="
if "%PICK%"=="1" set /p "PICKED=Folder: "
if "%PICK%"=="2" set "PICKED=%CD%"
if "%PICK%"=="3" for /f "usebackq delims=" %%F in (`powershell -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $d=New-Object System.Windows.Forms.FolderBrowserDialog; $d.Description='Folder to serve'; if($d.ShowDialog() -eq 'OK'){ $d.SelectedPath }"`) do set "PICKED=%%F"
if not defined PICKED exit /b 0
if exist "%PICKED%\" ( set "ROOT=%PICKED%" & call :save_config ) else ( echo x Not a folder: %PICKED% & pause )
exit /b 0

:set_port
set "NEWPORT="
set /p "NEWPORT=Port (1024-65535, now %PORT%): "
if not defined NEWPORT exit /b 0
set /a NP=NEWPORT 2>nul
if %NP% geq 1024 if %NP% leq 65535 ( set "PORT=%NP%" & call :save_config & exit /b 0 )
echo x Not a valid port.
pause
exit /b 0

:usage
echo http-master %VERSION% - static HTTP/HTTPS server for any folder
echo.
echo Usage:
echo   http-master                       open the menu
echo   http-master --serve [DIR]         start right away (Ctrl+C to stop)
echo       --port N                      port (default 8080 or the last one used)
echo       --https                       serve over HTTPS (a certificate is generated if needed)
echo       --network                     listen on all interfaces, not just this computer
echo   http-master --gen-cert            create a new self-signed certificate
echo   http-master --install-deps        install Node.js, http-server and openssl if missing
echo   http-master --check-update        look for a newer release
echo   http-master --version ^| --help
echo   Add --yes to answer prompts with yes.
echo.
echo More (PHP, Node.js apps, databases): %SERVERMASTER_URL%
exit /b 0
