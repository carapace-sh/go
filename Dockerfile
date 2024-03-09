FROM golang:1.22.1 as build

ADD . /go-src
RUN cd /go-src && make build


FROM golang:1.22.1
COPY --from=build --link /usr/local/go/ /usr/local/go/

