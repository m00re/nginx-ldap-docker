FROM alpine:3.4

MAINTAINER Jens Mittag <kontakt@jensmittag.de>

ENV NGINX_VERSION=1.13.4
ENV NGINX_LDAP_COMMIT=42d195d7a7575ebab1c369ad3fc5d78dc2c2669c

RUN set -x \
 && mkdir -p /tmp/src/nginx \
 && export BUILD_DEPS=" \
    autoconf \
    automake \
    curl \
    g++ \
    gcc \
	git \
    gzip \
    libtool \
    linux-headers \
    make \
    openldap-dev \
    openssl-dev \
    pcre-dev \
    tar \
    unzip \
    zlib-dev \
	m4 \
	perl \
	libssh2 \
	libpcrecpp \
	libpcre32 \
	libpcre16 \
	util-linux-dev \
	libsmartcols \
	libmount \
	libfdisk \
	libblkid \
	libuuid \
	cyrus-sasl-dev \
	libltdl \
	bash \
	readline \
	ncurses-libs \
	ncurses-terminfo \
	ncurses-terminfo-base \
	libsasl \
	db \
	gzip \
	expat \
	libc-dev \
	musl-dev \
	mpc1 \
	mpfr3 \
	pkgconfig \
	pkgconf \
	libatomic \
    " \
 && apk add --update ${BUILD_DEPS} \
        libldap \
        openssl \
        openssh \
        pcre \
        zlib

# Install Nginx from source, see http://nginx.org/en/linux_packages.html#mainline
RUN curl -fsSL https://github.com/nginx/nginx/archive/release-${NGINX_VERSION}.tar.gz | tar xz --strip=1 -C /tmp/src/nginx

# Fetch source code of LDAP module
RUN cd /tmp/src/ && \
    git clone https://github.com/kvspb/nginx-auth-ldap.git && \
    cd nginx-auth-ldap && \
    git checkout -b b80942160417e95adbadb16adc41aaa19a6a00d9

# Configure the Nginx build
RUN cd /tmp/src/nginx && \
    ./auto/configure \
        --prefix=/usr/share/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-file-aio \
        --with-http_v2_module \
        --with-ipv6 \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-http_slice_module \
        --add-module=/tmp/src/nginx-auth-ldap \
 && make \
 && make install \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

# Create users for the Nginx process 
RUN addgroup -g 1000 -S nginx && \
    adduser -u 1000 -S nginx

# Add supervisord
RUN apk add -u python py-pip && \
    pip install supervisor

# Clean up build-time packages
RUN apk del --purge ${BUILD_DEPS} \

# Clean up anything else
 && rm -fr \
    /etc/nginx/*.default \
    /tmp/* \
    /var/tmp/* \
    /var/cache/apk/*

COPY config/* /etc/nginx/

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
