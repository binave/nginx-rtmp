
ARG ALPINE_VERSION=3.12.3
ARG NGINX_VERSION=1.17.10
ARG NGINX_RTMP_VERSION=1.2.1
ARG NJS_VERSION=0.4.1
ARG FFMPEG_VERSION=4.2.3
ARG REPO_MIRRORS_URL=https://mirrors.huaweicloud.com/alpine

FROM alpine:$ALPINE_VERSION as build

ARG ALPINE_VERSION
ARG REPO_MIRRORS_URL
ARG NGINX_VERSION
ARG NGINX_RTMP_VERSION
ARG NJS_VERSION
ARG FFMPEG_VERSION

# ADD nginx-$NGINX_VERSION.tar.gz v$NGINX_RTMP_VERSION.tar.gz $NJS_VERSION.tar.gz ffmpeg-$FFMPEG_VERSION.tar.gz /tmp/

RUN printf "${REPO_MIRRORS_URL}/%s\n" \
    v${ALPINE_VERSION%.*}/main \
    v${ALPINE_VERSION%.*}/community \
    > /etc/apk/repositories && \
    apk update --no-cache || exit 1; \
:                \
:   install apk  \
;                \
    apk add --no-cache --virtual .download curl && \
    cd /tmp && \
    curl --location --retry 3 http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar -xzf - && \
    curl --location --retry 3 https://github.com/arut/nginx-rtmp-module/archive/v$NGINX_RTMP_VERSION.tar.gz | tar -xzf - && \
    curl --location --retry 3 https://github.com/nginx/njs/archive/$NJS_VERSION.tar.gz | tar -xzf - && \
    curl --location --retry 3 http://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.gz | tar -xzf - && \
    apk del .download || exit 1

RUN printf "${REPO_MIRRORS_URL}/%s\n" \
    v${ALPINE_VERSION%.*}/main \
    v${ALPINE_VERSION%.*}/community \
    > /etc/apk/repositories && \
    apk update --no-cache || exit 1; \
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
    zlib-dev || exit 1; \
