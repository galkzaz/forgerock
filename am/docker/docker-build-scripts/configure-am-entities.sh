#!/bin/bash

AMUSERID=${5}
AM_USER="uid=${AMUSERID},ou=People,dc=openam,dc=forgerock,dc=org"
COOKIENAME="iPlanetDirectoryPro"
ENVIRONMENT=${7}

echo ${6} > /tmp/pwd.txt
chmod 400 /tmp/pwd.txt

# Circle of Trust(s)
${3}/SSOAdminTools/openam/bin/ssoadm do-batch -u ${AM_USER} -f /tmp/pwd.txt -c -Z ./ssoadm-config-data/root-pwc/${ENVIRONMENT}_cots.batch -b /tmp/root-pwc-cots.status
${3}/SSOAdminTools/openam/bin/ssoadm do-batch -u ${AM_USER} -f /tmp/pwd.txt -c -Z ./ssoadm-config-data/root-pwc-sandbox/${ENVIRONMENT}_cots.batch -b /tmp/root-pwc-sandbox-cots.status

# Entities
for realm in ./entities/${ENVIRONMENT}/*
do
  if [ -d ${realm} ]; then
    realmid=$(echo ${realm} | awk -F/ '{print $NF}')
    editedrealmid=$(echo ${realmid} | sed -e "s/root-/-/g" | sed -e "s/-/\//g")
    for entitytype in ${realm}/*
    do
      if [ -d ${entitytype} ]; then
        if [ -f /tmp/${realmid}_openam_entities.batch ]; then
          rm /tmp/${realmid}_openam_entities.batch
        fi
        for entity in ${entitytype}/_M*
        do
          if [ -f ${entity} ]; then
            entitytypeid=$(echo ${entitytype} | awk -F/ '{print $NF}')
            entityx=$(echo ${entity} | sed -e "s/_M/_C/g")

            if [ -f ${entityx} ]; then
              #xmllint --xpath "/*[local-name()='EntityConfig' or local-name()='FederationConfig']/*[local-name()='IDPSSOConfig' or local-name()='SPSSOConfig' ]/*[local-name()='Attribute'][@name='cotlist']/*[local-name()='Value']" ${entityx}
              cot=`xmllint --xpath "/*[local-name()='EntityConfig' or local-name()='FederationConfig']/*[local-name()='IDPSSOConfig' or local-name()='SPSSOConfig' ]/*[local-name()='Attribute'][@name='cotlist']/*[local-name()='Value']" ${entityx} 2>/dev/null | sed -e "s/<Value>//g" | sed -e "s/<\/Value>//g" | tr -d "[:space:]"`
              if [ -z "${cot}" ]; then
                echo "WARNING: Unable to locate the cotlist attribute in ${entityx}; No Circle of Trust is defined."
                echo "import-entity -e ${editedrealmid} -c ${entitytypeid} -m ${entity} -x ${entityx}" >> /tmp/${realmid}_openam_entities.batch
              else
                echo "import-entity -e ${editedrealmid} -t ${cot} -c ${entitytypeid} -m ${entity} -x ${entityx}" >> /tmp/${realmid}_openam_entities.batch
              fi
            else
              echo "WARNING: Unable to locate the extended metadata for ${entity}; No Circle of Trust is defined."
              echo "import-entity -e ${editedrealmid} -c ${entitytypeid} -m ${entity}" >> /tmp/${realmid}_openam_entities.batch
            fi
          fi
        done

        if [ -f /tmp/${realmid}_openam_entities.batch ]; then
          ${3}/SSOAdminTools/openam/bin/ssoadm do-batch -u ${AM_USER} -f /tmp/pwd.txt -c -Z /tmp/${realmid}_openam_entities.batch -b /tmp/${realmid}_openam_entities.status
        fi
      fi
    done
  fi
done

# clean up
rm -rf /tmp/pwd.txt
