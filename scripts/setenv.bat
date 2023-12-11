:: Script file to set environment variables for clidriver

@ECHO OFF

if "%IBM_DB_HOME%" == "" (SET IBM_DB_HOME=%cd%\..)

SET PATH=%IBM_DB_HOME%\bin;%IBM_DB_HOME%\adm;%IBM_DB_HOME%\lib;%PATH%
SET LIB=%IBM_DB_HOME%\lib;%LIB%

:END
ECHO ON
@EXIT /B 0
