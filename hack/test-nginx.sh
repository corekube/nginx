#!/bin/bash

mkdir -p /etc/nginx-ssl-secret

cp wercker/fake-ssl/* /etc/nginx-ssl-secret/
cp /usr/src/proxy_ssl.conf /etc/nginx/conf.d/proxy.conf

sed -i "s/{{SERVER_NAME}}/$SERVER_NAME/g;" /etc/nginx/conf.d/proxy.conf

nginx -t -c /etc/nginx/nginx.conf
