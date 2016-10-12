@ECHO OFF

SETLOCAL
REM ===== Установка переменных =====

REM Расположение командных и программных файлов:
SET PROGPATH=C:\programs\cmd
SET ZIP=%PROGPATH%\7-ZipPortable\App\7-Zip\7z.exe

REM Каталог, в котором будет храниться архив:
SET ARCHPATH=C:\Arhiv\%1

REM Временный каталог, который будет использоваться
REM в процедуре ротации архивов
REM Каталог должен находиться на одном диске с каталогом архива,
REM тогда перемещение будет мгновенным.
SET TMPDIR=c:\temp
SET TMPFILE=%PROGPATH%\arhrotation.txt
SET TMPFILE2=%PROGPATH%\arhrotation2.txt

REM Сколько дней хранить архивы (уровень хранения):
SET LEVEL=5

REM Префикс имени архива (с путём)
REM %1 - имя архивируемой базы (Stroy, Plitka или любое другое)
REM передаётся при вызове из головного файла arhive.cmd,
REM дата и время будут добавлены при создании архива:
SET ARCHNAME=%ARCHPATH%\%1

REM Файл лога:
SET LOG=%ARCHPATH%\%1.log

REM Файл-список лог-файлов. Используется в функции :LOGROTATION
SET REN_LIST=%PROGPATH%\ren_list.txt

REM Расположение файла-списка для архивации
SET LIST=%PROGPATH%\%1_list.txt

REM Расположение файла-списка исключений для архивации
SET XLIST=%PROGPATH%\xlist.txt 

REM Установка количества попыток подключения сетевого диска
SET TRY=20

REM Формирование переменных, содержащих время и дату
REM Нужно для именования архивов и ротации
SET NOW=%DATE:~-4%%DATE:~3,2%%DATE:~0,2%
SET DAY=%DATE:~0,2%
SET /a DAY_BEGIN=%DAY%-1
SET DATE_BEGIN=%DATE:~-4%%DATE:~3,2%%DAY_BEGIN%
REM Переменную TIMESTAMP приходится выставлять, проверяя условие
REM В утренние часы, когда присутствует лидирующий ноль (04:30, например),
REM на самом деле подставляется пробел ( 4:30).
REM Поэтому приходится это проверять и, при необходимости, подставлять
REM этот ноль самостоятельно.
SET UTRO=%TIME:~0,1%
IF "%UTRO%" == " " (
   SET TIMESTAMP=%DATE:~-4%%DATE:~3,2%%DATE:~0,2%-0%TIME:~1,1%%TIME:~3,2%
) ELSE (
   SET TIMESTAMP=%DATE:~-4%%DATE:~3,2%%DATE:~0,2%-%TIME:~0,2%%TIME:~3,2%
)


REM Установка переменных для работы системы оповещения по эл. почте:
SET ZERAT=%PROGPATH%\zerat\zerat.exe
SET ZERAT_FILES=%PROGPATH%\zerat\files
SET MAILLIST=%ZERAT_FILES%\maillist.txt
SET SMTPSENDER=sender@mydomain.ru 
SET SMTPSERVER=mail.mydomain.ru
SET SMTPPORT=25 
SET SMTPUSER=sender@mydomain.ru 
SET SMTPPWD=password 
SET CODEPAGE=Windows-1251

REM Проверка и создание, при необходимости, файлов, необходимых для работы
REM системы оповещения по эл. почте
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

REM Каталог на сервере, в котором будут храниться архивы,
REM считая от базового каталога \\192.168.0.1\backup\
SET PATH_ON_SERVER=test\%1

REM ==== Программная часть ====

REM При первом запуске автоматически будет создан каталог, в который будет выполняться архивация.
REM Если он не существует.
IF NOT EXIST %ARCHPATH% MD %ARCHPATH%

REM Запись в лог-файл времени начала архивации
ECHO ========================== >> %LOG%
ECHO Start backup at >> %LOG%
DATE /T >> %LOG%
TIME /T >> %LOG%


REM Собственно, архивация данных выполняется этой командой.
%ZIP% a -t7z -r %ARCHNAME%-%TIMESTAMP% @%LIST% -x@%XLIST% -scsWIN

REM Ротация файлов архивов, чтобы не копились до бесконечности.
MOVE %ARCHPATH%\*.7z %TMPDIR%\1\
DIR %TMPDIR%\1 /a-d /b /o-d > %TMPFILE%
CALL :ARHROTATION %LEVEL% %TMPFILE%

REM Подключение сетевого диска
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

REM На сервер имеет смысл копировать только самый свежий архив,
REM т.к. предыдущие там уже должны быть.
REM Имя искомого архива формируется так:
REM %1-%NOW%-*.7z
REM %1 - входной параметр этого .cmd файла, имя архивируемой базы
REM %NOW% - сегодняшняя дата
REM  * - всё, что после даты, т.е. время создания архива, в данном случае игнорируется

REM Копирование архива на сервер (синхронизация каталогов, если быть точным)
%PROGPATH%\robocopy %ARCHPATH% Z:\ /MIR /E /Z /R:100 /TBD

REM Проверка существования архива на сервере и отправка уведомлений по почте
IF EXIST "Z:\%1-%NOW%-*.7z" (
   ECHO File exist
   CALL :SENDMSG %ZERAT_FILES%\%1_success.txt
) ELSE (
   ECHO File not exist
   CALL :SENDMSG %ZERAT_FILES%\%1_error.txt
)

REM Отключение сетевого диска
NET USE Z: /d /y

REM Запись в лог-файл времени окончания архивации
ECHO End backup at >> %LOG%
DATE /T >> %LOG%
TIME /T >> %LOG%

REM Ротация логов
REM Запускается только по первым числам месяца
IF %DAY% == 01 CALL :LOGROTATION


GOTO END

REM =========== FUNCTIONS ============

REM ===== Begin ARHROTATION function =====
:ARHROTATION
REM http://forum.script-coding.com/viewtopic.php?id=7493

:: Вывод n первых строк файла
::
:: Использование:
:: head n filename
::
:: Пример:
:: head 10 %windir%\System32\drivers\etc\hosts

:: Необходим временный файл для хранения n номеров первых строк в виде "[n]"
(

for /l %%n in ( 1, 1, %~1 ) do (
    echo.[%%n]
)

)>"%TEMP%\$$$head.txt"

:: нумеруем каждую строку
:: ищем только строки с заданным номером и выводим эти строки
:: по окончании временный файл удаляем
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