#!/bin/bash

mkdir -p /etc/ssl-secret

cp wercker/fake-ssl/* /etc/ssl-secret/
cp /usr/src/proxy_ssl.conf /etc/nginx/conf.d/proxy.conf

FAKE_SERVER_NAME=example.com
FAKE_ROOT_DIR=/srv/foobar
sed -i "s#{{SERVER_NAME}}#${FAKE_SERVER_NAME}#g;" /etc/nginx/conf.d/proxy.conf
sed -i "s#{{ROOT_DIR}}#${FAKE_ROOT_DIR}#g;" /etc/nginx/conf.d/proxy.conf

nginx -t -c /etc/nginx/nginx.conf
