
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
    apk update --no-cache; \
:                \
:   install apk  \
;                \
    apk add --no-cache --virtual .download curl && \
    cd /tmp && \
    curl --location --retry 3 http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar -xzf - && \
    curl --location --retry 3 https://github.com/arut/nginx-rtmp-module/archive/v$NGINX_RTMP_VERSION.tar.gz | tar -xzf - && \
    curl --location --retry 3 https://github.com/nginx/njs/archive/$NJS_VERSION.tar.gz | tar -xzf - && \
    curl --location --retry 3 http://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.gz | tar -xzf - && \
    apk del .download

RUN printf "${REPO_MIRRORS_URL}/%s\n" \
    v${ALPINE_VERSION%.*}/main \
    v${ALPINE_VERSION%.*}/community \
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
    make install; \
    rm -fv /etc/nginx/*.default; \
    mkdir -v /etc/nginx/conf.d /usr/share/nginx; \
    mv -v /etc/nginx/html /usr/share/nginx/ && \
    cd /etc/nginx/ && \
    printf "%s\n" \
H4sIAAAAAAAAA+0Ya2/bNjCf/SsIOYDbIrYkv2ujQ4uh3fJhTdF2wICuFRiJjjVLokZSsd02/e07 \
PiRLtuJ0j64dpgscU7wn7453JydXYbLp+TRZnHwxcAAmk4n6Btj/dofu4MQdTJzBuD8ejQYnjuuO \
xuMT5Hw5k3aQcYEZQieMUnGM7i78fxQyTuD0icyCeWtN2YowL2XUJ5wTjhDOBJ23WoQxyryIXiFk \
X2Nmw8pWPLbC9CRmjVkyb6VhgAwoSpYlmrIHGCnpmiSCow8tSWH0QfYlxBchTUCj6/SH89ZNq8VE \
nBo6sPEazNQPEqKQC5Ig9+FgNC82/WWWrDwevidoCGm1Q+A0jUIfSwXAeU1KgrQw2KLJvLLJiE9Z \
gOhisdu/aen/YNxSiNy4MPGjLCCGJg5j0hPblHDNF5AFziLhya2KJTb1BRFdLhjBMThGWUKvvAVl \
MRYgCIcJQp1TRmIqiIeDgKEuyh9V2N6cCtAGYfFx9BZZgPs9I1xYqFM5yg46p5DsIuPo9JIGW+9y \
Kwj3OAQEmOWJPEYWhBF2RIIhlPo9fAWsVs67kaZDEgQkkCurYw6FfZlMtcmjUSp71HkNB1gULMIo \
d2kRm7bwUy+hacaXxb5CrAhJsQyjJx1CM3DfeGRw7av3YVqizcMlS14vsB+o2qcS7mtfxa8CJj+/ \
aAe4o/5P3IF74g7VctSf9KH+953RqKn//wb4UQiX2IvxxlM1QZXPkQMVCbrABmpEtoCSYLbd/qq6 \
z9F0b5cXqEMeQeLUkxfbW7MQiliJoFUqfb9xqNOdD9ZjeZkhOnFqzSxd6kJOp2PHtc6sJYVCB9u6 \
NajyCLv6NHK/VDZhX2qyZvtV7+ywynUsRngKjYhIfcBiaqoqLGdWxiIpPGMhCM2L5WyveNaK1bVy \
dlg+z6xL7K+g4inBqe4Hhd2qXKtz6tWNrKptlNMhQT3TitpIl07VKV2nJ//6s6kzhUbYhqZVw8Vv \
ZxsOB4dsAV0nEcUBTsMDzv5EsbpS43S+h3zY77njac/VBt2OHlTQRVVH46ExpjIImCFAw9T0+8rm \
m9ns7SzHtKs4OCHiPELSEf1aCsVdQ2ZSLsExkS0bmq9MxrzdID0rpRBdNHw4QQPHVcx8Zts6+JK6 \
yCtIpYIzXKB7p6BMDmCC+jRCj5Bl3TfH1U5hRGQs2ZN6IFDT31QE5wQxEUsaoE8P0MWL1+cXz199 \
fP3yyfdPa9UMncGBMGmgT5gIF3KSIcgmwrdh046IgFvls20qbBk2e71e98gG7m9EoL/E9iKLIn8J \
fb6XknheL85bke2fEJmy8Bo4tEA9bgSBtyQ4gDT5pfuMQZC6F6meLV89+enpxcvzH86f5y4Haxhc \
dbSi4bTLjElHBhbp6V55apG1qhjezIhpl+ZL2TWQnXFmc1BFcjEijnZjZZgEZGO+ehK1W87NxJmn \
576K9mcpaZfU7LSUcYJtVWGGyRDyR/2zS/bIZ716LF8HdnxtJKcrTxan0N/NaTUWA2PFZt0RwPe7 \
YL0kOOqev0Dl2j0/zvIsnzjlCp1qCpkBe8PoUTE/QlDR7mreofK5dG73hUSA2zJiyCtOWZNLTqGo \
i2Oifk6vGCyM5kw/HSpXWKg3XHrR7blHzfu+eJNClpFoHRqo2VLMIdzcX5KYQBWBnmAebg/iJ/QO \
bhxZhJvuPQ5dHr7dj2bRv1+TlHCBAixw2Wb5RqlTsXi3qlP17hOwmn5jf9OZ87dT5+5QWoeUKnpS \
MYSu1JePOzSLo6oveXYp770AfZ1Hlt1B6kuSdea3kBmdpQnDmQJjp9KNjonwaOKTUvArN4cRNRpC \
gYP6s6DwHITwKi7qaNtFByyasJ1iqPio+x2qNVNhKzIOnVnh+EfUHo1d1cA6fZond0TOVxhx/LaC \
26sRr7dfkqVYLOURahuJwlbEwGSG+S3Edcf4K0pzis/qdQeeKA1iMMgMUQVs2DFtsJWnnvGwGTIV \
O5LsHAZmJJYEmT6nRNojR3fH0lnLGuElyoFPHz4D+ID6gmNenRce7TD7kwM61taLiAck2ZqfWaSl \
IMk8qJZ+Jse/JymG2t7hMMP7WSx/8ZHyDT+8+/sZvMutQwiG0gKENCHlKJayyv4VNJSTSumHhMhH \
ipv/7a8pDTTQQAMNNNBAAw000EADDTTQQAPfHvwB/sUb+AAoAAA= \
| base64 -d | tar -xzvf - && chmod 644 *.conf && \
    mv -v /etc/nginx/default.conf /etc/nginx/conf.d/; \
    find /bin /etc /lib /run /sbin /usr /var ! -type d | sort > /tmp/after-0.log; \
    apk del .build-nginx; \
:                              \
:   manipulate archive files   \
;                              \
    mkdir -pv /tmp/rootfs; \
    diff /tmp/before-0.log /tmp/after-0.log | \
    awk '/^\+\// && !/\.(a|c|h|log)$|examples/{sub(/\+/, "", $0); print $0}' | \
    cpio -d -p /tmp/rootfs;


# ffmpeg
RUN printf "${REPO_MIRRORS_URL}/%s\n" \
    edge/community \
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

RUN printf "${REPO_MIRRORS_URL}/%s\n" \
    v${ALPINE_VERSION%.*}/main \
    v${ALPINE_VERSION%.*}/community \
    edge/community \
    > /etc/apk/repositories && \
    apk update --no-cache; \
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
    x265-libs; \
:            \
:    user    \
;            \
    addgroup -g 101 -S nginx && \
    adduser -S -D -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx; \
    mkdir -pv /var/log/nginx /run/nginx; \
:                \
:    timezone    \
;                \
    apk add --no-cache --virtual .tz tzdata && \
    cp -fv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del .tz; \
    ln -fsv /dev/stdout /var/log/nginx/access.log && \
    ln -fsv /dev/stderr /var/log/nginx/error.log;

COPY --from=build /tmp/rootfs /

EXPOSE 80 443 1935

VOLUME [ "/etc/nginx/conf.d", "/etc/ssl" ]

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
