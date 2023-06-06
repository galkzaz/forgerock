#!/bin/bash

AMUSERID=${5}
AM_USER="uid=${AMUSERID},ou=People,dc=openam,dc=forgerock,dc=org"
COOKIENAME="iPlanetDirectoryPro"
#COOKIENAME="pwcGlobalSSID_local"
ENVIRONMENT=${7}

# Create authentication token
token=`curl -X POST -H "X-OpenAM-Username: ${AMUSERID}" -H "X-OpenAM-Password: ${6}" -H "Content-Type: application/json" -H "Accept-API-Version: resource=2.1" -d '{}' -s -k "${2}/json/realms/root/authenticate?authIndexType=service&authIndexValue=adminconsoleservice" | awk -F: '{print $2}' | awk -F, '{print $1}' | tr -d '"'`

# Delete Default policies
pwc_policies=`curl -H "${COOKIENAME}:${token}" -H "Accept-API-Version: resource=1.0" -s -k -v "${2}/json/pwc/policies/?_queryFilter=true"`

echo "${pwc_policies}" | grep -Po '"_id":.*?[^\\]",' | awk -F: '{print $2}' | tr -d '"' | tr -d ',' >> /tmp/policy_pwc_policies

while read policyname; do
  `curl -X DELETE -H "${COOKIENAME}:${token}" -H "Accept-API-Version: resource=2.1" -s -k -v "${2}/json/pwc/policies/${policyname}"`
done < /tmp/policy_pwc_policies

# Delete Default applications
pwc_policies_applications=`curl -H "${COOKIENAME}:${token}" -H "Accept-API-Version: resource=1.0" -s -k -v "${2}/json/pwc/applications/?_queryFilter=true"`

echo "${pwc_policies_applications}" | grep -Po '"_id":.*?[^\\]",' | awk -F: '{print $2}' | tr -d '"' | tr -d ',' >> /tmp/policy_pwc_applications

while read applicationname; do
  `curl -X DELETE -H "${COOKIENAME}:${token}" -H "Accept-API-Version: resource=2.1" -s -k -v "${2}/json/pwc/applications/${applicationname}"`
done < /tmp/policy_pwc_applications

# Delete Default Resource resourcetypes
pwc_policies_resource_types=`curl -H "${COOKIENAME}:${token}" -H "Accept-API-Version: resource=1.0" -s -k -v "${2}/json/pwc/resourcetypes/?_queryFilter=true"`

echo "${pwc_policies_resource_types}" | grep -Po '"_id":.*?[^\\]",' | awk -F: '{print $2}' | tr -d '"' | tr -d ',' >> /tmp/policy_pwc_resource_types

while read resourcetype; do
   `curl -X DELETE -H "${COOKIENAME}:${token}" -H "Accept-API-Version: resource=1.0" -s -k -v "${2}/json/pwc/resourcetypes/${resourcetype}"`
done < /tmp/policy_pwc_resource_types

# Policies
echo ${6} > /tmp/pwd.txt
chmod 400 /tmp/pwd.txt

#${3}/SSOAdminTools/openam/bin/ssoadm create-xacml -u ${AM_USER} -f /tmp/pwd.txt -e / --xmlfile ./policy-config-xml/${ENVIRONMENT}/root/realm-policies.xml

${3}/SSOAdminTools/openam/bin/ssoadm create-xacml -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -X ./policy-config-xml/${ENVIRONMENT}/root-pwc/realm-policies.xml

# clean up
rm -rf /tmp/pwd.txt
