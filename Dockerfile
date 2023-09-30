FROM alpine/curl:8.1.2 as digicert

WORKDIR /app
RUN curl https://dl.cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem -o DigiCertGlobalRootCA.crt.pem

FROM quay.io/keycloak/keycloak:latest as builder
COPY --from=digicert /app/DigiCertGlobalRootCA.crt.pem /opt/keycloak/.postgresql/root.crt

ENV KC_DB=postgres
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/
WORKDIR /opt/keycloak
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=change_me
ARG KC_DB_URL
ARG KC_DB_USERNAME
ARG KC_DB_PASSWORD
ARG KC_HOSTNAME
ENV KC_HTTP_ENABLED=true
ENV KC_PROXY=edge
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start"]
