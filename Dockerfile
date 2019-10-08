############################
# STEP 1 build executable binary
############################
FROM golang:latest AS builder
# Install git.
# Git is required for fetching the dependencies.
WORKDIR $GOPATH/src/metajar/sox/
COPY . .
# Fetch dependencies.
# Using go get.
RUN go get -d -v
# Build the binary.
RUN go build -o /go/bin/sox
############################
# STEP 2 build a small image
############################
FROM scratch

ADD . /tmp/
WORKDIR /tmp
# Copy our static executable.
COPY --from=builder /go/bin/sox /tmp/sox
CMD ["/tmp/sox"]