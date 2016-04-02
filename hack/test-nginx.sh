#!/bin/bash

mkdir -p /etc/ssl-config

cp wercker/fake-ssl/* /etc/ssl-config/
cp /usr/src/proxy_ssl.conf /etc/nginx/conf.d/proxy.conf

FAKE_SERVER_NAME=example.com
sed -i "s/{{SERVER_NAME}}/$FAKE_SERVER_NAME/g;" /etc/nginx/conf.d/proxy.conf

nginx -t -c /etc/nginx/nginx.conf
