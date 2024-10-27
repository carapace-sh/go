ARG GO_VERSION="1.23.1"

FROM golang:${GO_VERSION} AS build
COPY . /go-src
RUN cd /go-src && make build

FROM golang:${GO_VERSION} AS build-termux
COPY . /go-src
RUN cd /go-src && make build-termux

FROM golang:${GO_VERSION}
COPY --from=build /usr/local/go/ /usr/local/go
COPY --from=build-termux /usr/local/go/ /usr/local/go-termux/

RUN apt-get update && apt-get install -y sdkmanager
ARG NDK_VERSION="r27b"
ARG ANDROID_VERSION="35"
RUN sdkmanager --install "ndk;${NDK_VERSION}"
COPY go-android.sh /usr/local/bin/go-android
COPY go-termux.sh /usr/local/bin/go-termux
