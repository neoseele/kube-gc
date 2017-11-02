FROM alpine:3.6

RUN apk add --no-cache bash gawk sed grep bc coreutils docker

COPY cleanup.sh /bin/

CMD ["bash", "-c", "while true; do sleep 10; done"]
