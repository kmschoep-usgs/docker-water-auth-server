FROM openjdk:8-jdk-alpine

RUN set -x & \
  apk update && \
  apk upgrade && \
  apk add --no-cache curl && \
  apk --no-cache add openssl

ARG mlr_version=0.3.6

RUN curl -k -o app.jar -X GET "https://cida.usgs.gov/artifactory/mlr-maven-centralized/gov/usgs/wma/waterauthserver/$mlr_version/waterauthserver-$mlr_version.jar"

ADD entrypoint.sh entrypoint.sh

RUN chmod +x entrypoint.sh

ENV serverPort 8443

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "--spring.profiles.active=default" ]

HEALTHCHECK CMD curl -s -o /dev/null -w "%{http_code}" -k "https://127.0.0.1:${serverPort}/saml/metadata" | grep -q '200' || exit 1
