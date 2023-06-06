# PWC Identity - OpenAM
#

FROM tomcat:9.0.60-jdk11-openjdk

ARG AM_HOST=${AM_HOST}
ARG AM_USERID=${AM_USERID}
ARG AM_PASSWORD=${AM_PASSWORD}
ARG TOMCAT_VERSION=${OPENAM_TOMCAT_VERSION}
ARG OPENAM_VERSION=${OPENAM_VERSION}
ARG OPENAM_TOMCAT_AGENT_VERSION=${OPENAM_TOMCAT_AGENT_VERSION}
ARG SSOADM_VERSION=${SSOADM_VERSION}

ARG INSTALL_BASE=/opt/openam

ARG DOWNLOAD_DIRECTORY=Downloads

ARG TOMCAT_HOME=${INSTALL_BASE}/tomcat

ARG AM_URL="https://${AM_HOST}:8443/openam"

ARG ENV="local"

# Add OS tools we need, especially for DEV, maybe not add most of these to PROD
RUN apt-get update && \
    apt-get install -y apt-utils unzip curl bash vim tini net-tools openssl wget libxml2 libxml2-utils python3 python3-pip

# Install Azure CLI
#RUN pip3 install certifi && \
#    curl -sL -k https://aka.ms/InstallAzureCLIDeb | bash && \
#    python3 -m certifi > /tmp/certifi_path.txt

#ENV REQUESTS_CA_BUNDLE /usr/local/lib/python3.8/dist-packages/certifi/cacert.pem
#ENV SSL_CERT_FILE /usr/local/lib/python3.8/dist-packages/certifi/cacert.pem

# define user for openam
RUN useradd -m -d ${INSTALL_BASE} -s /bin/bash openam

# Move the default image location to the one this is expecting
RUN mv /usr/local/tomcat ${TOMCAT_HOME}
ENV LD_LIBRARY_PATH ${TOMCAT_HOME}/native-jni-lib
ENV CATALINA_HOME ${TOMCAT_HOME}
ENV PATH ${PATH}:${CATALINA_HOME}/bin
ENV TOMCAT_NATIVE_LIBDIR ${TOMCAT_HOME}/native-jni-lib

# Download needed files (should be wget'ed from a repo)
RUN mkdir -p downloads
COPY docker/resources/Amster-${OPENAM_VERSION}.zip ./downloads/
COPY docker/resources/AM-SSOAdminTools-${SSOADM_VERSION}.zip ./downloads/

# Apply customized tomcat configuration files
RUN mkdir -p ${TOMCAT_HOME}/webapps/ROOT
COPY docker/tomcat-config/conf ${TOMCAT_HOME}/conf
COPY docker/tomcat-config/ROOT ${TOMCAT_HOME}/webapps/ROOT

# tomcat garbage collection logs
RUN mkdir ${TOMCAT_HOME}/logcc

# Basic install of openAM, amster, and ssoadm

RUN mkdir -p ${INSTALL_BASE}/amster
RUN unzip ./downloads/Amster-${OPENAM_VERSION}.zip -d ${INSTALL_BASE}/amster && chmod 755 ${INSTALL_BASE}/amster/amster

RUN mkdir -p ${INSTALL_BASE}/SSOAdminTools && mkdir -p ${INSTALL_BASE}/SSOAdminTools/debug && mkdir -p ${INSTALL_BASE}/SSOAdminTools/logs && mkdir -p ${INSTALL_BASE}/SSOAdminTools/ssoadm-config-data
RUN unzip ./downloads/AM-SSOAdminTools-${SSOADM_VERSION}.zip -d ${INSTALL_BASE}/SSOAdminTools && chmod 755 ${INSTALL_BASE}/SSOAdminTools/setup

# Using the rebuilt war file.   It contains all the patches and company modifications.
COPY docker/resources/AM-${OPENAM_VERSION}.war ${TOMCAT_HOME}/webapps/openam.war

