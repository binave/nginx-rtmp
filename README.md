## nginx-rtmp-docker (alpine)
Dockerfile for nginx-rtmp-module + njs (dynamic) + FFmpeg from source, buile on Alpine linux.

---------
# Licensing
nginx-rtmp-docker is licensed under the Apache License, Version 2.0. See
[LICENSE](https://github.com/binave/nginx-rtmp/blob/master/LICENSE) for the full
license text.

import:
* [alpine linux](https://alpinelinux.org/)
* [nginx](http://nginx.org)
* [nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module)
* [njs](https://github.com/nginx/njs)
* [ffmpeg](https://www.ffmpeg.org)
* [Zulu OpenJDK](https://www.azul.com/products/zulu-community/)
* [Source Han Sans](https://github.com/adobe-fonts/source-han-sans)

---------

build

```sh

# simple build
docker build --tag binave/nginx-rtmp:1.21.4-alpine .

# custom version build
docker build \
    --tag binave/nginx-rtmp:1.21.4-alpine \
    --build-arg REPO_MIRRORS_URL=https://mirrors.huaweicloud.com/alpine \
    --build-arg ALPINE_VERSION=3.14.3 \
    --build-arg NGINX_VERSION=1.21.4 \
    --build-arg NGINX_RTMP_VERSION=1.2.2 \
    --build-arg NJS_VERSION=0.6.2 \
    --build-arg FFMPEG_VERSION=4.3.3 \
    .

# remove <none> images
docker images | awk '/<none>[[:space:]]+<none>/{printf " %s", $3};BEGIN{printf "docker rmi"}' | $SHELL

```

run

```sh
# ready
docker run --detach --rm --name nginx binave/nginx-rtmp:1.21.4-alpine tail -f /dev/null
mkdir /opt/nginx
docker cp nginx:/etc/nginx/http.conf.d /opt/nginx
docker cp nginx:/etc/nginx/rtmp.conf.d /opt/nginx
docker cp nginx:/etc/nginx/stream.conf.d /opt/nginx
docker cp nginx:/etc/ssl /opt/nginx
docker cp nginx:/run/www /run
docker stop nginx

[ -f /etc/timezone ] || echo "Asia/Shanghai" > /etc/timezone

# run
docker run --detach \
    --name nginx \
    --restart always \
    --publish 80:80 \
    --publish 443:443 \
    --publish 1935:1935 \
    --publish 8457:8457 \
    --volume /opt/nginx/http.conf.d:/etc/nginx/http.conf.d \
    --volume /opt/nginx/rtmp.conf.d:/etc/nginx/rtmp.conf.d \
    --volume /opt/nginx/stream.conf.d:/etc/nginx/stream.conf.d \
    --volume /opt/nginx/ssl:/etc/ssl \
    --volume /run/www:/run/www \
    --volume /etc/timezone:/etc/timezone:ro \
    --volume /etc/localtime:/etc/localtime:ro \
    binave/nginx-rtmp:1.21.4-alpine

```

Let's Encrypt website
```sh

docker run --rm \
    --volume /run/www:/www \
    --volume /opt/nginx/ssl/letsencrypt:/etc/letsencrypt \
    certbot/certbot:$(docker images | awk '/^certbot/{print $2}' | sort -rV | head -1) \
    certonly \
        --non-interactive \
        --agree-tos \
        --email <user@example.com> \
        --webroot \
        --webroot-path /www \
        --domain <www.example.com>

docker exec nginx nginx -s reload

```


alias nginx

```sh
cat >> ~/.bash_profile <<EOF
alias nginx='docker exec nginx nginx'
EOF

```
