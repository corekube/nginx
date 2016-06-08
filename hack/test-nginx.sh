#!/bin/bash

FAKE_SERVER_NAME=example.com
FAKE_ROOT_DIR=/srv/foobar
FAKE_SSL_CERTS_DIR=/srv/ssl-certs
FAKE_LETSENCRYPT_ACME_DIR=/srv/fake-acme-dir

# setup ssl certs dir
mkdir -p $FAKE_SSL_CERTS_DIR
cp wercker/fake-ssl/* $FAKE_SSL_CERTS_DIR/

# cp source proxy_ssl.conf to nginx dir
cp /usr/src/proxy_ssl.conf /etc/nginx/conf.d/proxy.conf

# Insert fake env vars to configure nginx
sed -i "s#{{LETSENCRYPT_DIR}}#$FAKE_SSL_CERTS_DIR#g;" /etc/nginx/conf.d/proxy.conf
sed -i "s#{{SSL_CERTS_DIR}}#$FAKE_SSL_CERTS_DIR#g;" /etc/nginx/conf.d/proxy.conf
sed -i "s#{{LETSENCRYPT_ACME_DIR}}#$FAKE_LETSENCRYPT_ACME_DIR#g;" /etc/nginx/conf.d/proxy.conf
sed -i "s#{{ROOT_DIR}}#$FAKE_ROOT_DIR#g;" /etc/nginx/conf.d/proxy.conf

sed -i "s#{{SERVER_NAME}}#$FAKE_SERVER_NAME#g;" /etc/nginx/conf.d/proxy.conf

# test nginx config
nginx -t -c /etc/nginx/nginx.conf
