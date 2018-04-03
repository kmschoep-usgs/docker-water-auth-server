#!/bin/sh
set -e

if [ $dbPassword ]; then
    MYSQL_PASSWORD_VAL=$dbPassword
elif [ $dbPassword_file ]; then
    MYSQL_PASSWORD_VAL=`cat $dbPassword_file`
fi

if [ -z "${KEYSTORE_PASSWORD_FILE}" ] || [ ! -f ${KEYSTORE_PASSWORD_FILE} ]; then
  KEYSTORE_PASSWORD="changeme"
else
  KEYSTORE_PASSWORD=`cat $KEYSTORE_PASSWORD_FILE`
fi

if [ -f "${keystoreLocation}" ]; then
  rm $keystoreLocation
fi

if [ -n "${TOMCAT_CERT_PATH}" ]; then
  openssl pkcs12 -export -in $TOMCAT_CERT_PATH -inkey $TOMCAT_KEY_PATH -name $keystoreSSLKey -out tomcat.p12 -password pass:$KEYSTORE_PASSWORD
  keytool -v -importkeystore -deststorepass $KEYSTORE_PASSWORD -destkeystore $keystoreLocation -deststoretype PKCS12 -srckeystore tomcat.p12 -srcstorepass $KEYSTORE_PASSWORD -srcstoretype PKCS12 -noprompt
fi

if [ -n "${TOKEN_CERT_PATH}" ]; then
  openssl pkcs12 -export -in $TOKEN_CERT_PATH -inkey $TOKEN_KEY_PATH -name $keystoreOAuthKey -out oauth.p12 -password pass:$KEYSTORE_PASSWORD
  keytool -v -importkeystore -deststorepass $KEYSTORE_PASSWORD -destkeystore $keystoreLocation -deststoretype PKCS12 -srckeystore oauth.p12 -srcstorepass $KEYSTORE_PASSWORD -srcstoretype PKCS12 -noprompt
fi

if [ -n "${SAML_CERT_PATH}" ]; then
  openssl pkcs12 -export -in $SAML_CERT_PATH -inkey $SAML_KEY_PATH -name $keystoreSAMLKey -out saml.p12 -password pass:$KEYSTORE_PASSWORD
  keytool -v -importkeystore -deststorepass $KEYSTORE_PASSWORD -destkeystore $keystoreLocation -deststoretype PKCS12 -srckeystore saml.p12 -srcstorepass $KEYSTORE_PASSWORD -srcstoretype PKCS12 -noprompt
fi

if [ -d "${CERT_IMPORT_DIRECTORY}" ]; then
  for c in $CERT_IMPORT_DIRECTORY/*.crt; do
    FILENAME="${CERT_IMPORT_DIRECTORY}/${c}"
    echo "Importing ${FILENAME}"
    keytool -importcert -file $CERT_IMPORT_DIRECTORY/$c -alias $c -keystore $keystoreLocation -storepass $KEYSTORE_PASSWORD -noprompt;
  done
fi

if [ -n "${samlIdpHost}" ] ; then
  openssl s_client -host $samlIdpHost -port $samlIdpPort -prexit -showcerts </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > samlidp.crt;
  keytool  -importcert -file samlidp.crt -alias samlidp -keystore $keystoreLocation -storepass $KEYSTORE_PASSWORD -noprompt;
fi

java -Djava.security.egd=file:/dev/./urandom -DdbPassword=$MYSQL_PASSWORD_VAL -DkeystorePassword=$KEYSTORE_PASSWORD -jar app.jar $@

exec env "$@"
