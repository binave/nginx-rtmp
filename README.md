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

---------

build

```sh

# simple build
docker build --tag binave/nginx-rtmp:1.17.10-alpine .

# custom version build
docker build \
    --tag binave/nginx-rtmp:1.17.10-alpine \
    --build-arg REPO_MIRRORS_URL=https://mirrors.aliyun.com/alpine \
    --build-arg ALPINE_VERSION=3.11.6 \
    --build-arg NGINX_VERSION=1.17.10 \
    --build-arg NGINX_RTMP_VERSION=1.2.1 \
    --build-arg NJS_VERSION=0.4.1 \
    --build-arg FFMPEG_VERSION=4.2.3 \
    .

# remove <none> images
docker images | awk '/<none>[[:space:]]+<none>/{printf " %s", $3};BEGIN{printf "docker rmi"}' | $SHELL

```

run

```sh
# ready
docker run --detach --rm --name nginx binave/nginx-rtmp:1.17.10-alpine tail -f /dev/null
mkdir /opt/nginx
docker cp nginx:/etc/ssl /opt/nginx
docker cp nginx:/etc/nginx/conf.d /opt/nginx
docker cp nginx:/usr/share/nginx/html /opt/nginx
docker stop nginx

# run
docker run --detach \
    --name nginx \
    --restart always \
    --publish 80:80 \
    --publish 443:443 \
    --publish 1935:1935 \
    --volume /opt/nginx/ssl:/etc/ssl \
    --volume /opt/nginx/conf.d:/etc/nginx/conf.d \
    --volume /opt/nginx/html:/usr/share/nginx/html \
    binave/nginx-rtmp:1.17.10-alpine

```

Let's Encrypt website
```sh
docker run --interactive --rm \
    --volume /opt/nginx/html:/www \
    --volume /opt/nginx/ssl/letsencrypt:/etc/letsencrypt \
    certbot/certbot \
    certonly \
        --agree-tos \
        --email user@example.com \
        --webroot \
        -w /www \
        -d www.example.com

```


alias nginx

```sh
cat >> ~/.bash_profile <<EOF
alias nginx='docker exec nginx nginx'
EOF

```