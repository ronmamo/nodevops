FROM alpine

RUN apk --no-cache add \
    curl bash zip git util-linux ca-certificates openssl python jq
