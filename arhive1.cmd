@ECHO OFF

SETLOCAL
REM ===== ��⠭���� ��६����� =====

REM ��ᯮ������� ��������� � �ணࠬ���� 䠩���:
SET PROGPATH=C:\programs\cmd
SET ZIP=%PROGPATH%\7-ZipPortable\App\7-Zip\7z.exe

REM ��⠫��, � ���஬ �㤥� �࠭����� ��娢:
SET ARCHPATH=C:\Arhiv\%1

REM �६���� ��⠫��, ����� �㤥� �ᯮ�짮������
REM � ��楤�� ��樨 ��娢��
REM ��⠫�� ������ ��室����� �� ����� ��᪥ � ��⠫���� ��娢�,
REM ⮣�� ��६�饭�� �㤥� ���������.
SET TMPDIR=c:\temp
SET TMPFILE=%PROGPATH%\arhrotation.txt
SET TMPFILE2=%PROGPATH%\arhrotation2.txt

REM ����쪮 ���� �࠭��� ��娢� (�஢��� �࠭����):
SET LEVEL=5

REM ��䨪� ����� ��娢� (� ����)
REM %1 - ��� ��娢��㥬�� ���� (Stroy, Plitka ��� �� ��㣮�)
REM ��।����� �� �맮�� �� ��������� 䠩�� arhive.cmd,
REM ��� � �६� ���� ��������� �� ᮧ����� ��娢�:
SET ARCHNAME=%ARCHPATH%\%1

REM ���� ����:
SET LOG=%ARCHPATH%\%1.log

REM ����-ᯨ᮪ ���-䠩���. �ᯮ������ � �㭪樨 :LOGROTATION
SET REN_LIST=%PROGPATH%\ren_list.txt

REM ��ᯮ������� 䠩��-ᯨ᪠ ��� ��娢�樨
SET LIST=%PROGPATH%\%1_list.txt

REM ��ᯮ������� 䠩��-ᯨ᪠ �᪫�祭�� ��� ��娢�樨
SET XLIST=%PROGPATH%\xlist.txt 

REM ��⠭���� ������⢠ ����⮪ ������祭�� �⥢��� ��᪠
SET TRY=20

REM ��ନ஢���� ��६�����, ᮤ�ঠ�� �६� � ����
REM �㦭� ��� ���������� ��娢�� � ��樨
SET NOW=%DATE:~-4%%DATE:~3,2%%DATE:~0,2%
SET DAY=%DATE:~0,2%
SET /a DAY_BEGIN=%DAY%-1
SET DATE_BEGIN=%DATE:~-4%%DATE:~3,2%%DAY_BEGIN%
REM ��६����� TIMESTAMP ��室���� ���⠢����, �஢���� �᫮���
REM � ��७��� ���, ����� ��������� �������騩 ���� (04:30, ���ਬ��),
REM �� ᠬ�� ���� ����⠢����� �஡�� ( 4:30).
REM ���⮬� ��室���� �� �஢����� �, �� ����室�����, ����⠢����
REM ��� ���� ᠬ����⥫쭮.
SET UTRO=%TIME:~0,1%
IF "%UTRO%" == " " (
   SET TIMESTAMP=%DATE:~-4%%DATE:~3,2%%DATE:~0,2%-0%TIME:~1,1%%TIME:~3,2%
) ELSE (
   SET TIMESTAMP=%DATE:~-4%%DATE:~3,2%%DATE:~0,2%-%TIME:~0,2%%TIME:~3,2%
)


REM ��⠭���� ��६����� ��� ࠡ��� ��⥬� �����饭�� �� �. ����:
SET ZERAT=%PROGPATH%\zerat\zerat.exe
SET ZERAT_FILES=%PROGPATH%\zerat\files
SET MAILLIST=%ZERAT_FILES%\maillist.txt
SET SMTPSENDER=sender@mydomain.ru 
SET SMTPSERVER=mail.mydomain.ru
SET SMTPPORT=25 
SET SMTPUSER=sender@mydomain.ru 
SET SMTPPWD=password 
SET CODEPAGE=Windows-1251

