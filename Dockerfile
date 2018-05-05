ARG BASE=alpine
FROM $BASE

ARG arch=arm
ENV ARCH=$arch

COPY qemu/qemu-$ARCH-static* /usr/bin/

# Initially was based on work of Christian Lück <christian@lueck.tv> and Andreas Löffler <andy@x86dev.com>.
# Added multiarch support
LABEL description="A complete, self-hosted Tiny Tiny RSS (TTRSS) environment." \
      maintainer="Angel Nunez Mencias <git@angelnu.com>"

RUN set -xe && \
    apk update && apk upgrade && \
    apk add --no-cache --virtual=run-deps \
    nginx git ca-certificates curl \
    php7 php7-fpm php7-curl php7-dom php7-gd php7-iconv php7-fileinfo php7-json \
    php7-mcrypt php7-pgsql php7-pcntl php7-pdo php7-pdo_pgsql \
    php7-mysqli php7-pdo_mysql \
    php7-mbstring php7-posix php7-session

# Add user www-data for php-fpm.
# 82 is the standard uid/gid for "www-data" in Alpine.
RUN adduser -u 82 -D -S -G www-data www-data

# Copy root file system.
COPY root /

# Add s6 overlay - todo: use different
ARG S6_RELEASE=v1.21.4.0
RUN curl -L -s https://github.com/just-containers/s6-overlay/releases/download/${S6_RELEASE}/s6-overlay-$arch.tar.gz | tar xvzf - -C /

# Add wait-for-it.sh
ADD https://raw.githubusercontent.com/Eficode/wait-for/master/wait-for /srv
RUN chmod 755 /srv/wait-for

# Expose Nginx ports.
EXPOSE 8080
EXPOSE 4443

# Expose default database credentials via ENV in order to ease overwriting.
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

# Clean up.
RUN set -xe && apk del --progress --purge && rm -rf /var/cache/apk/*

ENTRYPOINT ["/init"]
