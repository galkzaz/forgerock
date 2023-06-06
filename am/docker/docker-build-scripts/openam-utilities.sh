#!/bin/bash

# Command Syntax: openam-utilities.sh install_am|setup_ssoadm|configure_am <am_host> <am_url> <openam_directory> <tomcat_directory> <userid> <password> <environment>

if [ $# -ne 8 ]; then
  printf "Command Syntax: openam-utilities.sh install_am|setup_ssoadm|configure_am <am_host> <am_url> <openam_directory> <tomcat_directory> <userid> <password> <environment>\n"
  exit 0
fi

if [ -d ${5} ]; then
  if [ ! -f ${5}/bin/catalina.sh ]; then
    printf "The directory '${5}' is not a valid tomcat directory\n"
    exit 0
  fi

  case $1 in
    install_am|INSTALL_AM)
      printf "Installing AM ...\n"
      #cat /opt/openam/tomcat/logs/catalina.out
      cat /etc/hosts
      curl \
    --insecure \
      'https://am.myforgerock.com:8443/openam' 

      ${4}/amster/amster ./docker-build-scripts/amster/install-am.amster \
          -D javax.net.ssl.trustStore=${5}/conf/certs/tomcat_keystore.pfx \
          -D javax.net.ssl.trustStorePassword=changeit \
          -D AM_URL=${3} \
          -D AM_PASSWORD=${7} \
          -D AM_HOME=${4}/openam

      # Execute and notify the caller if this fails.
      if [[ $? -ne 0 ]]; then
          echo "Amster Installation failed"
          exit 1
      fi

     keytool -exportcert \
      -keystore /${4}/openam/opends/config/keystore \
      -storepass $(cat ${4}/openam/opends/config/keystore.pin) \
      -alias ssl-key-pair \
      -rfc \
      -file /tmp/ds-cert.pem

      keytool \
      -storepass changeit -keypass changeit \
      -importcert \
      -file /tmp/ds-cert.pem \
      -keystore ${5}/conf/certs/tomcat_keystore.pfx \
      -noprompt
      ;;
    setup_ssoadm|SETUP_SSOADM)
      printf "Setting up ssoadm ...\n"

      cd ${4}/SSOAdminTools/

      #./setup -p ${4}/openam -d ${4}/SSOAdminTools/debug -l ${4}/SSOAdminTools/logs --acceptLicense

     ./setup --truststore-path ${4}/openam/security/keystores/truststore --truststore-password changeit --truststore-type PKCS12 -p ${4}/openam -d ${4}/SSOAdminTools/debug -l ${4}/SSOAdminTools/logs --acceptLicense
      # Need to update ssoadm to include the truststore used by tomcat.  This will correct issues with processing the
      # certificates.
      sed -i 's/$truststore_path/\/opt\/openam\/tomcat\/conf\/certs\/tomcat_keystore.pfx/' ${4}/SSOAdminTools/openam/bin/ssoadm
      sed -i 's/$truststore_password/changeit/' ${4}/SSOAdminTools/openam/bin/ssoadm
      sed -i 's/$truststore_type/PKCS12/' ${4}/SSOAdminTools/openam/bin/ssoadm
      sed -i '/com.sun.identity.cli.CommandManager "$@"/i -D"org.forgerock.openam.ssoadm.auth.indexType=service" \\' ${4}/SSOAdminTools/openam/bin/ssoadm
      sed -i '/com.sun.identity.cli.CommandManager "$@"/i -D"org.forgerock.openam.ssoadm.auth.indexName=ldapService" \\' ${4}/SSOAdminTools/openam/bin/ssoadm
 
      cd - &>/dev/null

      ;;
    configure_am|CONFIGURE_AM)
      printf "Configuring AM ...\n"

      # Configure item(s) using ssoadm
      #./docker-build-scripts/ssoadm-configure-am.sh ${3} ${4} ${5} ${7} ${8}

      # Configure item(s) using amster
      ${4}/amster/amster ./docker-build-scripts/amster/configure-am-pwc.amster \
          -D javax.net.ssl.trustStore=${5}/conf/certs/tomcat_keystore.pfx \
          -D javax.net.ssl.trustStorePassword=changeit \
          -D AM_URL=${3} \
          -D AM_HOST=${2} \
          -D AMSTER_KEY=${4}/openam/amster_rsa \
          -D AM_CONFIG_PATH=${4}/amster/configs

      ;;
    *)
      printf "The command '${1}' is not valid; valid commands are install_am, setup_ssoadm, or configure_am.\n"
      ;;
  esac
else
  printf "Unable to locate the directory '${4}'\n"
fi