REM �஢�ઠ � ᮧ�����, �� ����室�����, 䠩���, ����室���� ��� ࠡ���
REM ��⥬� �����饭�� �� �. ����
IF NOT EXIST %ZERAT_FILES%\%1_error.txt (
   ECHO SMTPHOST:mail.mydomain.ru:25 >> %ZERAT_FILES%\%1_error.txt
   ECHO FROM:Sender ^<sender@mydomain.ru^> >> %ZERAT_FILES%\%1_error.txt
   ECHO TO:Admin ^<admin@mydomain.ru^> >> %ZERAT_FILES%\%1_error.txt
   ECHO SUBJECT:Error of Backup of 1C %1. >> %ZERAT_FILES%\%1_error.txt
   ECHO SMTPAuth:LOGIN >> %ZERAT_FILES%\%1_error.txt
   ECHO SMTPUSER:sender@mydomain.ru >> %ZERAT_FILES%\%1_error.txt
   ECHO SMTPPASS:password >> %ZERAT_FILES%\%1_error.txt
   ECHO CHARSET:Windows-1251 >> %ZERAT_FILES%\%1_error.txt
   ECHO Unsuccessfully completed to creation backup copy of the database 1C %1. >> %ZERAT_FILES%\%1_error.txt
   ECHO Backup file not finded on Z: disk. >> %ZERAT_FILES%\%1_error.txt
   ECHO Check your backup procedure. >> %ZERAT_FILES%\%1_error.txt
)

IF NOT EXIST %ZERAT_FILES%\%1_success.txt (
   ECHO SMTPHOST:mail.mydomain.ru:25 >> %ZERAT_FILES%\%1_success.txt
   ECHO FROM:Sender ^<sender@mydomain.ru^> >> %ZERAT_FILES%\%1_success.txt
   ECHO TO:Admin ^<admin@mydomain.ru^> >> %ZERAT_FILES%\%1_success.txt
   ECHO SUBJECT:Backup of 1C %1. >> %ZERAT_FILES%\%1_success.txt
   ECHO SMTPAuth:LOGIN >> %ZERAT_FILES%\%1_success.txt
   ECHO SMTPUSER:sender@mydomain.ru >> %ZERAT_FILES%\%1_success.txt
   ECHO SMTPPASS:password >> %ZERAT_FILES%\%1_success.txt
   ECHO CHARSET:Windows-1251 >> %ZERAT_FILES%\%1_success.txt
   ECHO Successfully completed to creation backup copy of the database 1C %1. >> %ZERAT_FILES%\%1_success.txt
   ECHO Backup file is on Z: disk. >> %ZERAT_FILES%\%1_success.txt
)

)
IF NOT EXIST %ZERAT_FILES%\maillist.txt (
   ECHO admin@mydomain.ru >> %ZERAT_FILES%\maillist.txt
REM   ECHO user1@mudomain.ru >> %ZERAT_FILES%\maillist.txt
REM   ECHO user2@mydomain.ru >> %ZERAT_FILES%\maillist.txt
)

REM ��⠫�� �� �ࢥ�, � ���஬ ���� �࠭����� ��娢�,
REM ���� �� �������� ��⠫��� \\192.168.0.1\backup\
SET PATH_ON_SERVER=test\%1

REM ==== �ணࠬ���� ���� ====

REM �� ��ࢮ� ����᪥ ��⮬���᪨ �㤥� ᮧ��� ��⠫��, � ����� �㤥� �믮������� ��娢���.
REM �᫨ �� �� �������.
IF NOT EXIST %ARCHPATH% MD %ARCHPATH%

REM ������ � ���-䠩� �६��� ��砫� ��娢�樨
ECHO ========================== >> %LOG%
ECHO Start backup at >> %LOG%
DATE /T >> %LOG%
TIME /T >> %LOG%


REM ����⢥���, ��娢��� ������ �믮������ �⮩ ��������.
%ZIP% a -t7z -r %ARCHNAME%-%TIMESTAMP% @%LIST% -x@%XLIST% -scsWIN

REM ����� 䠩��� ��娢��, �⮡� �� �������� �� ��᪮��筮��.
MOVE %ARCHPATH%\*.7z %TMPDIR%\1\
DIR %TMPDIR%\1 /a-d /b /o-d > %TMPFILE%
CALL :ARHROTATION %LEVEL% %TMPFILE%

