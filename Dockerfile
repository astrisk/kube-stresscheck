# --- base images -------------
FROM golang:1.14-alpine  AS builder

WORKDIR /workdir/
COPY .  /workdir/
RUN apk add git g++ make curl
RUN go build -o kube-stresscheck main.go

FROM alpine:3.12 AS runner

COPY --from=builder  /workdir/kube-stresscheck  /usr/bin/kube-stresscheck

RUN \
    apk add --no-cache gzip tar g++ make curl && \
    curl https://src.fedoraproject.org/repo/pkgs/stress/stress-1.0.4.tar.gz/a607afa695a511765b40993a64c6e2f4/stress-1.0.4.tar.gz | tar xz && \
    cd stress-1.0.4 && \
    ./configure && make && make install && \
    apk del --purge gzip tar g++ make curl && rm -rf stress-*

ENTRYPOINT ["/usr/bin/kube-stresscheck"]