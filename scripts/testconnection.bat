:: Script file to try connection to target server using ODBC driver
:: and collect db2trace files for this connection to diagnose the
:: connection related issue and make sure setup is proper.
:: This script is only for Windows platform.

@ECHO OFF
:: Update your database connection string in below command and run this file:
set connStr="DATABASE=sample;HOSTNAME=db2server.host.com;PORT=50000;UID=dbuser;PWD=dbpass;"

:: For SSL connection, use below connection string - comment above line and uncomment below one
:: set connStr="DATABASE=sample;HOSTNAME=db2server.host.com;PORT=50000;UID=dbuser;PWD=dbpass;SECURITY=SSL;SSLServerCertificate=C:\\full\\path\\of\\certificate.file;"

if "%IBM_DB_HOME%" == "" (SET IBM_DB_HOME=%cd%\..)
echo IBM_DB_HOME=%IBM_DB_HOME%

SET PATH=%IBM_DB_HOME%\bin;%IBM_DB_HOME%\adm;%IBM_DB_HOME%\lib;%PATH%
SET LIB=%IBM_DB_HOME%\lib;%LIB%

DEL /F 1.trc 1.flw 1.fmt 1.fmtc 1.cli
db2trc on -t -f 1.trc

db2cli validate -connstring %connStr%  -connect
:: You can use either above db2cli command to test full connection string
:: including SSL connection or run below command to test TCPIP connection.
:: Keep only one and comment other. Better to use above validate command.
::db2cli validate -database "sample:hotel.torolab.ibm.com:21169" -connect -user dbuser -passwd serverpass

db2trc off
db2trc flw -t 1.trc 1.flw
db2trc fmt 1.trc 1.fmt
db2trc fmt -c 1.trc 1.fmtc
db2trc fmt -cli 1.trc 1.cli

:END
ECHO ON
@EXIT /B 0
