#!/bin/bash

AMUSERID=${5}
AM_USER="uid=${AMUSERID},ou=People,dc=openam,dc=forgerock,dc=org"
COOKIENAME="iPlanetDirectoryPro"
ENVIRONMENT=${7}
ADMIN_GROUP_NAME="localPdeAdminGroup"
ADMIN_GROUP_ORG="ou=group,dc=openam,dc=forgerock,dc=org"
ADMIN_USER_LIST="\"uid=twillman002,l=Americas,ou=Internal,ou=People,dc=pwcglobal,dc=com\",\"uid=rgonzalez084,l=SoaCAT,ou=Internal,ou=People,dc=pwcglobal,dc=com\",\"uid=jwood067,l=Americas,ou=Internal,ou=People,dc=pwcglobal,dc=com\",\"uid=ceze008,l=emea,ou=Internal,ou=People,dc=pwcglobal,dc=com\",\"uid=jhoaglun001,l=Americas,ou=Internal,ou=People,dc=pwcglobal,dc=com\",\"uid=dmcferon003,l=americas,ou=Internal,ou=People,dc=pwcglobal,dc=com\""

# Create authentication token
token=`curl -X POST -H "X-OpenAM-Username: ${AMUSERID}" -H "X-OpenAM-Password: ${6}" -H "Content-Type: application/json" -H "Accept-API-Version: resource=2.1" -d '{}' -s -k "${2}/json/realms/root/authenticate?authIndexType=service&authIndexValue=adminconsoleservice" | awk -F: '{print $2}' | awk -F, '{print $1}' | tr -d '"'`

# Create the admin group
restdata='{"username":"'${ADMIN_GROUP_NAME}'"}'

group_add_result=`curl -X POST -H "${COOKIENAME}:${token}" -H "Content-Type: application/json" -H "Accept-API-Version: resource=1.0" -d ${restdata} -s -k "${2}/json/realms/root/groups?_action=create"`

# Add memebers to the group ...
restdata='{"uniquemember":['${ADMIN_USER_LIST}']}'

user_add_result=`curl -X PUT -H "${COOKIENAME}:${token}" -H "Content-Type: application/json" -H "Accept-API-Version: protocol=1.0,resource=1.0" -d ${restdata} -s -k "${2}/json/realms/root/groups/${ADMIN_GROUP_NAME}"`

# Update admin group with privileges
group_info=`curl -X GET -H "${COOKIENAME}:${token}" -H "Content-Type: application/json" -s -k "${2}/json/realms/root/groups/${ADMIN_GROUP_NAME}"`

restdata=$(echo "${group_info}" | sed "s/\"_rev\":\".*\",\"username\"/\"username\"/")
restdata=$(echo "${restdata}" | sed "s/\"RealmAdmin\":false/\"RealmAdmin\":true/")

group_update_result=`curl -X PUT -H "${COOKIENAME}:${token}" -H "Content-Type: application/json" -H "Accept-API-Version: protocol=2.0,resource=4.0" -d ${restdata} -s -k "${2}/json/realms/root/groups/${ADMIN_GROUP_NAME}"`
