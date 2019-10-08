
############################
# STEP 1 build executable binary
############################
# golang alpine 1.11.5
FROM golang@sha256:8dea7186cf96e6072c23bcbac842d140fe0186758bcc215acb1745f584984857 as builder

RUN apk update && apk add --no-cache git gcc linux-headers musl-dev

USER root
WORKDIR /root

# Fetch dependencies.

# Using go get.
RUN go get -u github.com/golang/dep/cmd/dep \
    && go get -d github.com/metajar/sox \
    # Since there are no go files in the root it comes back as error. || prevents this.
    || cd ${GOPATH}/src/github.com/metajar/sox \
    && dep ensure -v \
    && CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -a -installsuffix cgo -o /go/bin/sox ./cmd/sox 

############################
# STEP 2 build a small image
############################
FROM scratch

# Copy our static executable
RUN mkdir /app 
ADD . /app/
WORKDIR /app
COPY --from=builder /go/bin/sox /app/sox

CMD ["/app/sox"]
