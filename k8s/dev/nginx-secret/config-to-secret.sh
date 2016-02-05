#!/bin/bash

# Encodes the environment variables into a Kubernetes secret.
EXPECTEDARGS=1
if [ $# -lt $EXPECTEDARGS ]; then
  echo "Usage: $0 <SERVER_NAME>"
    exit 0
fi

SERVER_NAME=$1
sed -e "s#{{SERVER_NAME}}#${SERVER_NAME}#g" ./nginx-secret-template > nginx-secret

BASE64_ENC=$(cat nginx-secret | base64 --wrap=0)
sed -e "s#{{CONFIG_DATA}}#${BASE64_ENC}#g#g" ./nginx-secret-template.yaml > nginx-secret.yaml
