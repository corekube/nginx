#!/bin/bash

# Encodes the environment variables into a Kubernetes secret.
EXPECTEDARGS=1
if [ $# -lt $EXPECTEDARGS ]; then
  echo "Usage: $0 <SERVER_NAME>"
    exit 0
fi

# create envvar file for nginx.conf based on user input
SERVER_NAME=$1
sed -e "s#{{SERVER_NAME}}#${SERVER_NAME}#g" ./nginx-secret-template > nginx-secret

# set nginx.conf envvar file, nginx-secret, as base64 data in nginx-secret.yaml
BASE64_ENC=$(cat nginx-secret | base64 --wrap=0)
sed -e "s#{{CONFIG_DATA}}#${BASE64_ENC}#g#g" ./nginx-secret-template.yaml > nginx-secret.yaml

# set ssl.crt as base64 data in nginx-secret.yaml
BASE64_ENC=$(cat ssl.crt | base64 --wrap=0)
sed -i "s#{{SSL_CRT}}#${BASE64_ENC}#g#g" ./nginx-secret.yaml

# set ssl.key as base64 data in nginx-secret.yaml
BASE64_ENC=$(cat ssl.key | base64 --wrap=0)
sed -i "s#{{SSL_KEY}}#${BASE64_ENC}#g#g" ./nginx-secret.yaml
