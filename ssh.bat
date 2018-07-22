@echo off

SET /P USER=Type in the username of the user running boot2docker, as installed by Kitematic:

REM Find the port connected to the VBoxHeadless.exe that is LISTENING
REM
REM The VBoxHeadless.exe process can be found at:
REM VBoxSVC.exe >
REM  VBoxHeadless.exe >
REM    VBoxHeadless.exe >
REM     VBoxHeadless.exe

FOR /F "tokens=1,2,3,4,5" %%A IN ( '"tasklist /fi "imagename eq vboxheadless.exe" /nh"' ) DO (
  REM There will be at least three entries spawned by VBoxSVC
  CALL :bypid %%B
)
GOTO :eof

:bypid
  FOR /F "tokens=1,2,3,4,5" %%A IN (
    '"netstat -aon | find /I "listen" | find "127.0.0.1" | findstr %1"'
  ) DO (
    REM We look up the IP:PORT for each PID
    CALL :port %%B
  )
GOTO :eof

:port
  SET str=%1
  REM Here are the ports being used
  REM The `:` starts a parsing system that captures the string
  REM "127.0.0.1:" and sets it equal to "".
  REM Thus returning just the port! (and there should only be one port)

  REM echo %str:127.0.0.1:=%

  REM Going to be lazy and just SSH in
  REM USER is defined at the top of the script!
  CALL :ssh %USER%,%str:127.0.0.1:=%
GOTO :eof

:ssh
  REM The file path, %userprofile%\.docker\machine\machines\default, was enforced by Kitematic
  REM "..\%1" was tossed on in case the containers are running as a secondary user.
  runas /user:%computername%\%1 "ssh -F /dev/null -o ConnectionAttempts=3 -o ConnectTimeout=10 -o ControlMaster=no -o ControlPath=none -o PasswordAuthentication=no -o ServerAliveInterval=60 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null docker@127.0.0.1 -o IdentitiesOnly=yes -i %userprofile%\..\%1\.docker\machine\machines\default\id_rsa -p %2"
GOTO :eof

:eof
