FROM cidasdpdasartip.cr.usgs.gov:8447/wma/wma-spring-boot-base:latest

LABEL maintaner="gs-w_eto@usgs.gov"

ENV artifact_version=0.3.7

ENV LOCAL_DEV_MODE=false
ENV STANDARD_SPRING_ARGS="--spring.profiles.active=default"
ENV LOCAL_DEV_SPRING_ARGS="--spring.profiles.active=localDev --spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.session.SessionAutoConfiguration,org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration"

ENV serverPort=8443
ENV requireSsl=true
ENV serverContextPath=/auth/
ENV waterAuthUrlServerPort=8443
ENV waterAuthUrlServerName=localhost
ENV waterAuthUrlContextPath=/auth/
ENV dbInitializerEnabled=true
ENV dbConnectionUrl=jdbc:mysql://auth.example.gov/db
ENV dbUsername=mysqluser
ENV samlIdpMetadataLocation=https://saml-idp.example.gov/metadata.xml
ENV samlAuthnRequestProviderName=https://auth.example.gov:443/saml/
ENV samlAuthnRequestEntityId=https://auth.example.gov:443/saml/
ENV samlBaseEndpoint=/saml
ENV samlLoginEndpoint=/login
ENV samlLogoutEndpoint=/logout
ENV samlSingleLogoutEndpoint=/singlelogout
ENV samlSSOEndpoint=/sso
ENV samlSSOHOKEndpoint=/ssohok
ENV samlMetadataEndpoint=/metadata
ENV samlIdpHost=https://saml-idp.example.gov
ENV samlIdpPort=443
ENV samlGroupAttributeName=http://schemas.xmlsoap.org/claims/Group
ENV samlEmailAttributeName=http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress
ENV samlUsernameAttributeName=http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname
ENV loginSuccessTargetUrl=/
ENV loginErrorTargetUrl=/auth-error
ENV logoutSuccessTargetUrl=/out
ENV springFrameworkLogLevel=info

ENV keystoreOAuthKey=tokenkey
ENV keystoreSAMLKey=samlkey
ENV TOKEN_CERT_PATH=/home/spring/oauth-wildcard-sign.crt
ENV TOKEN_KEY_PATH=/home/spring/oauth-wildcard-sign.key
ENV SAML_KEY_PATH=/home/spring/saml-wildcard-sign.key
ENV SAML_CERT_PATH=/home/spring/saml-wildcard-sign.crt

# Only used in Local Dev mode
ENV localOauthClientId=local-client
ENV localOauthClientSecret=changeMe
ENV localOauthClientGrantTypes="authorization_code, access_token, refresh_token, client_credentials, password"
ENV localOauthClientScopes=user_details
ENV localOauthResourceId=local-app
ENV localUserName=user
ENV localUserPassword=changeMe
ENV localUserRole="ACTUATOR, DBA_EXAMPLE"
ENV localUserEmail=localuser@example.gov
ENV localContextPath=/auth/

COPY --chown=1000:1000 launch-app.sh ${LAUNCH_APP_SCRIPT}
RUN chmod +x ${LAUNCH_APP_SCRIPT}

RUN ./pull-from-artifactory.sh mlr-maven-centralized gov.usgs.wma waterauthserver ${artifact_version} app.jar

HEALTHCHECK CMD curl -s -o /dev/null -w "%{http_code}" -k "https://127.0.0.1:${serverPort}${serverContextPath}oauth/token_key" | grep -q '200' || exit 1
