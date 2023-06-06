#!/bin/bash

AMUSERID=${5}
AM_USER="uid=${AMUSERID},ou=People,dc=openam,dc=forgerock,dc=org"

echo ${6} > /tmp/pwd.txt
chmod 400 /tmp/pwd.txt

# Create new self-signed certificate(s) to be used by am
keytool -genkeypair -alias pwclocal -keyalg RSA -keysize 4096 -sigalg SHA512withRSA -validity 3650 -dname 'CN=pwclocal, OU=IFS, O=PricewaterhouseCoopers IT Services Limited, L=Austin, ST=TX, C=US' -keystore ${3}/openam/openam/pwc_am_keystore.jceks -storetype JCEKS -keypass ${6} -storepass ${6}

keytool -genkeypair -alias rsajwtsigningkey -keyalg RSA -keysize 4096 -sigalg SHA512withRSA -validity 3650 -dname 'CN=pwcrsajwtsigningkey, OU=IFS, O=PricewaterhouseCoopers IT Services Limited, L=Austin, ST=TX, C=US' -keystore ${3}/openam/openam/pwc_am_keystore.jceks -storetype JCEKS -keypass ${6} -storepass ${6}

echo -n ${6} > ${3}/openam/openam/.pwc_am_keypass

echo -n ${6} > ${3}/openam/openam/.pwc_am_storepass

chmod 400 ${3}/openam/openam/.pwc_am_keypass

chmod 400 ${3}/openam/openam/.pwc_am_storepass

# Create a transport key
keytool -genseckey -alias "sms.transport.key" -keyalg AES -keysize 128 -storetype jceks -keystore ${3}/openam/openam/pwc_am_keystore.jceks -storepass:file ${3}/openam/openam/.pwc_am_storepass -keypass:file ${3}/openam/openam/.pwc_am_keypass

# Update the am configuration ...
${3}/SSOAdminTools/openam/bin/ssoadm update-server-cfg  -u ${AM_USER} -f /tmp/pwd.txt -s default -a com.sun.identity.saml.xmlsig.keystore=%BASE_DIR%/%SERVER_URI%/pwc_am_keystore.jceks com.sun.identity.saml.xmlsig.storepass=%BASE_DIR%/%SERVER_URI%/.pwc_am_storepass com.sun.identity.saml.xmlsig.keypass=%BASE_DIR%/%SERVER_URI%/.pwc_am_keypass com.sun.identity.saml.xmlsig.certalias=pwclocal
${3}/SSOAdminTools/openam/bin/ssoadm set-attr-defs -u ${AM_USER} -f /tmp/pwd.txt -t organization  -s sunFAMSAML2Configuration -a metadataSigningKey=pwclocal
${3}/SSOAdminTools/openam/bin/ssoadm set-realm-svc-attrs -u ${AM_USER} -f /tmp/pwd.txt -s iPlanetAMAuthService -e /pwc -a iplanet-am-auth-key-alias=pwclocal

# clean up
rm -rf /tmp/pwd.txt
