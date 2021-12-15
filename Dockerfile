
ARG ALPINE_VERSION=3.14.3
ARG NGINX_VERSION=1.21.4
ARG NGINX_RTMP_VERSION=1.2.2
ARG NJS_VERSION=0.6.2
ARG FFMPEG_VERSION=4.3.3
ARG REPO_MIRRORS_URL=https://mirrors.huaweicloud.com/alpine
ARG OPENJDK

FROM alpine:$ALPINE_VERSION as build

ARG ALPINE_VERSION
ARG REPO_MIRRORS_URL
ARG NGINX_VERSION
ARG NGINX_RTMP_VERSION
ARG NJS_VERSION
ARG FFMPEG_VERSION
ARG OPENJDK

# ADD nginx-$NGINX_VERSION.tar.gz \
#     v$NGINX_RTMP_VERSION.tar.gz \
#     $NJS_VERSION.tar.gz \
#     ffmpeg-$FFMPEG_VERSION.tar.gz \
#     SourceHanSansCN-Normal.otf \
#     /tmp/

RUN set -e && cd /tmp && \
    wget --continue --output-document - http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar -xzf - && \
    wget --continue --output-document - https://github.com/arut/nginx-rtmp-module/archive/v$NGINX_RTMP_VERSION.tar.gz | tar -xzf - && \
    wget --continue --output-document - https://github.com/nginx/njs/archive/$NJS_VERSION.tar.gz | tar -xzf - && \
    wget --continue --output-document - http://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.gz | tar -xzf -; \
    wget --continue https://raw.githubusercontent.com/adobe-fonts/source-han-sans/release/SubsetOTF/CN/SourceHanSansCN-Normal.otf

RUN set -e; \
    printf "${REPO_MIRRORS_URL}/%s\n" \
    v${ALPINE_VERSION%.*}/main/ \
    v${ALPINE_VERSION%.*}/community/ \
    > /etc/apk/repositories && \
    apk update --no-cache; \
:                \
:   install apk  \
;                \
    apk add --no-cache --virtual .build-nginx \
    build-base \
    gd-dev \
    geoip-dev \
    libxslt-dev \
    linux-headers \
    openssl-dev \
    pcre-dev \
    zlib-dev; \
:                \
:   build nginx  \
;                \
    cd /tmp/nginx-$NGINX_VERSION && \
    ./configure \
    --add-module=/tmp/nginx-rtmp-module-$NGINX_RTMP_VERSION \
    --add-dynamic-module=/tmp/njs-$NJS_VERSION/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --lock-path=/var/run/nginx.lock \
    --modules-path=/usr/lib/nginx/modules \
    --pid-path=/var/run/nginx.pid \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --with-perl_modules_path=/usr/lib/perl5/vendor_perl \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module=dynamic \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_geoip_module=dynamic \
    --with-threads \
    --with-cc-opt='-Os -fomit-frame-pointer' \
    --with-ld-opt=-Wl,--as-needed && \
    make CFLAGS='-Wno-implicit-fallthrough'; \
    find /bin /etc /lib /run /sbin /usr /var ! -type d | sort > /tmp/before-0.log; \
    make install; \
