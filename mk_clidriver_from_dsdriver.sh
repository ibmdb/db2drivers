# !/bin/bash

# Make CLIDIVER from DSDRIVER for use by Open Source Drivers
# ===========================================================
#
# Usage:
# ------
# mk_clidriver_from_dsdriver.sh special_47376_v11.5.9_linuxx64_dsdriver.tar.gz 
# mk_clidriver_from_dsdriver.sh special_47376_v11.5.9_ntx64_odbc_cli.zip
# mk_clidriver_from_dsdriver.sh special_47376_v11.5.9_macos_dsdriver.dmg 
#
# For Linux and Unix platforms:
# -----------------------------
# 1. Download 64bit dsdriver from fix central and run this script by passing
#    file name.
# 2. zLinux: This script Copy libibmc++.so.1 from current directory into
#    odbc_cli for os390.
#    libibmc++.so.1 is copied from oemtools for 32 and 64 bit os390.
#
# For Windows:
# ------------
# 1. Download 64bit and 32bit odbc_cli.zip file from fix central on Linux system
# 2. Use this script to create clidriver for open source drivers.
# 3. Transfer generated zip files to Windows for modification as it do not have
#    include and security directories which comes with dsdriver only.
#
# After file transfer on Windows:
# 4. Download 64bit dsdriver installer from fix central and install on Windows.
#    DSDriver Install cmd, run on Admin command prompt: 
#    v11.5.9_ntx64_dsdriver_EN.exe /n v1159sb /p C:\\DSD1159SB
#    Or, setup.exe /n v121dsd /p C:\\DSD121GA
#
# 5. Copy "include" and "security" directory from installed dsdriver to 64bit
#    and 32bit unzipped odbc_cli driver directory.
# 6. Update db2cli.lst file manually for correct LFCR.
# 7. Recreate 64bit and 32bit odbc_cli zip files with same name.
#
# For MacOS:
# ----------
# 1. Download 64bit dsdriver.dmg file from fix central and run this script.
#

# Get file name from command line
filename="$1"
if [ "$filename" = "" ]; then
    echo "Please pass filename as argument after script name."
    echo "Usage:  mk_clidriver_from_dsdriver.sh <filename>"
    echo ""
    exit 1
fi

# Declare variables
createMacDriver=0
createWindowsDriver=0
createLUDriver=0
platform=`uname`
dir=`pwd`
file="${dir}/${filename}"
clidplat="linuxamd64"
osdplat="linuxx64"
ibmclid=""
bit="64" # for security directory

# Check file exist or not
if [[ ! -e "$file" ]]; then
  if [[ -e "$filename" ]]; then
    file="$filename" # filename has full path
  else
    echo "File $filename does not exist."
    exit 1
  fi
fi

# Check file extension
extension="${filename##*.}"
if [[ "$extension" != "gz" && "$extension" != "dmg" && "$extension" != "zip" ]]; then
    echo "Not a valid file extension."
    exit 1
fi

# Set variables to call functions for LUW and Mac drivers
if [[ "$filename" =~ _macos_dsdriver.dmg$ ]]; then
  if [ "$platform" = "Darwin" ]; then
    createMacDriver=1
  else
    echo "Run this script on MacOS for dsdriver.dmg file."
    exit 1
  fi
else
  if [ "$platform" = "Darwin" ]; then
    echo "Use dsdriver.dmg file to get clidriver on MacOS."
    exit 1
  fi
fi

if [[ "$filename" =~ _odbc_cli.zip$ ]]; then
    createWindowsDriver=1
fi
if [[ "$filename" =~ _dsdriver.tar.gz$ ]]; then
    createLUDriver=1
fi


# Define Functions to create clidriver
# ====================================

