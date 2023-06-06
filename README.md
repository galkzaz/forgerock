# forgerock

cd am/docker/tomcat-config/conf/certs
 keytool -genkey -alias am.myforgerock.com -storetype PKCS12 -keyalg RSA -validity 730 \
  -keysize 2048 -keystore tomcat_keystore.pfx -dname 'CN=am.myforgerock.com' -ext 'san=dns:am.myforgerock.com'

docker-compose \
  --env-file=.env \
  run \
  -d \
  -e JPDA_OPTS=-agentlib:jdwp=transport=dt_socket,address=9000,server=y,suspend=n \
  -p 8080:8080 \
  -p 8443:8443 \
  -p 50389:50389 \
  -p 9000:9000 \
    --name am7 \
  am \
  /usr/bin/tini  -v -- /opt/openam/tomcat/bin/catalina.sh jpda run