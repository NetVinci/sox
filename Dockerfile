FROM golang:latest AS builder
WORKDIR $GOPATH/src/metajar/sox/
COPY . .
RUN go get -d -v
# Build the binary.
RUN go build -o /go/bin/sox

# This Can Be Any Image 
FROM golang:latest

ADD . /tmp/
WORKDIR /tmp
# Copy our static executable.
COPY --from=builder /go/bin/sox /tmp/sox
CMD ["/tmp/sox"]