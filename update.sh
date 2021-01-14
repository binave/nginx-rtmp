#!/bin/bash
# commit 'nginx.conf' and 'default.conf' at Dockerfile

cd `dirname $0`;

sed -i ':1;N;$!b1;s@[0-9A-Za-z/+]\{76\}[[:space:]][^|]\+@'"`

    tar -czf - nginx.conf default.conf | base64 | awk '{print $0 " \\\\\\\\\\\\"}'

`"\n'@' ${0%/*}/Dockerfile
