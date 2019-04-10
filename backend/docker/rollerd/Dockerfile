FROM golang:alpine as builder

ENV GOPATH /go
ARG GIT_REMOTE_URL=https://github.com/eaware/coreroller
ARG GIT_BRANCH=master
WORKDIR /build
#    && git clone --single-branch --branch ${GIT_BRANCH} ${GIT_REMOTE_URL} \

RUN set -x \
    && apk --no-cache add git curl musl-dev \
    ca-certificates tzdata \
    && mkdir -p /build /coreroller/static \
    # Switch to https://pkgs.alpinelinux.org/package/edge/testing/x86_64/gb once this is in stable
    && git clone --branch v0.4.4 https://github.com/constabulary/gb /go/src/github.com/constabulary/gb \
    && go get github.com/constabulary/gb/... \
    && git clone ${GIT_REMOTE_URL} \
    && cd coreroller/backend \
    && /go/bin/gb build \
    && cp /build/coreroller/backend/bin/rollerd /coreroller

FROM node:9-alpine as assets
WORKDIR /build

ARG GIT_REMOTE_URL=https://github.com/eaware/coreroller
ARG GIT_BRANCH=master

RUN apk --no-cache add git \
    && git clone --single-branch --branch ${GIT_BRANCH} ${GIT_REMOTE_URL} \
    && cd /build/coreroller/frontend \
    && npm install \
    && npm run build

FROM alpine:3.8

RUN apk --no-cache add ca-certificates tzdata curl \
    && mkdir -p /coreroller/static \
    && /usr/bin/c_rehash /etc/ssl/certs

COPY KPN.pem  /etc/ssl/certs
COPY --from=builder /build/coreroller/backend/bin/rollerd /coreroller/
COPY --from=assets /build/coreroller/frontend/built/ /coreroller/static/

# workarround due to bug in update-ca-certificates
# WARNING: ca-certificates.crt does not contain exactly one certificate or CRL: skipping

RUN cat /etc/ssl/certs/KPN.pem >> /etc/ssl/certs/ca-certificates.crt

ENV COREROLLER_DB_URL "postgres://postgres@postgresqld.local:5432/coreroller?sslmode=disable"
EXPOSE 8000
CMD ["/coreroller/rollerd", "-http-static-dir=/coreroller/static"]