function getclidriver {
  cd $dir
  echo ""
  tarname="${osdplat}_odbc_cli.tar.gz"
  echo "Making ${tarname}"
  rm -rf clidriver odbc.tar.gz
  cp $ibmclid $dir/odbc.tar.gz
  tar xzf odbc.tar.gz
  cp -r dsdriver/security${bit} clidriver
  # aix32 do not have bnd directory
  if [ -e $dir/clidriver/bnd ]; then
    cd $dir/clidriver/bnd
    rm -rf *.lst
    echo "db2ajgrt.bnd+" > db2cli.lst
    echo "db2clipk.bnd+" >> db2cli.lst
    echo "db2clist.bnd+" >> db2cli.lst
    echo "db2cli.bnd" >> db2cli.lst
    chmod 755 *
    chmod 775 db2cli.lst
  fi
  if [ -e $dir/clidriver/db2dump ]; then
    cd $dir/clidriver/db2dump
    echo -n "" > db2diag.log
    chmod 664 db2diag.log
  fi
  cd $dir/clidriver 
  mv adm/* bin
  rm -rf adm
  rm -rf lib/*db2o.*
  # copy script files
  if [ -e "$dir/scripts/testconnection.sh" ]; then
    mkdir scripts
    cp ../scripts/testconnection.sh scripts
    cp ../scripts/setenv.sh scripts
    chmod 755 scripts/*
  else
    echo "==> File $dir/scripts/testconnection.sh does not exist!"
  fi
  chmod 775 *
  chmod 755 bin/* lib/* cfg/*
  cd $dir
  if [ "$osdplat" = "s390x64" ]; then
    cd clidriver/lib
    # Copy oemtools/linux390x64/ibmc++/libibmc++.so.1 from ibmgit
    if [ -e "$dir/64bit-libibmc++.so.1" ]; then
      cp $dir/64bit-libibmc++.so.1 libibmc++.so.1
      chmod 555 libibmc++.so.1
      ln -s libibmc++.so.1 libibmc++.so
    else
      echo "ERROR ==> File $dir/64bit-libibmc++.so.1 does not exist!"
    fi
    cd $dir
  fi
  if [ "$osdplat" = "s390" ]; then
    cd clidriver/lib
    if [ -e "$dir/libibmc++.so.1" ]; then
      cp $dir/libibmc++.so.1 libibmc++.so.1
      chmod 555 libibmc++.so.1
      ln -s libibmc++.so.1 libibmc++.so
    else
      echo "ERROR ==> File $dir/64bit-libibmc++.so.1 does not exist!"
    fi
    cd $dir
  fi
  rm -rf $tarname
  tar --preserve-permissions --xattrs -czf $tarname clidriver
  ls -l $tarname
  ls clidriver
  ls -l clidriver/lib
  echo ""
  ls -l *_odbc_cli.tar.gz
}

function mkdriver {
  rm -rf dsdriver
  tar xzf $file
  ibmclid="${dir}/dsdriver/odbc_cli_driver/${clidplat}/ibm_data_server_driver_for_odbc_cli.tar.gz"
  if [ -e $ibmclid ]; then
    bit="64"
    getclidriver
  else
    echo "${ibmclid} does not exist."
  fi
}

function mkdriver32 {
  ibmclid="${dir}/dsdriver/odbc_cli_driver/${clidplat}/ibm_data_server_driver_for_odbc_cli_32.tar.gz"
  if [ -e $ibmclid ]; then
    bit="32"
    getclidriver
  else
    echo "${ibmclid} does not exist."
  fi
}

function mkLinuxDriver {
  if [[ "$filename" =~ _linuxx64_dsdriver.tar.gz$ ]]; then
    clidplat="linuxamd64"
    osdplat="linuxx64"
    mkdriver
    clidplat="linuxia32"
    osdplat="linuxia32"
    mkdriver32
  fi

  if [[ "$filename" =~ _aix64_dsdriver.tar.gz$ ]]; then
    clidplat="aix64"
    osdplat="aix64"
    mkdriver
    clidplat="aix32"
    osdplat="aix32"
    mkdriver32
  fi

  if [[ "$filename" =~ _linuxppc64le_dsdriver.tar.gz$ ]]; then
    clidplat="linuxppc64le"
    osdplat="ppc64le"
    mkdriver
  fi

  if [[ "$filename" =~ _linux390x64_dsdriver.tar.gz$ ]]; then
    clidplat="linux390x64"
    osdplat="s390x64"
    mkdriver
    clidplat="linux390x32"
    osdplat="s390"
    mkdriver32
  fi
}

function mkWindowsDriver {
  if [[ "$filename" =~ _ntx64_odbc_cli.zip$ ]]; then
    rm -rf clidriver
    unzip -q $file
    osdplat="ntx64"
    mkntdriver
  fi

  if [[ "$filename" =~ _nt32_odbc_cli.zip$ ]]; then
    rm -rf clidriver
    unzip -q $file
    osdplat="nt32"
    mkntdriver
  fi

  echo ""
  ls -l *odbc_cli.zip
  echo "
    Windows zip files do not contain 'include' directory and IBMIAMauth64.dll.
    Get these file for Windows by installing dsdriver on Windows and
    then add include dir into 64bit and 32bit windows driver.
    DSDriver Install cmd: v11.5.8_ntx64_dsdriver_EN.exe /n v1158sb /p C:\\DSD1158SB
    Also, update db2cli.lst file on Windows manually for CRLF.
    "
}

function mkntdriver {
  echo ""
  zipname="${osdplat}_odbc_cli.zip"
  echo "Making ${zipname}"
  cd "${dir}/clidriver/bin"
  if [ "$osdplat" = "ntx64" ]; then
    rm -rf icc  x86.VC12.CRT x86.VC14.CRT db2app.dll db2cli.dll db2cli32.exe db2clio.dll db2clixml4c.dll db2diag.exe db2drdat.exe db2dsdcfgfill.exe db2ldap.dll db2ldapm.dll db2ldcfg.exe ibmdadb264.dll
    rm -rf db2odbc.dll db2odbc64.dll db2odbch.dll db2odbch64.dll db2oreg1.exe db2oreg132.exe db2osse.dll db2trc32.exe db2trcapi.dll db2trcd.exe 
    rm -rf DB2xml4c_cli_5_8.dll DB2xml4c_cli_5_8.dll.2.manifest IBM.DB2.APP.manifest IBM.DB2.CLI.manifest IBM.DB2.CLIO.manifest  IBM.DB2.CLIXML4C.manifest
    rm -rf IBM.DB2.LDAP.manifest IBM.DB2.LDAPM.manifest IBM.DB2.ODBC.manifest IBM.DB2.ODBCH.manifest IBM.DB2.ODBC64.manifest IBM.DB2.ODBCH64.manifest
    rm -rf IBM.DB2.SEC.manifest IBMIAMauth.dll IBMkrb5.dll IBMkrb5TwoPart.dll IBMLDAPauthclient.dll IBMOSauthclient.dll IBMOSauthclientTwoPart.dll

    cd ../lib
    rm -rf db2app.lib db2cli.lib db2clio.lib
    mv ../security64 ../security
  else
    rm -rf db2diag.exe db2drdat.exe db2dsdcfgfill.exe db2ldcfg.exe db2oreg1.exe
    rm -rf db2odbc.dll db2odbch.dll IBM.DB2.ODBC.manifest IBM.DB2.ODBCH.manifest
    mv ../security32 ../security
  fi

  if [ -e $dir/clidriver/bnd ]; then
    cd $dir/clidriver/bnd
    rm -rf *.lst
    echo "db2ajgrt.bnd+" > db2cli.lst
    echo "db2clipk.bnd+" >> db2cli.lst
    echo "db2clist.bnd+" >> db2cli.lst
    echo "db2cli.bnd" >> db2cli.lst
    chmod 775 *
  fi
  cd $dir/clidriver/msg/en_US
  rm -rf *.CRT *dll* db2nmp.xml db2diag.mo
  chmod 775 *
  # copy script files
  cd "${dir}/clidriver"
  if [ -e "$dir/scripts/testconnection.bat" ]; then
    mkdir scripts
    cp $dir/scripts/testconnection.bat scripts
    cp $dir/scripts/setenv.bat scripts
    chmod 775 scripts/*
  else
    echo "==> File $dir/scripts/testconnection.bat does not exist!"
    echo ""
  fi
  chmod 775 * license/* cfg/* lib/* bin/* db2/*
  cd $dir
  rm -rf $zipname
  zip -9yrq ${osdplat}_odbc_cli clidriver
  ls -l $zipname
  ls clidriver
  ls -l clidriver/lib
}

function mkMacDriver {
   #read -p "dsdriver.dmg file name: " dmgfile
   dmgfile="$file"
   # Remove any pre-attached dsdriver to avoid conflict
   hdiutil detach /Volumes/dsdriver/
   hdiutil attach $dmgfile

   rm -rf clidriver_pre ibm_data_server_driver_for_odbc_cli.tar.gz macos64_odbc_cli.tar.gz
   mv clidriver clidriver_pre
   cp /Volumes/dsdriver/odbc_cli_driver/macos/ibm_data_server_driver_for_odbc_cli.tar.gz .
   tar -zxf ibm_data_server_driver_for_odbc_cli.tar.gz
   cp -r /Volumes/dsdriver/security64 clidriver
   hdiutil detach /Volumes/dsdriver/

   # Modify clidriver and remove unwanted files
   cd clidriver
   mv adm/* bin; rm -rf adm
   cd bnd; rm -f ddcs400.lst  ddcsvm.lst ddcsmvs.lst  ddcsvse.lst db2cli.lst
   echo "db2ajgrt.bnd+" > db2cli.lst; echo "db2clipk.bnd+" >> db2cli.lst; echo "db2clist.bnd+" >> db2cli.lst; echo "db2cli.bnd" >> db2cli.lst
   chmod 444 db2cli.lst; cd ../..
#   cp clidriver_pre/lib/libstdc++.6.dylib clidriver/lib
#   cp libstdc++.6.dylib clidriver/lib
   cd clidriver/lib
   rm -f libdb2o.dylib libDB2xml4c.58.dylib libDB2xml4c.dylib 
   ln -s libDB2xml4c.58.0.dylib libDB2xml4c.58.dylib
   ln -s libDB2xml4c.58.0.dylib libDB2xml4c.dylib
   chmod 775 *
   install_name_tool -change /usr/local/opt/gcc@8/lib/gcc/8/libstdc++.6.dylib /usr/local/lib/gcc/8/libstdc++.6.dylib libdb2.dylib
   install_name_tool -change /usr/local/opt/gcc@8/lib/gcc/8/libgcc_s.1.dylib /usr/local/lib/gcc/8/libgcc_s.1.dylib  libdb2.dylib
   install_name_tool -change /Users/regress1/db2/engn/lib/bldsupp/libDB2xml4c.58.0.dylib @loader_path/libDB2xml4c.58.0.dylib libdb2clixml4c.dylib
   install_name_tool -change /usr/local/opt/gcc@8/lib/gcc/8/libstdc++.6.dylib /usr/local/lib/gcc/8/libstdc++.6.dylib libdb2clixml4c.dylib
   install_name_tool -id libdb2clixml4c.dylib libdb2clixml4c.dylib
   install_name_tool -id libDB2xml4c.58.0.dylib libDB2xml4c.58.0.dylib
   install_name_tool -id libdb2.dylib libdb2.dylib

   chmod 555 libdb2.dylib libdb2clixml4c.dylib libDB2xml4c.58.0.dylib
   cd ../bin
   install_name_tool -change ../lib/libdb2.dylib @loader_path/../lib/libdb2.dylib db2cli
   install_name_tool -change ../lib/libdb2.dylib @loader_path/../lib/libdb2.dylib db2diag
   install_name_tool -change ../lib/libdb2.dylib @loader_path/../lib/libdb2.dylib db2drdat
   install_name_tool -change ../lib/libdb2.dylib @loader_path/../lib/libdb2.dylib db2dsdcfgfill
   install_name_tool -change ../lib/libdb2.dylib @loader_path/../lib/libdb2.dylib db2level
   install_name_tool -change ../lib/libdb2.dylib @loader_path/../lib/libdb2.dylib db2support
   install_name_tool -change ../lib/libdb2.dylib @loader_path/../lib/libdb2.dylib db2trc
   chmod 755 *
   cd ..
   chmod 775 license cfg
   if [ -e ./db2dump ] ; then
       chmod 775 db2dump
       echo -n "" > db2dump/db2diag.log
       chmod 664 db2dump/db2diag.log
   fi

   if [ -e "$dir/scripts/testconnection.sh" ]; then
     mkdir scripts
     cp ../scripts/testconnection.sh scripts
     cp ../scripts/setenv.sh scripts
     chmod 755 scripts/*
   else
     echo "==> File $dir/scripts/testconnection.sh does not exist!"
     echo ""
   fi
   chmod 775 * 
   chmod 755 bnd/* cfg/* license/*

   cd ..
   if [ `uname -m` == "x86_64" ]; then
     tar --preserve-permissions --xattrs -czf macos64_odbc_cli.tar.gz clidriver
   else
     tar --preserve-permissions --xattrs -czf macarm64_odbc_cli.tar.gz clidriver
   fi
   rm -f ibm_data_server_driver_for_odbc_cli.tar.gz
   ls -l clidriver/lib; ls clidriver/bnd; cat clidriver/bnd/db2cli.lst
   otool -L clidriver/lib/libdb2.dylib
   echo ""
   ls -l *_odbc_cli.tar.gz
}

# Call functions to create clidriver
# ==================================
if [ "$createMacDriver" = "1" ]; then
    mkMacDriver
fi
if [ "$createWindowsDriver" = "1" ]; then
    mkWindowsDriver
fi
if [ "$createLUDriver" = "1" ]; then
    mkLinuxDriver
fi

# Clean up
rm -rf odbc.tar.gz dsdriver clidriver
echo ""
echo "Done!"
echo ""