REM ������祭�� �⥢��� ��᪠
:CONNECT
NET USE Z: /d /y
FOR /L %%N IN (1,1,%TRY%) DO (
   IF NOT EXIST Z:\nul (
      NET USE Z: \\192.168.0.1\backup\%PATH_ON_SERVER% /user:username userpassword /persistent:no
      ECHO Disk Z: connected sucsessfully! >> %log%
   ) ELSE (
      ECHO Disk Z: already connected! >> %log%
	  GOTO EXIT01
   )
)
:EXIT01

REM �� �ࢥ� ����� ��� ����஢��� ⮫쪮 ᠬ� ᢥ��� ��娢,
REM �.�. �।��騥 ⠬ 㦥 ������ ����.
REM ��� �᪮���� ��娢� �ନ����� ⠪:
REM %1-%NOW%-*.7z
REM %1 - �室��� ��ࠬ��� �⮣� .cmd 䠩��, ��� ��娢��㥬�� ����
REM %NOW% - ᥣ������� ���
REM  * - ���, �� ��᫥ ����, �.�. �६� ᮧ����� ��娢�, � ������ ��砥 ����������

REM ����஢���� ��娢� �� �ࢥ� (ᨭ�஭����� ��⠫����, �᫨ ���� ���)
%PROGPATH%\robocopy %ARCHPATH% Z:\ /MIR /E /Z /R:100 /TBD

REM �஢�ઠ ����⢮����� ��娢� �� �ࢥ� � ��ࠢ�� 㢥�������� �� ����
IF EXIST "Z:\%1-%NOW%-*.7z" (
   ECHO File exist
   CALL :SENDMSG %ZERAT_FILES%\%1_success.txt
) ELSE (
   ECHO File not exist
   CALL :SENDMSG %ZERAT_FILES%\%1_error.txt
)

REM �⪫�祭�� �⥢��� ��᪠
NET USE Z: /d /y

REM ������ � ���-䠩� �६��� ����砭�� ��娢�樨
ECHO End backup at >> %LOG%
DATE /T >> %LOG%
TIME /T >> %LOG%

REM ����� �����
REM ����᪠���� ⮫쪮 �� ���� �᫠� �����
IF %DAY% == 01 CALL :LOGROTATION


GOTO END

REM =========== FUNCTIONS ============

REM ===== Begin ARHROTATION function =====
:ARHROTATION
REM http://forum.script-coding.com/viewtopic.php?id=7493

:: �뢮� n ����� ��ப 䠩��
::
:: �ᯮ�짮�����:
:: head n filename
::
:: �ਬ��:
:: head 10 %windir%\System32\drivers\etc\hosts

:: ����室�� �६���� 䠩� ��� �࠭���� n ����஢ ����� ��ப � ���� "[n]"
(

for /l %%n in ( 1, 1, %~1 ) do (
    echo.[%%n]
)

)>"%TEMP%\$$$head.txt"

:: �㬥�㥬 ������ ��ப�
:: �饬 ⮫쪮 ��ப� � ������� ����஬ � �뢮��� �� ��ப�
:: �� ����砭�� �६���� 䠩� 㤠�塞
for /f "tokens=1,* delims=]" %%n in (
    'find /n /v "" "%~2" ^| findstr /b /l /g:"%TEMP%\$$$head.txt" ^&^& del "%TEMP%\$$$head.txt"'
) do (
    echo.%%o >> %TMPFILE2%
)


FOR /F %%f in ('TYPE %TMPFILE2%') DO (
MOVE %TMPDIR%\1\%%f %TMPDIR%\2
)
DEL /F /Q %TMPDIR%\1\*.*
MOVE %TMPDIR%\2\*.* %ARCHPATH%
DEL %TMPFILE2%

EXIT /b
REM ===== End ARHROTATION function =====

REM ===== Begin SENDMSG function =====
:SENDMSG

%ZERAT% %1

EXIT /b
REM ===== End SENDMSG function =====


REM ===== Begin LOGROTATION function =====
:LOGROTATION
IF NOT EXIST %LOG% EXIT /b
REM ECHO %LOG% > %REN_LIST%
FOR /F %%f in ('TYPE %REN_LIST%') DO (
IF EXIST %%f.bak DEL %%f.bak
IF EXIST %%f REN %%f %%~nxf.bak
)
EXIT /b
REM ===== End LOGROTATION function =====

REM =========== END FUNCTIONS ============

:END