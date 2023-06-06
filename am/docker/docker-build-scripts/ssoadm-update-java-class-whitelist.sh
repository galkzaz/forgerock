#!/bin/bash

AMUSERID=${5}
AM_USER="uid=${AMUSERID},ou=People,dc=openam,dc=forgerock,dc=org"
COOKIENAME="iPlanetDirectoryPro"
ENVIRONMENT=${7}

echo ${6} > /tmp/pwd.txt
chmod 400 /tmp/pwd.txt

# Create and update the white list for the OIDC_CLAIMS/engineConfiguration
#${3}/SSOAdminTools/openam/bin/ssoadm get-sub-cfg -u ${AM_USER} -f /tmp/pwd.txt -s ScriptingService -g OIDC_CLAIMS/engineConfiguration | grep whiteList > /tmp/oc_whitelist.txt

echo whiteList=com.pwc.pwcidentity.openam.oauth2.attributemapper.PwCIdentityOAuth2DynamicAttributeMapper >> /tmp/oc_whitelist.txt
echo whiteList=com.iplanet.am.sdk.AMHashMap >> /tmp/oc_whitelist.txt

${3}/SSOAdminTools/openam/bin/ssoadm set-sub-cfg -u ${AM_USER} -f /tmp/pwd.txt -s ScriptingService -g OIDC_CLAIMS/engineConfiguration -o add -D /tmp/oc_whitelist.txt

# Create and update the white list for the OAUTH_ACCESS_TOKEN_MODIFICATION/engineConfiguration
#${3}/SSOAdminTools/openam/bin/ssoadm get-sub-cfg -u ${AM_USER} -f /tmp/pwd.txt -s ScriptingService -g OAUTH2_ACCESS_TOKEN_MODIFICATION/engineConfiguration | grep whiteList > /tmp/oatm_whitelist.txt

echo whiteList=com.pwc.pwcidentity.openam.oauth2.attributemapper.PwCIdentityOAuth2DynamicAttributeMapper >> /tmp/oatm_whitelist.txt
echo whiteList=com.iplanet.am.sdk.AMHashMap >> /tmp/oatm_whitelist.txt

${3}/SSOAdminTools/openam/bin/ssoadm set-sub-cfg -u ${AM_USER} -f /tmp/pwd.txt -s ScriptingService -g OAUTH2_ACCESS_TOKEN_MODIFICATION/engineConfiguration -o add -D /tmp/oatm_whitelist.txt

# Create and update the white list for the POLICY_CONDITION/engineConfiguration
${3}/SSOAdminTools/openam/bin/ssoadm get-sub-cfg -u ${AM_USER} -f /tmp/pwd.txt -s ScriptingService -g POLICY_CONDITION/engineConfiguration | grep whiteList > /tmp/pc_whitelist.txt

echo whiteList=org.mozilla.javascript.ConsString >> /tmp/pc_whitelist.txt

${3}/SSOAdminTools/openam/bin/ssoadm set-sub-cfg -u ${AM_USER} -f /tmp/pwd.txt -s ScriptingService -g POLICY_CONDITION/engineConfiguration -o add -D /tmp/pc_whitelist.txt

# clean up
rm -rf /tmp/oc_whitelist.txt
rm -rf /tmp/oatm_whitelist.txt
rm -rf /tmp/pc_whitelist.txt
rm -rf /tmp/pwd.txt
