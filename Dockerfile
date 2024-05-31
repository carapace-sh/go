FROM golang:1.22.1 as build
ADD . /go-src
RUN cd /go-src && make build

FROM golang:1.22.1 as build-termux
ADD . /go-src
RUN cd /go-src && make build-termux

FROM golang:1.22.1
COPY --from=build /usr/local/go/ /usr/local/go
COPY --from=build-termux /usr/local/go/ /usr/local/go-termux/

RUN apt-get update && apt-get install -y sdktools
ENV NDK_VERSION r26.d
RUN sdktools --install 'ndk;${NDK_VERSION}'
ADD go-termux.sh /usr/local/bin/go-termux
