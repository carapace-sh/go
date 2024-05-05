FROM golang:1.22.1 as build
ADD . /go-src
RUN cd /go-src && make build

FROM golang:1.22.1 as build-termux
ADD . /go-src
RUN cd /go-src && make build-termux

FROM golang:1.22.1
COPY --from=build --link /usr/local/go/ /usr/local/go-lenient/
COPY --from=build-termux --link /usr/local/go/ /usr/local/go-lenient-termux/
RUN ln -s /usr/local/go-lenient/bin/go /usr/local/bin/go-lenient
RUN ln -s /usr/local/go-lenient-termux/bin/go /usr/local/bin/go-lenient-termux

