FROM ruby:2.2-alpine

RUN apk add --no-cache --virtual .ruby-builddeps \
        autoconf \
        bison \
        bzip2 \
        bzip2-dev \
        ca-certificates \
        coreutils \
        g++ \
        gcc \
        git \
        gdbm-dev \
        glib-dev \
        libc-dev \
        libffi-dev \
        libxml2-dev \
        libxslt-dev \
        linux-headers \
        make \
        ncurses-dev \
        openssl \
        openssl-dev \
        patch \
        procps \
        readline-dev \
        ruby \
        tar \
        yaml-dev \
        zlib-dev \
    && gem install redmon \
    && apk del .ruby-builddeps

RUN apk add --no-cache libstdc++

EXPOSE 4567
ENTRYPOINT ["redmon"]
