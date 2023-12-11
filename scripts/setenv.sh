# Script file to set environment variables for clidriver 
# This script is only for non-Windows platforms.
# Run "source ./setenv.sh" or ". ./setenv.sh" to apply it.

if [ "$IBM_DB_HOME" == "" ]
then
  IBM_DB_HOME=`pwd`/..
fi
OS=`uname`

export PATH=$IBM_DB_HOME/bin:$IBM_DB_HOME/adm:$IBM_DB_HOME/lib:$PATH
if [ "$OS" == "Darwin" ]
then
  export DYLD_LIBRARY_PATH=$IBM_DB_HOME/lib:$DYLD_LIBRARY_PATH
else
  if [ "$OS" == "AIX" ]
  then
    export LIBPATH=$IBM_DB_HOME/lib:$LIBPATH
  else
    export LD_LIBRARY_PATH=$IBM_DB_HOME/lib:$LD_LIBRARY_PATH
  fi
fi

export INCLUDE=$IBM_DB_HOME/include:$INCLUDE

