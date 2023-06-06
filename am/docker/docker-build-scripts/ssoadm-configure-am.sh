#!/bin/bash

AMUSERID=${5}
AM_USER="uid=${AMUSERID},ou=People,dc=openam,dc=forgerock,dc=org"
COOKIENAME="iPlanetDirectoryPro"
SITE="local"
ENVIRONMENT=${7}

echo ${6} > /tmp/pwd.txt
chmod 400 /tmp/pwd.txt

# Create authentication token
token=`curl -X POST -H "X-OpenAM-Username: ${AMUSERID}" -H "X-OpenAM-Password: ${6}" -H "Content-Type: application/json" -H "Accept-API-Version: resource=2.1" -d '{}' -s -k "${2}/json/realms/root/authenticate?authIndexType=service&authIndexValue=adminconsoleservice" | awk -F: '{print $2}' | awk -F, '{print $1}' | tr -d '""'`

# realms (using ssoadm to update the root realm, keep getting the following
#    {"code":501,"reason":"Not Implemented","message":"Cannot provide ID for Realm resource"}
# when trying to use the rest api for updating)
${3}/SSOAdminTools/openam/bin/ssoadm set-realm-attrs -u ${AM_USER} -f /tmp/pwd.txt -e / -s sunIdentityRepositoryService -a sunOrganizationAliases=
${3}/SSOAdminTools/openam/bin/ssoadm set-realm-attrs -u ${AM_USER} -f /tmp/pwd.txt -e / -s sunIdentityRepositoryService -p -a sunOrganizationAliases=am.myforgerock.com
#${3}/SSOAdminTools/openam/bin/ssoadm set-realm-attrs -u ${AM_USER} -f /tmp/pwd.txt -e / -s sunIdentityRepositoryService -p -a sunOrganizationAliases=am.myforgerock.com

#curl -X PUT -H "${COOKIENAME}:${token}" -H "Accept-API-Version: resource=1.0" -H "Content-Type: application/json" -d '{"aliases": ["am.myforgerock.com"]}' -s -k "${2}/json/global-config/realms/Lw"
pwcRealmId=`curl -X POST -H "${COOKIENAME}:${token}" -H "Accept-API-Version: resource=1.0" -H "Content-Type: application/json" -d '{"name": "pwc","active": true,"parentPath": "/","aliases":["openam","login.myforgerock.com","am.myforgerock.com"]}' -s -k "${2}/json/global-config/realms" | awk -F, '{print $1}' | awk -F: '{print $2}' | tr -d '""'`
sandboxRealmId=`curl -X POST -H "${COOKIENAME}:${token}" -H "Accept-API-Version: resource=1.0" -H "Content-Type: application/json" -d '{"name": "sandbox","active": true,"parentPath": "/pwc","aliases":[ ]}' -s -k "${2}/json/global-config/realms" | awk -F, '{print $1}' | awk -F: '{print $2}' | tr -d '""'`

