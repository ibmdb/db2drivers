# !/bin/bash

# Download 64bit dsdriver for non-windows platforms
# Copy libibmc++.so.1 from oemtools for os390 platforms

# Make macos driver on Mac System only using mkmacosclidriver.sh script.

# For Windows, download 64bit and 32bit odbc_cli driver zip file. These
# Windows zip files do not contain 'include' directory.
# Get include directory for Windows by installing dsdriver on Windows and
# then add include dir into 64bit and 32bit windows driver.
# DSDriver Install cmd: v11.5.8_ntx64_dsdriver_EN.exe /n v1158sb /p C:\\DSD1158SB
# Copy include dir and security dir files from dsdriver to clidriver on windows
# Also, update db2cli.lst file on Windows manually for LFCR.

echo "Making odbc_cli.tar.gz for open source drivers from dsdriver.tar.gz file ..."
echo "Please enter the tar.gz file prefix as project ex. special_36648_v11.5.9"
read -p "PROJECT = " project
#project="special_36648_v11.5.9"

clidplat="linuxamd64"
osdplat="linuxx64"
dir=`pwd`
bit="64"
ibmclid="${dir}/dsdriver/odbc_cli_driver/${clidplat}/ibm_data_server_driver_for_odbc_cli.tar.gz"
mkdir $dir/$project

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
  mkdir scripts
  cp $dir/scripts/testconnection.sh scripts
  cp $dir/scripts/setenv.sh scripts
  chmod 775 * scripts/*
  chmod 755 bin/* lib/* cfg/*
  cd $dir
  if [ "$osdplat" = "s390x64" ]; then
    cd clidriver/lib
    # Copy oemtools/linux390x64/ibmc++/libibmc++.so.1 from ibmgit
    cp $dir/64libibmc++.so.1 libibmc++.so.1
    chmod 555 libibmc++.so.1
    ln -s libibmc++.so.1 libibmc++.so
    cd $dir
  fi
  if [ "$osdplat" = "s390" ]; then
    cd clidriver/lib
    cp $dir/libibmc++.so.1 libibmc++.so.1
    chmod 555 libibmc++.so.1
    ln -s libibmc++.so.1 libibmc++.so
    cd $dir
  fi
  rm -rf $tarname
  tar --preserve-permissions --xattrs -czf $tarname clidriver
  mv $tarname $project
  ls -l $project/$tarname
  ls clidriver
  ls -l clidriver/lib
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
  file="${dir}/${project}_linuxx64_dsdriver.tar.gz"
  if [ -e $file ]; then
    mkdriver
    clidplat="linuxia32"
    osdplat="linuxia32"
    mkdriver32
  fi

  file="${dir}/${project}_aix64_dsdriver.tar.gz"
  if [ -e $file ]; then
    clidplat="aix64"
    osdplat="aix64"
    mkdriver
    clidplat="aix32"
    osdplat="aix32"
    mkdriver32
  fi

  file="${dir}/${project}_linuxppc64le_dsdriver.tar.gz"
  if [ -e $file ]; then
    clidplat="linuxppc64le"
    osdplat="ppc64le"
    mkdriver
  fi

  file="${dir}/${project}_linux390x64_dsdriver.tar.gz"
  if [ -e $file ]; then
    clidplat="linux390x64"
    osdplat="s390x64"
    mkdriver
    clidplat="linux390x32"
    osdplat="s390"
    mkdriver32
  fi
}

function mkWindowsDriver {
  file="${dir}/${project}_ntx64_odbc_cli.zip"
  if [ -e $file ]; then
    rm -rf clidriver
    unzip -q $file
    osdplat="ntx64"
    mkntdriver
  fi

  file="${dir}/${project}_nt32_odbc_cli.zip"
  if [ -e $file ]; then
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
    "
}

function mkntdriver {
  echo ""
  zipname="${osdplat}_odbc_cli.zip"
  echo "Making ${zipname}"
  cd "${dir}/clidriver/bin"
  if [ "$osdplat" = "ntx64" ]; then
    rm -rf icc  x86.VC12.CRT db2app.dll db2cli.dll db2cli32.exe db2clio.dll db2clixml4c.dll db2diag.exe db2drdat.exe db2dsdcfgfill.exe db2ldap.dll db2ldapm.dll db2ldcfg.exe ibmdadb264.dll
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
    echo "db2ajgrt.bnd+\r" > db2cli.lst
    echo "db2clipk.bnd+\r" >> db2cli.lst
    echo "db2clist.bnd+\r" >> db2cli.lst
    echo "db2cli.bnd\r" >> db2cli.lst
    chmod 775 *
  fi
  # copy script files
  cd "${dir}/clidriver"
  mkdir scripts
  cp $dir/scripts/testconnection.bat scripts
  cp $dir/scripts/setenv.bat scripts
  chmod 775 * scripts/*
  chmod 775 license/* cfg/* lib/* bin/* db2/*
  cd $dir/clidriver/msg/en_US
  rm -rf *.CRT *dll* db2nmp.xml db2diag.mo
  chmod 775 *
  cd $dir
  rm -rf $zipname
  zip -9yrq ${osdplat}_odbc_cli clidriver
  mv $zipname $project
  ls -l $project/$zipname
  ls clidriver
  ls -l clidriver/lib
}

mkLinuxDriver
mkWindowsDriver

# Clean up
rm -rf odbc.tar.gz
ls -l *_odbc_cli.tar.gz
echo ""
echo "Done!"
echo ""

