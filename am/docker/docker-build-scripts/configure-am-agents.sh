#!/bin/bash

AMUSERID=${5}
AM_USER="uid=${AMUSERID},ou=People,dc=openam,dc=forgerock,dc=org"
COOKIENAME="iPlanetDirectoryPro"
ENVIRONMENT=${7}

# Agent(s)
echo ${6} > /tmp/pwd.txt
chmod 400 /tmp/pwd.txt

${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t J2EEAgent -b ig_agent -g https://login.myforgerock.com:443/agentapp -s ${2} -D ./agents/${ENVIRONMENT}/root-pwc/J2EEAgent/igAgent.txt

${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc/sandbox -t J2EEAgent -b ig_agent -g https://login.myforgerock.com:443/agentapp -s ${2} -D ./agents/${ENVIRONMENT}/root-pwc-sandbox/J2EEAgent/igAgent.txt

${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b dynamicclaims -D ./agents/${ENVIRONMENT}/root-pwc/OAuth2Client/dynamicclaims.txt
${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b nodejs-app -D ./agents/${ENVIRONMENT}/root-pwc/OAuth2Client/nodejs-app.txt
${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b oauth-spring-01 -D ./agents/${ENVIRONMENT}/root-pwc/OAuth2Client/oauth-spring-01.txt
${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b pwcbearertoken -D ./agents/${ENVIRONMENT}/root-pwc/OAuth2Client/pwcbearertoken.txt

#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b RMOnline
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b myvn-itinternal.azurewebsites.net
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:MW-AdminProd
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:api.vote.iwy.es
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:ec:pwc.delivery
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:fi-contract.cloudvault.m-files.com
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:hoteling:prod
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:estimatorpro:digital:hosting.pwc.com
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:eu.lab.pwc.com
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b voting.myforgerock.com
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:matttest:promotethu1
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:de-gad-aa2p.myforgerock.com
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:grafana-codequality.myforgerock.com
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:cogagent-us-api-pwc-com
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:adberap.in.nam.ad.myforgerock.com
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:womentoring.IN
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:mcaportaluat.IN
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc -t OAuth2Client -b urn:HFF-Stage

#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc/sandbox -t OAuth2Client -b urn:pcselfserviceext
#${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e /pwc/sandbox -t OAuth2Client -b urn:apps.pwc.es-portalapp-api

for realm in ./agents/${ENVIRONMENT}/*
do
  if [ -d ${realm} ]; then
    realmid=$(echo ${realm} | awk -F/ '{print $NF}')
    editedrealmid=$(echo ${realmid} | sed -e "s/root-/-/g" | sed -e "s/-/\//g")
    for agenttype in ${realm}/*
    do
      echo "### ${agenttype}"
      if [ -d ${agenttype} ]; then
        agenttypeid=$(echo ${agenttype} | awk -F/ '{print $NF}')

        #if [ "${agenttypeid}" == "J2EEAgent" ]; then
          #${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e ${editedrealmid} -t ${agenttypeid} -b ig_agent -g https://login.myforgerock.com:443/agentapp -s ${2} -D ./ssoadm-config-data/root-pwc-sandbox/igAgent.txt
        #elif [ "${agenttypeid}" == "OAuth2Client" ]; then
          #${3}/SSOAdminTools/openam/bin/ssoadm create-agent -u ${AM_USER} -f /tmp/pwd.txt -e ${editedrealmid} -t ${agenttypeid} -b urn:HFF-Stage
        #fi
      fi
    done
  fi
done

# clean up
rm -rf /tmp/pwd.txt
