FROM openjdk:8-jdk-alpine

RUN apk update && apk add --no-cache curl openssl

ARG water_auth_version=0.3.8-SNAPSHOT

RUN curl -k -o app.jar -X GET "https://cida.usgs.gov/artifactory/mlr-maven-centralized/gov/usgs/wma/waterauthserver/$water_auth_version/waterauthserver-$water_auth_version.jar"

ADD entrypoint.sh entrypoint.sh

RUN chmod +x entrypoint.sh

ENV serverPort 8443

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "--spring.profiles.active=default" ]

HEALTHCHECK CMD curl -s -o /dev/null -w "%{http_code}" -k "https://127.0.0.1:${serverPort}/saml/metadata" | grep -q '200' || exit 1
