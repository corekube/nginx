#!/bin/bash
# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and

# source nginx-config
source /etc/config/nginx

# Remove existing configs, if any
rm /etc/nginx/conf.d/*.conf

# Env says we're using SSL 
if [ $ENABLE_SSL ]; then
  echo "Enabling SSL..."
  cp /usr/src/proxy_ssl.conf /etc/nginx/conf.d/proxy.conf
else
  # No SSL
  echo "Enabling *Without* SSL..."
  cp /usr/src/proxy_nossl.conf /etc/nginx/conf.d/proxy.conf
fi

# Insert env vars to configure nginx
sed -i "s#{{LETSENCRYPT_DIR}}#$LETSENCRYPT_DIR#g;" /etc/nginx/conf.d/proxy.conf
sed -i "s#{{SSL_CERTS_DIR}}#$SSL_CERTS_DIR#g;" /etc/nginx/conf.d/proxy.conf
sed -i "s#{{LETSENCRYPT_ACME_DIR}}#$LETSENCRYPT_ACME_DIR#g;" /etc/nginx/conf.d/proxy.conf
sed -i "s#{{ROOT_DIR}}#$ROOT_DIR#g;" /etc/nginx/conf.d/proxy.conf

sed -i "s#{{SERVER_NAME}}#$SERVER_NAME#g;" /etc/nginx/conf.d/proxy.conf

# Show proxy.conf for logs
cat /etc/nginx/conf.d/proxy.conf

echo "Starting nginx..."
nginx -g 'daemon off;'
