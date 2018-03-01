#!/bin/sh
set -x

if [ $dbPassword ]; then
    MYSQL_PASSWORD_VAL=$dbPassword
elif [ $dbPassword_file ]; then
    MYSQL_PASSWORD_VAL=`cat $dbPassword_file`
fi

keystorePassword=`cat $KEYSTORE_PASSWORD_FILE`

openssl pkcs12 -export -in $waterauthserver_TOKEN_CERT_path -inkey $waterauthserver_TOKEN_KEY_path -name $keystoreOAuthKey -out oauth.p12 -password pass:$keystorePassword
openssl pkcs12 -export -in $waterauthserver_SAML_CERT_path -inkey $waterauthserver_SAML_KEY_path -name $keystoreSAMLKey -out saml.p12 -password pass:$keystorePassword
openssl pkcs12 -export -in $waterauthserver_TOMCAT_CERT_path -inkey $waterauthserver_TOMCAT_KEY_path -name $keystoreSSLKey -out tomcat.p12 -password pass:$keystorePassword

keytool -v -importkeystore -deststorepass $keystorePassword -destkeystore $keystoreLocation -deststoretype JKS -srckeystore oauth.p12 -srcstorepass $keystorePassword -srcstoretype PKCS12 -noprompt
keytool -v -importkeystore -deststorepass $keystorePassword -destkeystore $keystoreLocation -deststoretype JKS -srckeystore saml.p12 -srcstorepass $keystorePassword -srcstoretype PKCS12 -noprompt
keytool -v -importkeystore -deststorepass $keystorePassword -destkeystore $keystoreLocation -deststoretype JKS -srckeystore tomcat.p12 -srcstorepass $keystorePassword -srcstoretype PKCS12 -noprompt

if [ -d "${CERT_IMPORT_DIRECTORY}" ]; then
  for c in $CERT_IMPORT_DIRECTORY/*.crt; do
    FILENAME="${CERT_IMPORT_DIRECTORY}/${c}"
    echo "Importing ${FILENAME}"
    keytool -importcert -file $CERT_IMPORT_DIRECTORY/$c -alias $c -keystore $keystoreLocation -storepass $keystorePassword -noprompt;
  done
fi

if [ -n "$samlIdpHost" ] ; then
  openssl s_client -host $samlIdpHost -port $samlIdpPort -prexit -showcerts </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > samlidp.crt;
  keytool  -importcert -file samlidp.crt -alias samlidp -keystore $keystoreLocation -storepass $keystorePassword -noprompt;
fi

java -Djava.security.egd=file:/dev/./urandom -DdbPassword=$MYSQL_PASSWORD_VAL -DkeystorePassword=$keystorePassword -jar app.jar

exec $?
