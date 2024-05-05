FROM golang:1.22.1 as build
ADD . /go-src
RUN cd /go-src && make build

FROM golang:1.22.1 as build-termux
ADD . /go-src
RUN cd /go-src && make build-termux

FROM golang:1.22.1
COPY --from=build /usr/local/go/ /usr/local/go
COPY --from=build-termux /usr/local/go/ /usr/local/go-termux/
RUN ln -s /usr/local/go-termux/bin/go /usr/local/bin/go-termux
