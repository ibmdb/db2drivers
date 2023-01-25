# If you have dsdriver.dmg image for MacOS, just run this script
# to get clidriver for macos platform

   alias sanitizeClidriver='cd clidriver; mv adm/* bin; rm -rf adm; cd bnd; rm -f ddcs400.lst  ddcsvm.lst ddcsmvs.lst  ddcsvse.lst db2cli.lst; echo "db2ajgrt.bnd+" > db2cli.lst; echo "db2clipk.bnd+" >> db2cli.lst; echo "db2clist.bnd+" >> db2cli.lst; echo "db2cli.bnd" >> db2cli.lst; chmod 444 db2cli.lst; cd ../.. ; rm -f clidriver/lib/*db2o.*'
   alias showFiles='ls -l clidriver/lib; ls clidriver/bnd; cat clidriver/bnd/db2cli.lst'

   cd /Users/bjha/nodework
   rm -rf clidriver_pre ibm_data_server_driver_for_odbc_cli.tar.gz macos64_odbc_cli.tar.gz
   mv clidriver clidriver_pre
# Put the dsdriver image name below
   hdiutil attach special_26260_v11.5.8_macos_dsdriver.dmg
   cp /Volumes/dsdriver/odbc_cli_driver/macos/ibm_data_server_driver_for_odbc_cli.tar.gz .
   tar -zxf ibm_data_server_driver_for_odbc_cli.tar.gz
   cp -r /Volumes/dsdriver/security64 clidriver
   hdiutil detach /Volumes/dsdriver/
   sanitizeClidriver
#   cp clidriver_pre/lib/libstdc++.6.dylib clidriver/lib
   cd clidriver/lib
   rm -f libdb2o.dylib libDB2xml4c.58.dylib libDB2xml4c.dylib 
   ln -s libDB2xml4c.58.0.dylib libDB2xml4c.58.dylib
   ln -s libDB2xml4c.58.0.dylib libDB2xml4c.dylib
   chmod 775 libdb2.dylib
   install_name_tool -change /usr/local/opt/gcc@8/lib/gcc/8/libstdc++.6.dylib /usr/local/lib/gcc/8/libstdc++.6.dylib  libdb2.dylib
   install_name_tool -change /usr/local/opt/gcc@8/lib/gcc/8/libgcc_s.1.dylib /usr/local/lib/gcc/8/libgcc_s.1.dylib  libdb2.dylib
   chmod 555 libdb2.dylib
   cd ../..
   tar -zcf macos64_odbc_cli.tar.gz clidriver
   rm -f ibm_data_server_driver_for_odbc_cli.tar.gz
   showFiles
   otool -L clidriver/lib/libdb2.dylib