RUN mkdir -p build && mkdir -p docker-build-scripts && mkdir -p ssoadm-config-data && mkdir -p policy-config-xml && mkdir -p entities && mkdir -p agents
#COPY build ./build
COPY docker/docker-build-scripts ./docker-build-scripts
# COPY build/resources/ssoadm-config-data ./ssoadm-config-data
# COPY build/resources/policy-config-xml ./policy-config-xml
# COPY build/resources/entities ./entities
# COPY build/resources/agents ./agents
RUN chmod -R a+x ./docker-build-scripts/*.sh

# Configuring AM
RUN chown -R openam:openam ${INSTALL_BASE}
USER openam

RUN ./docker-build-scripts/tomcat-utilities.sh start ${TOMCAT_HOME} && \
    ./docker-build-scripts/openam-utilities.sh install_am ${AM_HOST} ${AM_URL} ${INSTALL_BASE} ${TOMCAT_HOME} ${AM_USERID} ${AM_PASSWORD} ${ENV} && \
    #./docker-build-scripts/openam-utilities.sh setup_ssoadm ${AM_HOST} ${AM_URL} ${INSTALL_BASE} ${TOMCAT_HOME} ${AM_USERID} ${AM_PASSWORD} ${ENV} && \
    #./docker-build-scripts/ssoadm-configure-am.sh ${AM_HOST} ${AM_URL} ${INSTALL_BASE} ${TOMCAT_HOME} ${AM_USERID} ${AM_PASSWORD} ${ENV} && \
#    ./docker-build-scripts/openam-utilities.sh configure_am ${AM_HOST} ${AM_URL} ${INSTALL_BASE} ${TOMCAT_HOME} ${AM_USERID} ${AM_PASSWORD} ${ENV} && \
    # ./docker-build-scripts/configure-am-keystore.sh ${AM_HOST} ${AM_URL} ${INSTALL_BASE} ${TOMCAT_HOME} ${AM_USERID} ${AM_PASSWORD} ${ENV} && \
    # ./docker-build-scripts/configure-am-policies.sh ${AM_HOST} ${AM_URL} ${INSTALL_BASE} ${TOMCAT_HOME} ${AM_USERID} ${AM_PASSWORD} ${ENV} && \
    # ./docker-build-scripts/configure-am-oauth2provider.sh ${AM_HOST} ${AM_URL} ${INSTALL_BASE} ${TOMCAT_HOME} ${AM_USERID} ${AM_PASSWORD} ${ENV} && \
    # ./docker-build-scripts/configure-am-agents.sh ${AM_HOST} ${AM_URL} ${INSTALL_BASE} ${TOMCAT_HOME} ${AM_USERID} ${AM_PASSWORD} ${ENV} && \
    # ./docker-build-scripts/configure-am-entities.sh ${AM_HOST} ${AM_URL} ${INSTALL_BASE} ${TOMCAT_HOME} ${AM_USERID} ${AM_PASSWORD} ${ENV} && \
    # ./docker-build-scripts/configure-am-sessionpropertywhitelist.sh ${AM_HOST} ${AM_URL} ${INSTALL_BASE} ${TOMCAT_HOME} ${AM_USERID} ${AM_PASSWORD} ${ENV} && \
    # ./docker-build-scripts/configure-am-privileges.sh ${AM_HOST} ${AM_URL} ${INSTALL_BASE} ${TOMCAT_HOME} ${AM_USERID} ${AM_PASSWORD} ${ENV} && \
    # ./docker-build-scripts/ssoadm-update-java-class-whitelist.sh ${AM_HOST} ${AM_URL} ${INSTALL_BASE} ${TOMCAT_HOME} ${AM_USERID} ${AM_PASSWORD} ${ENV} && \
    ./docker-build-scripts/tomcat-utilities.sh stop ${TOMCAT_HOME}

# Cleanup ...
USER root
#RUN rm -rf ./build ./downloads ./docker-build-scripts ./ssoadm-config-data ./policy-config-xml ./entities ./agents

USER openam

CMD ["/bin/sh"]
