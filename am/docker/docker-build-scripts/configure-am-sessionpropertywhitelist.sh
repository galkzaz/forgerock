#!/bin/bash

AMUSERID=${5}
AM_USER="uid=${AMUSERID},ou=People,dc=openam,dc=forgerock,dc=org"
COOKIENAME="iPlanetDirectoryPro"
ENVIRONMENT=${7}

echo ${6} > /tmp/pwd.txt
chmod 400 /tmp/pwd.txt

# Create authentication token
token=`curl -X POST -H "X-OpenAM-Username: ${AMUSERID}" -H "X-OpenAM-Password: ${6}" -H "Content-Type: application/json" -H "Accept-API-Version: resource=2.1" -d '{}' -s -k "${2}/json/realms/root/authenticate?authIndexType=service&authIndexValue=adminconsoleservice" | awk -F: '{print $2}' | awk -F, '{print $1}' | tr -d '"'`

spwldata='{"sessionPropertyWhitelist":["am.protected.country","am.protected.ppiAMCtxId","am.protected.userId","am.protected.empId","am.protected.uimail","am.protected.emailAddress","am.protected.otpRequired"]}'

# OAuth2 Proviider
pwcspwl=`curl -X PUT -H "${COOKIENAME}:${token}" -H "Content-Type: application/json" -H "Accept-API-Version: resource=1.0" -d "${spwldata}" -s -k "${2}/json/realms/root/realms/pwc/realm-config/services/amSessionPropertyWhitelist"`

pwcsandboxspwl=`curl -X PUT -H "${COOKIENAME}:${token}" -H "Content-Type: application/json" -H "Accept-API-Version: resource=1.0" -d "${spwldata}" -s -k "${2}/json/realms/root/realms/pwc/realms/sandbox/realm-config/services/amSessionPropertyWhitelist"`

# clean up
rm -rf /tmp/pwd.txt