:                     \
:   decompress conf   \
;                     \
    cd /etc/nginx/ && \
    printf "%s\n" \
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 \
Qw011FBDDTXUUEMNNfRf0T/iSoCTAHgAAA== \
| base64 -d | tar -xzvf -; \
    chmod -v 644 *.conf xjar && \
    mkdir -v /etc/nginx/http.conf.d /etc/nginx/rtmp.conf.d /etc/nginx/stream.conf.d; \
    mv -v /etc/nginx/http.conf /etc/nginx/http.conf.d/default.conf; \
    mv -v /etc/nginx/rtmp.conf /etc/nginx/rtmp.conf.d/default.conf; \
    mv -v /etc/nginx/stream.conf /etc/nginx/stream.conf.d/default.conf; \
    mv -v /etc/nginx/xjar /usr/bin/ && chmod -v +x /usr/bin/xjar; \
    mv -v /etc/nginx/html /run/www; \
    rm -fv /etc/nginx/*.default; \
    find /bin /etc /lib /run /sbin /usr /var ! -type d | sort > /tmp/after-0.log; \
    apk del .build-nginx; \
:                              \
:   manipulate archive files   \
;                              \
    mkdir -pv /tmp/rootfs/usr/share/fonts && mv -v /tmp/*.otf /tmp/rootfs/usr/share/fonts; \
    diff /tmp/before-0.log /tmp/after-0.log | \
    awk '/^\+\// && !/\.(a|c|h|log)$|examples/{sub(/\+/, "", $0); print $0}' | \
    cpio -d -p /tmp/rootfs;


# ffmpeg
RUN set -e; \
    printf "${REPO_MIRRORS_URL}/%s\n" \
    edge/community/ \
    >> /etc/apk/repositories && \
    apk update --no-cache; \
:               \
:   update apk  \
;               \
    apk add --update --no-cache \
    build-base \
    freetype-dev \
    lame-dev \
    libass-dev \
    libtheora-dev \
    libvorbis-dev \
    libvpx-dev \
    libwebp-dev \
    nasm \
    openssl-dev \
    opus-dev \
    rtmpdump-dev \
    x264-dev \
    x265-dev \
    fdk-aac-dev; \
:                 \
:   build ffmpeg  \
;                 \
    cd /tmp/ffmpeg-$FFMPEG_VERSION && \
    ./configure \
    --disable-debug \
    --disable-doc \
    --disable-ffplay \
    --disable-static \
    --enable-avresample \
    --enable-gpl \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-librtmp \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree \
    --enable-openssl \
    --enable-postproc \
    --enable-shared \
    --enable-small \
    --enable-version3 && \
    make; \
    find /bin /etc /lib /run /sbin /usr /var ! -type d | sort > /tmp/before-1.log; \
    make install; \
    find /bin /etc /lib /run /sbin /usr /var ! -type d | sort > /tmp/after-1.log; \
:                              \
:   manipulate archive files   \
;                              \
    mkdir -pv /tmp/rootfs; \
    diff /tmp/before-1.log /tmp/after-1.log | \
    awk '/^\+\// && !/\.(a|c|h|log)$|examples/{sub(/\+/, "", $0); print $0}' | \
    cpio -d -p /tmp/rootfs;



FROM alpine:$ALPINE_VERSION

LABEL maintainer="binave <nidnil@icloud.com>"

ARG ALPINE_VERSION
ARG REPO_MIRRORS_URL
ARG OPENJDK

RUN set -e; \
    printf "${REPO_MIRRORS_URL}/%s\n" \
    v${ALPINE_VERSION%.*}/main/ \
    v${ALPINE_VERSION%.*}/community/ \
    edge/community/ \
    > /etc/apk/repositories; \
    [ "$OPENJDK" ] && \
        wget --quiet --continue https://cdn.azul.com/public_keys/alpine-signing@azul.com-5d5dc44c.rsa.pub -P /etc/apk/keys/ && \
        printf "%s\n" https://repos.azul.com/zulu/alpine/ >> /etc/apk/repositories && \
        ln -sv ../lib/jvm/default-jvm/bin/javac /usr/sbin/; \
    apk update --no-cache && \
    apk add --no-cache $OPENJDK \
    fdk-aac \
    geoip \
    lame \
    libass \
    libedit \
    libgcrypt \
    libgd \
    libintl \
    libtheora \
    libvorbis \
    libvpx \
    libwebp \
    libxml2 \
    nghttp2-libs \
    opus \
    pcre \
    rtmpdump \
    tzdata \
    x264-libs \
    x265-libs; \
    fc-cache && fc-list; \
:            \
:    user    \
;            \
    addgroup -g 101 -S nginx && \
    adduser -S -D -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx; \
    mkdir -pv /var/log/nginx /var/log/srv /run/nginx /run/srv; \
:                 \
:   docker logs   \
;                 \
    ln -fsv /dev/stdout /var/log/nginx-http-access.log && \
    ln -fsv /dev/stdout /var/log/nginx-rtmp-access.log && \
    ln -fsv /dev/stdout /var/log/nginx-stream-access.log && \
    ln -fsv /dev/stderr /var/log/nginx-error.log;

COPY --from=build /tmp/rootfs /

EXPOSE 80 443 1935 8457

VOLUME [ "/etc/nginx/http.conf.d", "/etc/ssl", "/run/www", "/run/srv", "/var/log/srv" ]

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
