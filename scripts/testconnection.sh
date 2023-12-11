# Script file to try connection to target server using ODBC driver
# and collect db2trace files for this connection to diagnose the
# connection related issue and make sure setup is proper.
# This script is only for non-Windows platform.

# Update database connection string in below command and run using "./testconnection.sh" command

connStr="DATABASE=sample;HOSTNAME=dbserver.host.com;PORT=50000;UID=dbuser;PWD=dbpasswd;"

# For SSL connection, use below connection string - comment above line and uncomment below one
#connStr="DATABASE=sample;HOSTNAME=db2server.host.com;PORT=50000;UID=dbuser;PWD=dbpass;SECURITY=SSL;SSLServerCertificate=/full/path/of/certificateFile.arm;"


if [ "$IBM_DB_HOME" == "" ]
then
  IBM_DB_HOME=`pwd`/clidriver
else
  echo "Env var IBM_DB_HOME is set to $IBM_DB_HOME"
fi
OS=`uname`

export PATH=$IBM_DB_HOME/bin:$IBM_DB_HOME/adm:$IBM_DB_HOME/lib:$PATH
if [ "$OS" == "Darwin" ]
then
  export DYLD_LIBRARY_PATH=$IBM_DB_HOME/lib:$DYLD_LIBRARY_PATH
else
  export LD_LIBRARY_PATH=$IBM_DB_HOME/lib:$LD_LIBRARY_PATH
fi

rm -rf 1.trc 1.flw 1.fmt 1.fmtc 1.cli 1.txt
if [ "$OS" == "Darwin" ]
then
  db2trc on -t -l 2m
else
  db2trc on -t -f 1.trc
fi
sleep 5

# ACTUAL COMMAND
db2cli validate -connstring "$connStr" -connect | tee 1.txt

# You can use either above db2cli command to test full connection string or
# below command to test TCPIP connection.
# Keep only one and comment other. Better to use above validate command.
#db2cli validate -database "sample:hotel.torolab.ibm.com:21169" -connect -user newton -passwd serverpass

if [ "$OS" == "Darwin" ]
then
db2trc dump 1.trc
fi
db2trc off
db2trc flw -t 1.trc 1.flw
db2trc fmt 1.trc 1.fmt
db2trc fmt -c 1.trc 1.fmtc
db2trc fmt -cli 1.trc 1.cli

