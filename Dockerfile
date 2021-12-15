
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
H4sIAAAAAAAAA+w8f3vaRtL9259iD5NgUoOQwE4KD/eeLyWNW8f2Yzu93MUJEdJiVAtJr1ZgqEM/ \
+83Mrn4hgdPrm7bvPVGeGLE7OzszOzszO7vLJIqCpuV7468+39OC5+nTp/QJz9qn3tEP9a/g70H7 \
sH1gGACn6x2j8xVrfUaakmcmIjNk7KvQ96NtcA/V/z99LNfhXjScmovhyLeXQ+H8zNlBa9rb2dll \
u2wC6tHVNO/G8RZNP7zRuKfZviU0rIDixRBfhpYf8uHUt2cub06iqbur0E64afNwOJqNx/CBuAHr \
xjqmG89uewDhmuENH5bBCdZRUDtB6C+WueYHugEV2XLBnq2ViqSq2Cbi02A4dlw+vAudiGcBdlz/ \
Zjj2w6kZsZ+E77HafeVvkTPloD3ToNKtVPHL0BH+s8OWXtmvTHwRYbHg4RzoM207hFLJEpaHfOpD \
F6oce6p0qzQCo2XEgTiA26/tsLWnVgm5CHxPcOwPmoT8f2dAxBC/7ldmoYvIZ6EDSEMObPIQC2iQ \
4u+laM0bRRiBzgTSTEX7lZFp3XLPJsSBiEJuThO6IzOaCeJTvq1qpDgxHIt8UhB2D4X4SHEwvdXE \
f0b3WetZC0d8tbNb0kxsbtfptGW7bDPbv/Nc37TNwCm0NJ5SUx27fNZbq/zGaOqHz5q6pGhzdTtX \
fct5YLrOnLPDjiJGtbgnCbuOiLinRIx8FgrfdrvvunHNbr4OOGRCuDQFjVIIal0CpnTOM6cc+vMt \
00VthIGROHgY+uEwgOFlnW+esnZLp8YC5rkcfYROFAt0qQeNqljIvma1bjXww6jG+iwFjjE7Y7ZX \
BWKGMJ8i3/JdgKpU6kocUmghj2aht9breocKfpVDHANMeTTxbfbLE3Z2fnV8dnr58eri6PmgtJtO \
q11AhgRaPIycsWOZEWcajywNCjWXRzDtrHAZRBoOq3Z3d9fkC5jgYNYsf6qNZ65rTUzHawZ82itH \
N7zly1+BMgidObSQCAkjTC1l89ibxosQBrFxFkQOzHl2efRqcHZx/N3xaTyYQE0ItoDd+s6zRqhI \
Mi2LCzEEk8WYNjdDDd6kCSez3ZT1TapHY6aQoaZgP0xTksQHJd+wWSJ8NI+oWPUMjJQ32Uz2Xttr \
PqnvvX2vvatXWVVYEz7l8RhrVb1qaCzgYEc9MC69BMUqeUM/K6kOZx6KKwVyPJsv5F/yMumrhElG \
uMDJ7jbUu6XIs3VRuCTGBUPTSn+0DBn4Xb79LfKz7XbZzc9OMETb6FgMBR2rIn2uUwutc/RKrwTD \
m+rDBTfdxvE5y/qP3vYmL/zwzgxtbuMbq0oIVLIFOjRZhW95wguIXuL8T6f8A52eorY1zrECpDfj \
vRzH8u8dHwkfXEu0DdXr4CaEF9XzTH4rdk61YPQEylFv6lvJe+57HrdI5BWFsVIkUDYLTCEyagyO \
SX0pmJVkGH+BSRCAs3UWjT0BsQZ86h/Vi1EvUUmYpbYZmVmazVnkS430x+Ocmj4wH3cLMxKnYn4m \
JjYe9Xh9Nu5m5mMZd+9/YVrscLX/cnV9WH0qRUjSGBU3x4LarCwkzqn7gCSPwGIHUWPgWb7teDes \
VkOf7PkMXAiomkC1z7QXsxEqRgRBQLQMwGw96ZXX+p7F1zUsrWa1fkWrMfpAGmubwBS3maiu9Qwa \
1nIOPociN3ixpmoMrOrYh++2E4KEy2B3k6ghCWy0wAQvyRp/ZaV0UG2JsmTHKdfi/6TbrWqRJ3CT \
6YnFwDSP32lSTfCtRyILXBPGLl4NMKUoXVaLVavGYP7UwA4BzKTWVViA3ARRCZ9rPSt6E+Y36/Gf \
wBTkGJnCup6NODh0Fk04Ox+8YnL5VuwS4jeY8xBX2+VhIRYKTa2CcsFb0syklk0rLDM0gB88kzNe \
ZiKAsuqhDXN8woxN+vD5LRYOcQmf262XmHt//NhLkwSBcBW8LNTY4BsdTxIpvUCmZN2fFgBwbfGe \
BILBbLXoWzf0hE2qepkfLeXy2yyRBWxbBfTncG/gA1TM9WnqgpERtMnbinLjimCBCdMBDVYmZKfC \
XGtYgZsiD1NmEH5FF3HFtqVDwRRmVtWw6uyw3KNBiVpVqGaJiVUZA2rOsLlgsAxAm6WWDYRSO2jJ \
xUaGs2yP7KDVgv8G/G/Df+g+adHLL+76aU1mCRfHoYXFUTKINveWTK4ckUBAoL7QwmgfJ9JRYEKQ \
WRPM9q3ZFCJKQqvaWxBrzELB7hyQOC1GAdD3eHaoMoqiXUMPWT2h/mGw44VZTNhf2Jvvjy6GF2dn \
V5d9+X58+vzk9beD+Nt3p2cXg35vZyVTmi+vrs6ZZXroHWaC2+gXFGMYWl1cvTon0QuATtI5uyrl \
k82/qNzVTqxhVxNHsNcXJzhR5g7M5BQXtHIsgc7ozauTGFXiOhEiyVfRaERTuWqU/O5mqnbZa/D2 \
EXYloiVIfsLBFsGAzB1+h9gZTAZYWZHa5NpB56PQvwOWynoaZrDh9+ZCuHGea5Wyn6MZYXJ07xIB \
JXSlQm3mwJ/7wTLpjt1NeMhR3kt/xu5ML8rBmp7NgllEUwMTMUxOID9cMprF2DjLGc1YrIFFW0Ku \
to2niSvW2LnE8WcvTy7ZODRvUKVFpl7G1tkW+JhB4DoSpTYHR4rfeXMa8JtZ6LJpe5bkD+MHlcXX \
poEBzIls5arADwxXFiCTK3qOc68BxjsKfReWBg0LC7axa5tiUsrvt0eXL0sZ/s00wP8/esPjy5N7 \
5M7O590A3L7/1zJ0o0X7f4cdvXPYPsT9v4ND48v+3+/x4E4Pk/64t3Pnh7c8xOw9ekOwbZSHgphF \
hholCeUG1VAqGWJyiFkDx44NQxJMSB2DGsQ0R5uiHLvqz0oiTuhRbxkd8tVq3wjhHM9yZzZXeKfO \
lDfJ9spQwOZjc+ZGlOrIm1/finjUyKZg1NZI5MMaR8jMhwqPku09NjXBVbIaxQnZFQtrJF9Jam/l \
nh8FlO9YJU7JVVhxf00+NbVLxtY3+tjaDt1mDMX9ubjt2rqoUou3EzZuBjSwXSO7GYCcq2ZAlo2R \
Xdxzsh6JrGDo+cEMfEdcThXJZhhtRfrgqNnhQRzuYho8AxuPJ5qdpi03JZ6QEerl6ifx4QQAiutB \
MzBoibfYiuNGscbauOWG6hMkgz1skswa8QhaSjxVFIlXW5Ubyb+8uhgcvdrKAFvfiGVKsT6BM9ns \
E3mTwKXcqaoCf3+0Pfvy/Lon0dLP2McD53/0wwP0/xAHtA6Mp50Wnf/Rv/j/3+X5xIMtZHg2HmCh \
Ux9lRx/0b9oH0m5Yk5l3K0/UdGDQY0OVOmtGBynSjAR9jb0OLT645Yd2uluRZCZg5f0jm/o272I+ \
AdaII+gdVoP7YNm8JW5UCCt0RjwUqkG21+kymsdphly+iHvmCNwfkSGNnePdZCBy9K3vZxClYycU \
EdN/AJIVhmxCScKk+YxM6ZDWs7jO0sx5STUe1pLnpX4o6x7YA+fNrFkYYmyRDCauxjksyNjYnReR \
zjwHwpcNHCmZQq27hJWhP02PlWQ3LV3Xv0tgkxM3WQ4oixNDpMxnO1NYXHOZlU52tEPTE2ojbG88 \
xpU18ziHwKdeMsAj5yaXbtwybmcew/QDEiikDtlq4BiEsTLpYvnTKWYiVMf1HALKbaG+RU40o3i2 \
y6pAjFa9h7+rfVbFrVr4hh8rmXjKkPo47g2rm1nMuV4oz6T4hkFwcQQ5cCXi5jRARG0O+5qO2jML \
c40T2kTyXaKXTlChnrSNRdtoQlex8jNHwsazywaoHMKamAIttVyXe4JzNuIwnnU28zBDQHlNPJe0 \
ncWEO6SIwSwGbmC0Sb5RSpPr3HKVPTFntpMnKErVZB9ZdH6mNxO3LBEZOL0IIh8eagDEMc8amlPB \
eGRtJOsVLDOcAKwCX0ADFxqLOJMoAm45Y4fbzYJiEbDiqBFy1nAoNszmortoKDWpKnRsqzGXRMFU \
ZRCs0buFybKGkGOztiERP40xNSnHTyMUa19hYmUHjiC3TBsljx9R9HJUpD7ZWV2CqQLywbSc1Egp \
gm3d3vGRlcTGD07Xy4y2E6eq/Zro4+M38QiMpcZ0YPhmCwNHQ7P5XKPCFmtY3Tl0OloYhx2QvLdB \
zp8kb0mONl1uOASQ90O0pPpE1gdkptQsSKckpUCzcGgCYAU/RQHAiJJlK5m7MKUwqXzng8e0JqjW \
2W0fpAsZ1Ms2eXIQRhYCZdB5kOetapYj8hxhUS0l20IOvAxDYrrzfhATxuhGaFjcZY5iNJty0PCj \
nSWcUuevQ7e/flaveDhsA1tS434Nc5dqrwebUGrfDCMYJwjKaNkmC7Yw0PmVDJD97ceaqbaaSnwt \
zQqGjoGj2yvhdu7b+e1flDgtOmFiiK2CgqbGhrbAUbEtGGAzDR8gntsY4cmzMRNu3QKM56sYJw3g \
clQgi9bEjErCwC0jhq5x7GOsgs7E89W5AUpiKYeM2ro+z5iQp3UYcOlghCnkhg3qtsgBgz+CMZm5 \
sDohL2+GN7SpRttIlJw6P7u8WnPqlIEqofaVCZ6SGikYCDZmIimK0MPkSfVhyC0QDe7KAN0hluQC \
vHw4vJuJOtJ8Hh5B8fys4vreMA7/1CZyajRxQ01TtaWTBD0jeRtUlHz/iBe1ZwNSqCq3KdQZ1TMM \
mvdCHnAzEqTyjlCc1PMd2bjMKO8Iq8o6OsIBHPmgEziEIBmY3KU6k2sF09KzTVgmKDr26hkt2KQ2 \
wIqWxutcNNnxGEOobNMQ9dCLcg1JsN8Nrhq0f8fEEsKjBY46CedxPOwljgPRma7w4+SQnQvs2EBa \
INwa7eYqWMFvgq/EGCi2S/9j9kePrb69eY2lt5SJuuXLMZ6VFmwP5jtFg3UVzRsMlm6zKOfUVPOk \
1dZF2NwqqcZFmOpRb5XUOx7EmXMISoxpqUKAfC2pAkvUjFkEYyRjCWrP7bzOKaxbVC8Dke8Q7Gdi \
Fl+eXObqdhker8ENThhoTMfDaHMTxtQC+YNfNTO7rHiUahqMQcIkFdwtxYCjnqDC9QztzsZbh3IB \
kWLAkFtaMCEz8TaMnimNEK4VEkzI4f0KYKQVcTzKSDrJcisl/9gDx4YWWHmyzLmvlxDCaUdHz5vE \
o3M+wdlAVm8EHGL0TiAJqiD0KeNNqxYVLSrvWW8mULT6UsVKSslGfxqPTv25gwsr016SWEDC3QLt \
cUTq+jcuqKrLQF1HPtCnVgmEpGnOHZasB1RkmqBgWBUTnrAVrxgAGmIblxYU4EY6Hb3Vwkqm5xBs \
i2FhlDWioyj5Me3T48qbTqyo5VYuZULSrmEUXmNjENUsTBZ9MaKsK5Yb8Knelyw6EKRQkpmr8K0s \
bjgffNegbW3UPGfqoFcFotenQ5YYtT2+lRqCKRZl6MGv6wRtuZ9B6dji/YzPl1fP5PE/VxcP7f+2 \
D1oG5n/b7dZTvfOU7n8+bbe/5H9/j+czX2yML4JhTfK+4V4jxT82XoOkjdG4YL8i6PZh9YGLkf/B \
NcWpGTB1X42jrR5mb87JREx8PqbkWKzsOL1YqK4kkhGQW9LrRLLcNcT03mN6zEwZmvSQGSBNzgtl \
DmBK6pJ7iikLZI2SM2lbLI2a+EVbIwOGMumYbuAlV/uEOpSbUP3L9WhiXI82MNvSexk4vDysN3UF \
nYMzMnCLaRA0pGohaA6u/Unie0Z7DSXioy+/s/ySW5GJgiY0Vyqx0ISY5LIoRiKQytXJ5Vxvtios \
csVaoV5WaJQVtnOFqaKWa2Z6I9ctXMYtqv624VB3HvTk6i4JOK7NFmYvXqUXaD7fSKXXh/lolm4W \
TEx5xCG3Ew8PuEpBRCenrovyeNY5OMSNdVgimI4r+m0iEt/j0xH9dktkj6SstX76qa2T3mees+hS \
yBGbKnm5Th46IJjc1hzDXiQOKXC1xkyPbzBdZOvT8nauXE4okl1MUqYiJUsNQ0zVg6HQxmGjc7wx \
R/kpDwshvQF/DvO6VM5aFiLPXNFeJDd2Yr+Hl6B7/wUHGhc/meHn7mN7/AfR38EBnf8z2oZ+8BT3 \
/1udQ/1L/Pd7PLt/0UaOp+EPY4z8BQObR9qPB7ND52YSMaNl6AxA2E+Op8ztiWNxD0/Op3t68uh/ \
XLPPflRXcY1mi+0hQEVVVepyeuHScWouMQNCi0RKHNIqli/wrqNc84MXdEy8o5js/Ck08hj5PxUS \
f4Q7ecyUW2T+OAvJzChzgF6lTjAxbhLJ9KMmrgQV2snx88Hp5aABZKtGrz0XLzlg1tQJgeXRMl4k \
0ukA8w5TnOZNqFbBQAXeZaSdRuGPoztTHUq3wUKFzmgW5cQW0wi8ZwFAcKbHKkeX7Piywv5+dHl8 \
uU9Y/nF89fLs9RX7x9HFxdHp1fHgkp1dsOdnp98e0y8hsLMX7Oj0n+yH49Nv9xl3KHHLF3RFFAl1 \
UKCYn0Nkl5zniIjTN2or0wLuvJsZXi+58cHkeZhlwcvCDiWwBe6vEB4X1tORymIWWGvu7AyHi5+G \
wzjfPcSwaC++UvWWVaoQu7xjHz/GP9mgzguoVgA95Hjtle9lf3IA293rmva21fjmqPEvs/Hz8J22 \
qrA+/uAEoHv8mN2DAXe8aMweCeqkF3fQ6mV+bkBuHDr2ot/QMUMq+j12N0E9fMuqe3tQ8XXfqNdZ \
A0qq97v6ir3r0Z40glaq+MFqQEq3CqANvQsAyVf4UkFgj/diWhaPFoAGWz2qwJpl1SNvSVUVWa5p \
C+36erGqJCQmEPYjGxrf8mWx7Qf1UruGZ1GjXgBQ02yNrT5IXKv0Zx5czHyywIdYdG668YUwKdRu \
q2soSTYaamjuCbb/oTAoJNkPPSYmzjgCuUpEgLwc1qh8kB2C6NrqcpmF6caqDlMn4bjRCGZRnegh \
aDWiHNOpPx5dHB/9/WQwfHV0Xr1HslbD84vBi+M3wyr2e125lo2uK71eBqPjWeFouQFppcuuYbQf \
wM2+7jPZtl7PI5dHbn4DxQ/AlLN0w5WQACLbYar3n4I6jxOD3TlfRzvDHxx6iJEcHjyfVE8oAb3d \
QwwfGVjKgDUsVnufxVZbQ1fP4bJcboZ1RcQHice8u2WNF6zWr7GaVoqrFiPT7uNZAv+q+qr2IYcd \
KBcJpWvYYxQfN3YD09UwtUrzSSXtsKbmXlqj3TvjvaqB99re7y3QaJmN8bt7Y1X/uqqBXVO934DF \
nI32wALss8q1fBYVeL+BP1WjToVeZcW4C3MmbgV4Vfk6a8Y23rLMfPyTMVrgcJVY0MoTsKnYSfu3 \
ddIudNLOdCLlmRPnk0SQlUfiutVuv23rU/XWwhcP9OstCKw7uLg4u3gHBg0mowPenH69p4vqh77u \
r4+NXurrJH4uTGsHFzZkNEnR0WHupTePaQ4w7s2d0PfobmWygUwQcnLEs0yNcR/Hcu/N9x8XP9WH \
WVf5db8wKerYPYQKsK5hb74fXj0/fz28PBkMzoeXg+f96n2hrNuowWK1BiY/bXV8ejW4OD06Udcx \
qVW+DFrR9VnaHvNMt7bCdqffHZ++GUIc80K2Sb8jPF7El2vC9LZSvt+Xg4urf/U/3OBGtjdmz09+ \
AGJ/+IBVrwavhldnV0cn/Q8olZr2ik+v/Mh0Uwk8ahpjqXhMo/sn6mNV+3d7R9qdxpH8rl/RHiAc \
YhhGzrWDUOys5cRvfeTJTjZZwAgBkrDF8Riw5QD/fauqu6eP6Rkk777se/s8HyTo6a4+qrrubliA \
Z2GC6XiKF1OctwSC3iUnZBIMcamKp1/OTn95/kdinK+WeE3Dag5M74L5gHHmL1iRzsJgDdS5sBHo \
jbwrxFKvFmCaIaoOCfWRx+NYaykFNnXHxfW7wYeBENgYaZvMpGDHBxrC2sJfUJreYifBThjhRIAk \
BYsVw696E4PaI8aFHQeXI0Fb3ZT/1f/Ae8DJON+CJrr6s12UyHJXim/G40U/Hg+poklv7haTZX85 \
vhrfgkKRJrYgiILytryzD9Q8PgP6eoJrFlpQN6k+JJE4tFiYawSkwdUVFLdESC1gBPUUGIECIrIa \
+9okNA0R8qEzuWQPAWI5CrAIqHTheOUREXm8CuqFl5Nbhs4sTMMDZjGPv0t3AbuFooXHEsp6QZcK \
thj/gFe8ha2cZslAQP8b4MGf+WqMV77BFA+BneKfr/HPN/jnW/zzHf75Pg/mIgUUDBEcCEEKCVRI \
sMLv6jwtqi8Hi67SFOjhzTweVxKo1ZYoWaSLzGWoOoDtIYbFcLE2qaFU2kMOyRxrDIOzAd8n8L8i \
kODrkxSvXUOLP8Wr8bTi0RYCnp5sJVdlJw6H6+V/HYUEMxuDn4mveyNmdX/EVOTQ/QRH1QRJFbVW \
vkb79sh2Lq5z0mZHe7kOKjhhiBoO95dGQTVdiSrOwLLC6zs6UL93eOhYG6HnEEjAK0qK+IbkFfm0 \
QY559m1+all5xKKPdnA+bDUQTwy5g4pFk3k9r5cNP38/gXjvo283MbEQffXSKCjF2egjwIhCqQA2 \
ahGqgE1U/kLSL+vGzLgg+IF5QCYeA0VtPVp4eZNlEjndxrvBshigiYQlD7AouJlcdIMgc8qD1XVM \
6ySH1wWB3A16oLvCIMUQw7CagcwcAjt9+STdJ2oYFcpHAB0j6TxrdDi3O40QK1UBr2lFQ39AX+W5 \
EG1+R4MXQAkAkNoflDfdLckHU6koriJBVdkJa1YzEY8TCN52OlG8AMUr6vVqUiVoV/Dqm+2bs19P \
t2EV8aMPI2yxC9Cx3resNZUPZ0LJINyDxs4TmKCFTQer4TWtZz1RVKrVfVSfQFAMi1M7p2r52j2E \
PNgwjghAuHaU7ICGauiY8tlZrK2sK4bIm0EP0otm41UA+8kugq2VwKlyvxQ6yJTxg/f39vFiadTk \
nX5CNHF8HwoMQ8GTlNQhP5NVNUxec0V9Of/Yx0gsv3ILfTvkYCG3nsacJZdoJ8kLSUS0rYK4WtZA \
3C7q30RgCkrFh+T6DSiRF3Go7rSbbIrqs3mpTVH/ZtxwU9S+CM7BPZlkO+TN2LA0uD+OqkXk9dIc \
c/iEkZx4FRTNizGYZJGKE2/S20etmPA1GjVaJqkdRXz9EHYCVOQNpiB3tJPQ0uvr3BWO3ZBgNJmO \
tS8Ufj3h9fPcWy4XuILCd3PiHwSajIoCKQ7Au9xVCrVVEhiQUff0+kf5671DIDBhA4n1HHh8B93S \
ZTCSiNMT6NAGlTScix0UURwciCg042QrtN/YzqBO+3EsPoGKjG3I177IO/GMLZqB1AzYesuIgxOw \
jf54T9mQccbJ/odJn+/rSlaWNHo1tro8z12ljNmQRMhcKMWhjJ4yOxnJ27zu/GLvrAXTdC6xeLlX \
R8KHe8dcnFmhIYPhsjRXlU8G66IO0hqKISW84ob4QKlV28mAEHx0EKPdTP8eBAyMES1U5GxktinJ \
IM09OuFOlPy58/VMT5uCSjTXQpkurC+L4JIKlDj9VfKREtSTCN9qS+dYL1V/Iz4W7jD6wgPkgrrQ \
NeUs3kGpEUKqV/Kf8RkxCgq29qyWoDqNgSeEmMFySWvw9D4cswcNlBZcNggeyahosps9jGCurscz \
55ZMegoUkEItcNAM2kL5IB7pIB45QFxOsmeq2pZYzdHWVdFwacoH1mMvexVy2CdUONmroNO0DxKf \
+4JPczM3XNIRNqJ1qV7b1YuVSlJQqNV3eCfRpgBamvhE1CE+I4ngx6MqKNop+PeVOFIrMoYNmlFC \
VmkUuRQjZx/mwiQbwVKR8nbUQ02NydtIHXMj3E9jdI8dV+U+I8cnS0K51anUXFVmWprfikBEUqOt \
S5pE1eVTSaOsYFfBmEECCxiBixMUXKtFmTa2ak37yurhsylTW4axU0eIdISoyp9DqUVHp7JLreQe \
FMsDPZE4MpcnN0v8cqWU2ATazRabqnnUxDwUahsILsZTMIqbsBTUdkFRSwFJU5K6+kl/UIGlUBsq \
ryT8MCGcAGVromn7nhX5X7I2072kFEdrDZsRUtm2GeGxGfgnzFKHd1ia8ZimkG9Y7dLN+d5MeQCy \
4FAwVw6fHR/7r38+OKcCCst+oHNa7eIRRmi7hc7bBz0Rnvrx9KdnLzfzi3azxYb4V+w1xaHIh0tu \
Rs3FVejViil342pw1bZca4CzyqQdttjkuH0znl2trgFYFb4eHrrcgcM23WSyhEp1Nqmz0OH0gvFA \
R0hbTSJH9Il23irnW6YXFIfniC3hk4TgZ6W4Ts4v5tXZyzMaxPwCBNrwgh3SIjo5q2uQQyL/Taaf \
e36Bzta80Ww+cziJf5wPYZfjar/HtF0AhnvnsHPABpDh3echIA2zwhz8kyBbwx2tpqexX1gW6BnW \
ZXgByzK+naxYU/REX/gxxV2ZFUPYQbCNpJPw3WCJtmviHrycoGpSuaszgKfF+HRh5CXzJ3TSx6uh \
M99jRyd0H8gMb1jQFT7KHnDEh/d7y7kr31gx82uO49702jvRi17nB3dz2ld72Z5zwhBbWAMt83R7 \
My8FU3g7eBWN10B/PpdFXZFky02hikhB6RZYuUixknawuaKB6d75w63+RQ6V2BIfj6eSPHieiuiT \
0ohFVyrnpQzAH/v/wgSXzttKr/O21tvUw6Pvd0WR7WHBa+7KVToJJuwmKEUj7/mrn/pPnp0pS4nP \
LMIub5xVMSPKrm7WEAkKVhswWcDQ+uWfTwpoZAWpKq9/fVoI0My9G8iSqEu2WUYT6AxPWcTeAaYJ \
wJ+IfG79589+O5XVIhdoMLd3tFjkr6NN2JeBJQ6WbyHKj4144ivU1moiVO1rUOvWajhi0CChjKd/ \
Y0L45XxNucU5Tct+PF8vh+O4UQ4afNL5tZdDWTMh3qJWJTEG+KqJN3RLigmLEJUgxF0Pv5YaNVWN \
Bof2GAWw2zb1BEWtYUOY9kYHo8nSGgepbma1D4M+5eBUFsDkxpfJniirlgAnAM4QdLswiXKjRgFM \
il8+CKCy3CXFI9oYHLagdhwrz/uz1opPcIp3dQ1W+hXsjoakwW6MwqBbgj375Kn/7MXLX84wQW18 \
df3Ony2W/p+U0+0P7grHzweUGnXC9kAwdSiRL2w9DKeUvyfy+nqMl09VR+JNKr+vzJMCH6qkwDJu \
DVF8pBVTqqA9JcFLMT3QGqKQhfrF8HoVgVo8yMt/dqxdBrXtEhNGKl7Z7qfsVYHBNukHpOgCuo/v \
JWSCilvcSsmmBBQlOHiut5Y7hvebhc3myYkZkVOS5BJMCZAG/vgWjJ0Yj9H7/mw+u6BizKjAFHND \
7iRYEbmUF4MRD3zCDOFvxI0PfuvBOv7UwBWllXOsm7ZoyWcrja9lvjBsFK0VEnTNCi1q6gwt5/KK \
88NHXsoO0qJxaIe4zKTx8HrOU/cLwBx3It2/bHlKamXbI6aZGjZIl/Orlna9UK4wC9CxSKqWDlmt \
gNAEVvjTc/hzGQBPLGJLq9ORvJVzJPtAhodsLhL7quQffRsnWyrGmxbxpAlhVGeLLYHOFuiiBqYL \
kiBVgeNIgTxmWwXJ1LJKfZ9OL279J1XrDT7Eqn973H989tPrwzawo9+ptmdDcdeF6bwbfVxEdD0G \
ah7tEawcJcjUhYflUz1ex+hca8/qIiGnjYczPauD1LhrruHu5WfPLLZFu9vFvDiXCj17ueUj2VLO \
KHles/o+fQ8CiPmLD8ySgHojjZ9BbcnTcmWmgQyxM4s6MpiPCoYl8SVErKADqFhTktnXoL3mZGCr \
+ray7IZ2uZ7xO++t9+lMbtBqCaSRwa2nuHQr6XTudLd4z7dVOJtfrxfsmCmLB/cscS+wg74K2Vc6 \
9qoM2d6I+cs1K8dB9zb8sdupkCNrE9aPdpWW+lz9ofpDZ7r9R2/bBY3jqmyYUrxz4Q0xcOzEvQd2 \
F9dLNE1GiTtQZNjJCUtknmrIvH7pj9K0NMLjw2AyXF6C+LmuxKvRfL2qgi2hmXpipi2ZJXKlNleU \
x2tEZgpXSMLA7/DcalNKFDdHkR+Cbasn1BqULvTCCqpQzB8hMGgCLUaDT7HHDlPUr+uaO22aVd3v \
mBg2Pz97/QZk8puzV89JoXoAZW9OH7/4+7M3f/R/Oz17/ezVS8GmO/TyKB0mkof/aUZg2vkYrA9p \
XkaXRmDIbKS3MGto/gEdFhgo2jdZqd0+YSmtih2327rQkKuq97QaTMBgfMQ8u5Jh9huUEK/mCzcp \
OKQcPyq3T8qhifMZYu79BMjU/xvTOzX4HmX+NhvfWCT2cTDBLMrpZNUOm/o7ro+gsbAwgGrbwlBS \
BC6pm9BGIB2XNHrzfXFusmkHWu4hrWjSZbmKSrHG2xBGlKoWMfutvabW5HKlmfnCJGzDHV0QjNqY \
cssgneXYrTkb2MEf4KLDpMUKaGScpBJL0SDLqsl2HsiUONqz1E7CEqWS+WhvWq7xp19e4N0XXrHp \
Efm7y1FrQEFh7Ra8X2cLetbnqdrynaYqo6xO6cpGwoJLw3WltlD0CV+cm8qz4JFGVlBmkJwcis4u \
nblBjkSdtAsRjPbMOWgJm1njlzDoeE+h7ojQUTSIn/2R4kmelL4by8rcn8jLuCHABIobOZuS55cW \
5TZUvC4zk4Ez1pyEBdSpM0jAyiDnyzcZOVZPdZgFSEvKTeDkD4wGJ/Sajmzei2gN0hk7+GRmVGig \
zLDk/ryxJIMqTYhAEejP4sle7qxnR4IGH4s8B0lrY6Oa4yRdPFys04XT8TRVyC0PqfwRueAhVAAK \
1O00aLVDHgl66plEYVXMhMgPdyX10mGRTIxpKyS2znQyG4C+/2HMKvLw6AjYm5hxVW4o2iZ/GY4t \
/Dqnwxmex+k2vXXkZQkPXBw0IxDMQYIKi//RkenekSTVsEqKT3XkEprM6NfZ+9n840w6gxR7cYLf \
K0OcsSNaY3rj4CPOTEcHLYDpR/eZ6lj/i9CuoTzDaXSuh9jIF6Rr0PPRHFkl7snhfA022QnjR73w \
998MEwpo3a0424qg8gpwZ6UWiEh5WYRYMPRuchBvtKLkhKuwy0wt3WnW8E/cyuTXBodN495gsypp \
u+E5WWuHpRfnrAT1Qd2lSDgpX9pZcUAuLobtKXHYSTq5CO0xYk5P0+VyDHbideIheAFsVDkB1sEg \
YqU4oM7xsHudXPpuvZfiYbYx2J4hcWhmY9vVOO0/UBqiGL9uY6ddCjSViVaw45W2Tu+ATRxYARRX \
Hn4xNH7b14BPWR34juuM1BvGsVNX/vLSU1Z6gy5yCZd5dVzBZqaLIaAfvcv1MxgqcgH9jZPl1h/p \
14prpoG0p8gLIA+9bA7Myew1nBxhB+0mZromGdhjvOIWaKjMIqdJlJhD6kuBfowBXa1aYZ/bLv22 \
CgBXKSqreas63Ie19XuHVRkT7m4x9MuM2C86s3imAo/7AlFVzQFM8Vb7eL0c89NlNB/62QfUSunw \
lT0+Ka3k2nLWIUcd4EIkXEOWCkkGc0O09zvFTUF+fNTb9dr8ciFxA04iAXRnnoSkj/6e+04fPplF \
/X58DRCliFVYq1jf8RnCdM9hyJygi7ytd+7ZGNeHTDOU3TjqqZ1OVqBZQSdtLmbYcYWyNGi5k9Xz \
VBYGjQ1jYAaSXaOR9zqLDaW5wffoB2bETvm8i6HcIo2Dg3U8uBpHDC/GYx1es8c6HRye2PO9RqOx \
9X0g/540eperreR3sHVVQKGXfo9wpamUeJhYxkPvUi0o+JXxTOcjvFKe6xeyA/rVUXcH1/iLDhw4 \
w0su6gxv+FU/z0QXL+Kk6OeOtn4HHZK9nlpudjOAXTcTP4dEu4+cluxifDmHrQkAGolCQJD4T6tt \
R5MY/6sloomCgBf+sezTvfLBzgD8Fd5MRtBtyQ3o5AtBOgrXQdDLotyHjQBJLnEhHvunr57St++m \
BwWm4qbtcglFQ+lNvXwgYwbtMl5OxBc6SUdvBNol4o1P0xtV/5AaCGkW3N7e4isRoMBXv09v8TaI \
qVZ8yMtjUS7GCWM8OBg3JHphH+IPwj6SiGPlEQaYljwyy39AhshZkmCXbg8Oxf+j8n8GpiVcgg+b \
yI2cLUh5z3iHBOY3MQysKewgMkmHTyQnRZL+15clfnm+PF+eL8+X58vz5fny/B88/wb9uucaAKAA \
AA== \
| base64 -d | tar -xzvf -; \
    chmod -v 644 *.conf xjar && \
    mkdir -v /etc/nginx/http.conf.d /etc/nginx/rtmp.conf.d /etc/nginx/stream.conf.d; \
    mv -v /etc/nginx/http.conf /etc/nginx/http.conf.d/default.conf; \
    mv -v /etc/nginx/rtmp.conf /etc/nginx/rtmp.conf.d/default.conf; \
    mv -v /etc/nginx/stream.conf /etc/nginx/stream.conf.d/default.conf; \
    sed -i 's@/$nginx_version@@' /etc/nginx/fastcgi_params; \
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
