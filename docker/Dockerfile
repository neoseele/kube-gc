FROM alpine:3.5

RUN apk add --no-cache docker

COPY cleanup.sh /bin/

CMD ["/bin/sh", "-c", "while true; do echo `hostname`; sleep 10; done"]
