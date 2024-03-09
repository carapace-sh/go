FROM golang:1.22 as build

ADD . /go-src
RUN cd /go-src && make build


FROM golang:1.22
COPY --from=build --link /usr/local/go/ /usr/local/go/

