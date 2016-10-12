@ECHO OFF

echo y | logoff rdp-tcp

timeout /T 10

TASKKILL /T /F /IM 1cv8.exe

timeout /T 10

CALL %~dp0\arhive1.cmd plitka
CALL %~dp0\arhive1.cmd stroy

:END