# Script(s)
for realm in ./build/resources/scripts/*
do
  if [ -d ${realm} ]; then
    for context in ${realm}/*
    do
      if [ -d ${context} ]; then
        for scriptFile in ${context}/*
        do
          if [ -f ${scriptFile} ]; then
            realmList="realms/$(echo ${realm} | awk -F/ '{print $NF}' | sed -e "s/-/\/realms\//g")"
            scriptName=$(echo ${scriptFile} | awk -F/ '{print $NF}' | cut -d'.' -f 1)
            scriptLanguage=$(echo ${scriptFile} | awk -F/ '{print $NF}' | cut -d'.' -f 2)
            if [ "${scriptLanguage}" = "groovy" ]; then
              scriptLanguage="GROOVY"
            elif [ "${scriptLanguage}" == "js" ]; then
              scriptLanguage="JAVASCRIPT"
            fi
            context=$(echo ${context} | awk -F/ '{print $NF}')
            encScript=`cat ${scriptFile}`
            restData='{"name":"'${scriptName}'","description":"","script":"'${encScript}'","language":"'${scriptLanguage}'","context":"'${context}'"}'
            scriptId=`curl -X PUT -H "${COOKIENAME}:${token}" -H "Accept-API-Version: resource=1.1" -H "Content-Type: application/json" -d ${restData} -s -k "${2}/json/${realmList}/scripts/${scriptName}" | awk -F, '{print $1}' | awk -F: '{print $2}' | tr -d '""'`
          fi
        done
      fi
    done
  fi
done

# Scripted Authentication Module(s) (Need to use REST API, ssoadm is not working and will not be fixed)
#${3}/SSOAdminTools/openam/bin/ssoadm create-auth-instance -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -m ValidateDJAccountLockOut -t Scripted
samId=`curl -X PUT -H "${COOKIENAME}:${token}" -H "Content-Type: application/json" -H "Accept-API-Version: resource=1.0" -H "Accept: application/json" -d '{"clientScriptEnabled": false,"clientScript": null,"serverScript": "ValidateDJAccountLockOut","authenticationLevel":0}' -s -k "${2}/json/realms/root/realms/pwc/realm-config/authentication/modules/scripted/ValidateDJAccountLockOut" | awk -F, '{print $1}' | awk -F: '{print $2}' | tr -d '""'`
samId=`curl -X PUT -H "${COOKIENAME}:${token}" -H "Content-Type: application/json" -H "Accept-API-Version: resource=1.0" -H "Accept: application/json" -d '{"clientScriptEnabled": false,"clientScript": null,"serverScript": "IDMMandatoryPhoneNumberException","authenticationLevel":0}' -s -k "${2}/json/realms/root/realms/pwc/realm-config/authentication/modules/scripted/IDM_phoneNumberException" | awk -F, '{print $1}' | awk -F: '{print $2}' | tr -d '""'`
samId=`curl -X PUT -H "${COOKIENAME}:${token}" -H "Content-Type: application/json" -H "Accept-API-Version: resource=1.0" -H "Accept: application/json" -d '{"clientScriptEnabled": false,"clientScript": null,"serverScript": "IDMUpdateUsersProfile","authenticationLevel":0}' -s -k "${2}/json/realms/root/realms/pwc/realm-config/authentication/modules/scripted/IDM_updatePhoneNumber" | awk -F, '{print $1}' | awk -F: '{print $2}' | tr -d '""'`
samId=`curl -X PUT -H "${COOKIENAME}:${token}" -H "Content-Type: application/json" -H "Accept-API-Version: resource=1.0" -H "Accept: application/json" -d '{"clientScriptEnabled": false,"clientScript": null,"serverScript": "sharedStateUsername","authenticationLevel":0}' -s -k "${2}/json/realms/root/realms/pwc/realm-config/authentication/modules/scripted/ScriptSharedState" | awk -F, '{print $1}' | awk -F: '{print $2}' | tr -d '""'`

# OAuth2
oauth2Id=`curl -X PUT -H "${COOKIENAME}:${token}" -H "Content-Type: application/json" -H "Accept-API-Version: resource=1.0" -H "Accept: application/json" -d '{"clientScriptEnabled": false,"clientScript": null,"serverScript": "sharedStateUsername","authenticationLevel":0}' -s -k "${2}/json/realms/root/realms/pwc/realm-config/authentication/modules/scripted/ScriptSharedState" | awk -F, '{print $1}' | awk -F: '{print $2}' | tr -d '""'`

# Authentication Modules / Chains
${3}/SSOAdminTools/openam/bin/ssoadm do-batch -u ${AM_USER} -f /tmp/pwd.txt -c -Z ./ssoadm-config-data/root/${ENVIRONMENT}_authentication_chains.batch -b /tmp/root-authentication-chains.status
${3}/SSOAdminTools/openam/bin/ssoadm do-batch -u ${AM_USER} -f /tmp/pwd.txt -c -Z ./ssoadm-config-data/root-pwc/${ENVIRONMENT}_authentication_chains.batch -b /tmp/root-pwc-authentication-chains.status

# realm update(s)
${3}/SSOAdminTools/openam/bin/ssoadm set-realm-svc-attrs -u ${AM_USER} -f /tmp/pwd.txt -e / -s iPlanetAMAuthService -D ./ssoadm-config-data/root/amAuthAttributes.txt

${3}/SSOAdminTools/openam/bin/ssoadm set-realm-svc-attrs -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -s iPlanetAMAuthService -D ./ssoadm-config-data/root-pwc/amAuthAttributes.txt

# site(s)
${3}/SSOAdminTools/openam/bin/ssoadm create-site -u ${AM_USER} -f /tmp/pwd.txt -s ${SITE} -i ${2}
${3}/SSOAdminTools/openam/bin/ssoadm add-site-members -u ${AM_USER} -f /tmp/pwd.txt -s ${SITE} -e ${2}

# Cookie(s)
${3}/SSOAdminTools/openam/bin/ssoadm set-attr-defs -u ${AM_USER} -f /tmp/pwd.txt  -s iPlanetAMPlatformService -t Global -a iplanet-am-platform-cookie-domains=myforgerock.com

# Enable Debugging
${3}/SSOAdminTools/openam/bin/ssoadm update-server-cfg -u ${AM_USER} -f /tmp/pwd.txt -s default -a com.iplanet.services.debug.level=message
${3}/SSOAdminTools/openam/bin/ssoadm update-server-cfg -u ${AM_USER} -f /tmp/pwd.txt -s ${2} -a com.iplanet.services.debug.level=message

# Cookie(s)
${3}/SSOAdminTools/openam/bin/ssoadm update-server-cfg -u ${AM_USER} -f /tmp/pwd.txt -s default -a com.iplanet.am.cookie.name=pwcGlobalSSID_${SITE} com.sun.identity.cookie.httponly=true com.iplanet.am.cookie.secure=true
${3}/SSOAdminTools/openam/bin/ssoadm update-server-cfg -u ${AM_USER} -f /tmp/pwd.txt -s default -a openam.ssid.cookie=pwcGlobalSSID_${SITE}

# DNS
${3}/SSOAdminTools/openam/bin/ssoadm update-server-cfg -u ${AM_USER} -f /tmp/pwd.txt -s default -a com.sun.identity.server.fqdnMap[am.myforgerock.com]=am.myforgerock.com com.sun.identity.server.fqdnMap[login.myforgerock.com]=login.myforgerock.com com.sun.identity.server.fqdnMap[am.myforgerock.com]=am.myforgerock.com

# Policy
${3}/SSOAdminTools/openam/bin/ssoadm update-server-cfg -u ${AM_USER} -f /tmp/pwd.txt -s default -a openam.eval.policy="01|https://am-devlocal-myforgerock.com:8443"

# Error Page(s)
${3}/SSOAdminTools/openam/bin/ssoadm update-server-cfg -u ${AM_USER} -f /tmp/pwd.txt -s default -a openam.emaildomain.errorpage=https://login.myforgerock.com/login/invalidemailerror
${3}/SSOAdminTools/openam/bin/ssoadm update-server-cfg -u ${AM_USER} -f /tmp/pwd.txt -s default -a openam.unauthorized.errorpage=https://login.myforgerock.com/login/invalidaccesserror

# Validation service
${3}/SSOAdminTools/openam/bin/ssoadm add-svc-realm -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -s validationService -D ./ssoadm-config-data/root-pwc/${ENVIRONMENT}_validation_service.txt

# Certificate Revoke List
#${3}/SSOAdminTools/openam/bin/ssoadm update-server-cfg -u ${AM_USER} -f /tmp/pwd.txt -s default -D ./ssoadm-config-data/root/crlProperties.txt

# Update Userstore(s) with the user Attributes
${3}/SSOAdminTools/openam/bin/ssoadm update-datastore -u ${AM_USER} -f /tmp/pwd.txt -e / -m OpenDJ -D ./ssoadm-config-data/root/userstore_user_attributes.txt
${3}/SSOAdminTools/openam/bin/ssoadm update-datastore -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -m OpenDJ -D ./ssoadm-config-data/root-pwc/userstore_user_attributes.txt
${3}/SSOAdminTools/openam/bin/ssoadm update-datastore -u ${AM_USER} -f /tmp/pwd.txt -e /pwc/sandbox -m OpenDJ -D ./ssoadm-config-data/root-pwc-sandbox/userstore_user_attributes.txt

# remove status attributes for Userstore(s)
${3}/SSOAdminTools/openam/bin/ssoadm update-datastore -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -m OpenDJ -D ./ssoadm-config-data/root-pwc/userstore_status_attributes.txt
${3}/SSOAdminTools/openam/bin/ssoadm update-datastore -u ${AM_USER} -f /tmp/pwd.txt -e /pwc/sandbox -m OpenDJ -D ./ssoadm-config-data/root-pwc-sandbox/userstore_status_attributes.txt

# clean up
rm -rf /tmp/pwd.txt