:                \
:   build nginx  \
;                \
    find /bin /etc /lib /run /sbin /usr /var ! -type d | sort > /tmp/before-0.log; \
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
    make CFLAGS='-Wno-implicit-fallthrough' && \
    make install || exit 1; \
    rm -fv /etc/nginx/*.default; \
    mkdir -v /etc/nginx/conf.d /usr/share/nginx && \
    mv -v /etc/nginx/html /usr/share/nginx/ && \
:                     \
:   decompress conf   \
;                     \
    cd /etc/nginx/ && \
    printf "%s\n" \
H4sIAAAAAAAAA+1Y64/TRhC/z/krVs5JAXSJ7bxJRAWqoL0P5RBQqRIFa8/eJO7ZXnd3fUmA42/v \
7MOOnfhy9EFpheeUi73z9M7sb8ZJlmGy6fk0WZx8MXKAJpOJ+gba/3aH7uDEHUycwbg/Ho0GJ47r \
jsbjE+R8uZB2lHGBGUInjFJxTO4u/v+UMk7g6RNZBfPWmrIrwryUUZ9wTjhCOBN03moRxijzIrpE \
yL7GzIYrW+nYitOTnDVmybyVhgEypCRZlmjJHnCkpWuSCI4+tKSE8QfVlxBfhDQBj67TH85bN60W \
E3Fq5CDGawhT30iKQi5IgtyHg9G8WPRXWXLl8fA9QUMoqx0Dp2kU+lg6AM1rUjKkjcESTeaVRUZ8 \
ygJEF4vd+k1L/4fgVkLkwYWJH2UBMTJxGJOe2KaEa72ALHAWCU8uVSKxqS+I6HLBCI5hY1QkdOkt \
KIuxAEM4TBDqnDISU0E8HAQMdVF+q9L25lSAN0iLj6O3yALe7xnhwkKdyqPsqHMKxS4yjk4vabD1 \
LreCcI9DQkBZPpHHyIIwwo5YMILSv4eXoGrluhsZOhRBQAJ5ZXXMQ2FfFlNt8WiWqh71vEYDIgoW \
YZRvaZGbtvBTL6FpxlfFumJcEZJimUZPbgjNYPvGI8NrL9+HaUk2T5eEvF5gP1DYpwruax/Fr0Km \
Pr9oB7gD/yeDiXviwpGFFuBOhmPA/74zcRr8/zfIj0I4xF6MN57CBAWfI0ciUhu1kTzZM9sgOGVL \
myR2QH1uSwYsbzx19gEriRfTIItIbyXiqG3MrggOACguswXgirINVm/lIbc/vZqDRITZknh1chwN \
jVQLutRmW1EfuX1glNc5mu6t8oJ1qCNInHoSeLw1CwFkSwKtEjT/xqGPdD5YjyXYQPXEqTWzNBSH \
nE7HjmudWSsKQAzLunUp+IZV/UhyvQTrsC49WbN9VD47ROGOxQhPoVES6Q9UDOYr4DuzMhZJ4xkL \
wWgO5rM9cK81q7F8dgjvZ9Yl9q8AkZXhVPerIm7VTtRz6qubjiqcXA4J6plW2UYa2lUnd52e/OvP \
ps7UkRm/qdPit6sNh4NDtYCuk4jiAKfhgWZ/olRd6XE632M+7Pfc8bTn6oBuZw8q7KLroPHQBFMZ \
VMyQomlq5pHK4pvZ7O0s57SrPHhCxHmkTmC/VkJp14iZkktwTORIAcOBLMa8HSI9y6WQXTR8OEED \
x1XKHI65Tr6ULuoKSqnQDBfo3ik4kwOioD6N0CNkWffN4+pNYURkLNmzemBQy99UDOcCMRErGqBP \
D9DFi9fnF89ffXz98sn3T2vdDJ3BgTEZoE+YCBdy0iLIJsK3YdGOiIBT5bNtKmyZNnu9XvfIBs4v \
oJZPY3uRRZG/gjmkl5J4Xm/OuyLbP2EyZeE1aGiDehwKAgNp6JfuMwZJ6l6kevZ99eSnpxcvz384 \
f55vOUTD4KijKxpOu8yEdGSgkjvdK09VEquK4dKMwHZp/pVdDdkZZzYHVyQ3AxC+G3vDJCAb86XQ \
fXc5NxNxXp77Ltqf5aRdcrPzUuYJtlXADJMr1I/6Z5fikff66rF8XdnptZGc/jwJTqG/myNrIgbF \
Ssy6I8De75L1kuCoe/4ClbF7flzlWT4Ryyt0qiVkBewNy0fN/AhJRbujeYfL53Jzuy8kA7YtI0a8 \
silrcskpgLo4ZurndMngwnjO9N2hc8UFvOFyF92eezS874s3PWQZi9ZhgFotxRzSzf0ViQmgCPQE \
c3N7Ej+hd3DiyCLcdO9x6PLw7X40F/37NUUJByjAApdjlm+8uhSLd786V+8+garpN/Z/unL+dunc \
nUrrUFJlz0yPpb58fEOzOKruJc8u5bkX4K/zyLI7SH1Jsc78FjHjszRhOFNQ7FS60TETHk18Ukp+ \
5eQwokZDADjAnwWF+yBksA11su2iAxZN2E4xID7qfodqw1Tcio3Dzaxo/CNuj+auGmCdP62Tb0Su \
VwRx/LTCtlczXh+/FEuxWMlHqG0kilsxA5MZ5rcI1z3GX3GaS3xWrzvYidIgBoPMEFXIhhXTBlt5 \
6ZkdNkOmUkdSncPAjMSKINPnlEl75OjuWHrWskd4yXPg04fPAD7gvtCYV+eFRzvO/uSAjrX1IuMB \
SbbmZyAZKVgyN6qln8nx70mKAds7HGZ4P4vlL1LSvtH34URm8C63DiEZygsI0oSUs1iqKvtX8FAu \
KuUfCiIfKW6+2V97GmqooYYaaqihhhpqqKGGGmqooW+R/gA7czZlACgAAA== \
| base64 -d | tar -xzvf - || exit 1; \
    chmod 644 *.conf && \
    mv -v /etc/nginx/default.conf /etc/nginx/conf.d/; \
    find /bin /etc /lib /run /sbin /usr /var ! -type d | sort > /tmp/after-0.log; \
    apk del .build-nginx; \
:                              \
:   manipulate archive files   \
;                              \
    mkdir -pv /tmp/rootfs; \
    diff /tmp/before-0.log /tmp/after-0.log | \
    awk '/^\+\// && !/\.(a|c|h|log)$|examples/{sub(/\+/, "", $0); print $0}' | \
    cpio -d -p /tmp/rootfs || exit 1;


# ffmpeg
RUN printf "${REPO_MIRRORS_URL}/%s\n" \
    edge/community \
    >> /etc/apk/repositories && \
    apk update --no-cache || exit 1; \
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
    fdk-aac-dev || exit 1; \
:                 \
:   build ffmpeg  \
;                 \
    find /bin /etc /lib /run /sbin /usr /var ! -type d | sort > /tmp/before-1.log; \
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
    make && \
    make install || exit 1; \
    find /bin /etc /lib /run /sbin /usr /var ! -type d | sort > /tmp/after-1.log; \
:                              \
:   manipulate archive files   \
;                              \
    mkdir -pv /tmp/rootfs; \
    diff /tmp/before-1.log /tmp/after-1.log | \
    awk '/^\+\// && !/\.(a|c|h|log)$|examples/{sub(/\+/, "", $0); print $0}' | \
    cpio -d -p /tmp/rootfs || exit 1;



FROM alpine:$ALPINE_VERSION

LABEL maintainer="binave <nidnil@icloud.com>"

ARG ALPINE_VERSION
ARG REPO_MIRRORS_URL

RUN printf "${REPO_MIRRORS_URL}/%s\n" \
    v${ALPINE_VERSION%.*}/main \
    v${ALPINE_VERSION%.*}/community \
    edge/community \
    > /etc/apk/repositories && \
    apk update --no-cache && \
    apk add --no-cache \
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
    x265-libs || exit 1; \
:            \
:    user    \
;            \
    addgroup -g 101 -S nginx && \
    adduser -S -D -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx || exit 1; \
    mkdir -pv /var/log/nginx /run/nginx; \
:                \
:    timezone    \
;                \
    apk add --no-cache --virtual .tz tzdata && \
    cp -fv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime || exit 1; \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del .tz; \
:                 \
:   docker logs   \
;                 \
    ln -fsv /dev/stdout /var/log/nginx/access.log && \
    ln -fsv /dev/stderr /var/log/nginx/error.log;

COPY --from=build /tmp/rootfs /

EXPOSE 80 443 1935

VOLUME [ "/etc/nginx/conf.d", "/etc/ssl" ]

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
