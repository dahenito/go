# syntax=docker/dockerfile:1

ARG VERSION=1.22.5

###
FROM golang:${VERSION}-alpine AS builder
RUN apk add --no-cache bash file git git-daemon make rsync

#
ARG VERSION

WORKDIR /goroot
# https://go.dev/doc/install/source
# https://github.com/golang/go.git
RUN git clone https://go.googlesource.com/go /goroot
RUN git checkout -b ${VERSION} go${VERSION}

#
ARG HOSTOS
ARG HOSTARCH
ARG DOCKER_APP_PATH

ENV VERSION=${VERSION}
ENV GOROOT_FINAL=${DOCKER_APP_PATH}
ENV GOOS=${HOSTOS}
ENV GOARCH=${HOSTARCH}
# ENV GOHOSTOS=linux
# ENV GOHOSTARCH=arm64

WORKDIR /goroot/src
RUN ./make.bash

RUN  [ -d /goroot/bin/${GOOS}_${GOARCH} ] \
	&& cp -R /goroot/bin/${GOOS}_${GOARCH} /egress \
	|| cp -R /goroot/bin /egress

#
COPY install uninstall /egress/

CMD [ "/bin/bash" ]
