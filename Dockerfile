FROM golang:alpine3.22

# https://mirrors.alpinelinux.org/
RUN sed -i 's@dl-cdn.alpinelinux.org@ftp.halifax.rwth-aachen.de@g' /etc/apk/repositories

RUN apk update
RUN apk upgrade

# required crowdsec 
RUN apk add --no-cache \
  gcc make linux-headers musl-dev \
  zlib-dev zlib-static python3-dev \
  curl zstd-static zstd-dev g++ cmake \
  git pcre2-static pcre2-dev sqlite-static sqlite-dev ninja

ENV XZ_OPT=-e9
COPY build-static-crowdsec.sh build-crowdsec-tmux.sh
RUN chmod +x ./build-static-crowdsec.sh
RUN bash ./build-static-crowdsec.sh
