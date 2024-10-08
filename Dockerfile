FROM golang:1.23.0 AS build
COPY . /go-src
RUN cd /go-src && make build

FROM golang:1.23.0 AS build-termux
COPY . /go-src
RUN cd /go-src && make build-termux

FROM golang:1.23.0
COPY --from=build /usr/local/go/ /usr/local/go
COPY --from=build-termux /usr/local/go/ /usr/local/go-termux/

RUN apt-get update && apt-get install -y sdkmanager
ENV NDK_VERSION=r26d
ENV ANDROID_VERSION=34
RUN sdkmanager --install "ndk;${NDK_VERSION}"
COPY go-termux.sh /usr/local/bin/go-termux
