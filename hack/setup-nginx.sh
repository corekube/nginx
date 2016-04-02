#!/bin/bash

mkdir -p /etc/nginx/conf.d
cp start.sh /usr/src/
cp nginx/nginx.conf /etc/nginx/
cp nginx/proxy*.conf /usr/src/
