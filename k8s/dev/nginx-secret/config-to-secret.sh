#!/bin/bash

# Encodes the environment variables into a Kubernetes secret.
EXPECTEDARGS=3
if [ $# -lt $EXPECTEDARGS ]; then
  echo "Usage: $0 <SERVER_NAME> <SSL_CRT_FILEPATH> <SSL_KEY_FILEPATH>"
    exit 1
fi

SERVER_NAME=$1
SSL_CRT_FILEPATH=$2
SSL_KEY_FILEPATH=$3

# create nginx-secret (envvar file for nginx.conf) based on user input
sed -e "s#{{SERVER_NAME}}#${SERVER_NAME}#g" ./nginx-secret-template > nginx-secret

# set nginx-secret (envvar file for nginx.conf) contents as
# base64 data in nginx-secret.yaml
BASE64_ENC=$(cat nginx-secret | base64 --wrap=0)
sed -e "s#{{CONFIG_DATA}}#${BASE64_ENC}#g#g" ./nginx-secret-template.yaml > nginx-secret.yaml

# set ssl.crt as base64 data in nginx-secret.yaml
BASE64_ENC=$(cat $SSL_CRT_FILEPATH | base64 --wrap=0)
sed -i "s#{{SSL_CRT}}#${BASE64_ENC}#g#g" ./nginx-secret.yaml

# set ssl.key as base64 data in nginx-secret.yaml
BASE64_ENC=$(cat $SSL_KEY_FILEPATH | base64 --wrap=0)
sed -i "s#{{SSL_KEY}}#${BASE64_ENC}#g#g" ./nginx-secret.yaml
