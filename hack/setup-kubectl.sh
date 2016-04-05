#!/bin/bash

# auth against the identity service
auth=`curl -s -k -X POST https://identity.api.rackspacecloud.com/v2.0/tokens \
  -H "Content-Type: application/json" \
  -d '{
"auth": {
"RAX-KSKEY:apiKeyCredentials": {
"username": "'$CF_USERNAME'",
"apiKey": "'$CF_API_KEY'"
      }
    }
  }'
`

# extract token
TOKEN=`echo $auth | grep token | grep id | \
awk -F '","' '{print $1}' | awk -F '":"' '{print $2}'
`

# pull down kubeconfig files
CERTS_DIR=/srv/kubernetes
mkdir -p $CERTS_DIR

curl -s -k -o $CERTS_DIR/kubecfg.crt -X GET $CF_ENDPOINT/$CF_CONTAINER_NAME/kubecfg.crt \
  -H "X-Auth-Token: $TOKEN" \
  -H "Accept: application/json"

curl -s -k -o $CERTS_DIR/kubecfg.key -X GET $CF_ENDPOINT/$CF_CONTAINER_NAME/kubecfg.key \
  -H "X-Auth-Token: $TOKEN" \
  -H "Accept: application/json"

curl -s -k -o $CERTS_DIR/ca.crt -X GET $CF_ENDPOINT/$CF_CONTAINER_NAME/ca.crt \
  -H "X-Auth-Token: $TOKEN" \
  -H "Accept: application/json"

# setup ssh tunnel to k8s master priv interface
# ~/.ssh/config is added by Wercker step 'add-ssh-key':
# https://github.com/wercker/step-add-ssh-key/blob/master/addKey.sh
IDENTITY_FILE=`cat ~/.ssh/config | grep -i identity | awk -F " " '{print $2}'`
ssh -i $IDENTITY_FILE -L 9443:$KUBERNETES_MASTER_PRIVATE_IP:443 root@$KUBERNETES_MASTER_PUBLIC_IP -f -N

# pull down kubectl
wget --quiet https://storage.googleapis.com/kubernetes-release/release/v$KUBERNETES_VERSION/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

# configure kubectl
NAMESPACE="integration-test-${WERCKER_GIT_COMMIT:0:5}"
/usr/local/bin/kubectl config set-cluster local --server=https://127.0.0.1:9443
/usr/local/bin/kubectl config set-cluster local --certificate-authority=/$CERTS_DIR/ca.crt
/usr/local/bin/kubectl config set-credentials wercker --client-certificate=$CERTS_DIR/kubecfg.crt
/usr/local/bin/kubectl config set-credentials wercker --client-key=$CERTS_DIR/kubecfg.key
/usr/local/bin/kubectl config set-context local --cluster=local
/usr/local/bin/kubectl config set-context local --user=wercker
/usr/local/bin/kubectl config set-context local --namespace=$NAMESPACE
/usr/local/bin/kubectl config use-context local

# test kubectl
/usr/local/bin/kubectl version
/usr/local/bin/kubectl get ns $NAMESPACE && ACTION=null || ACTION=create;

if [ "$ACTION" == create ]; then
  /usr/local/bin/kubectl create ns $NAMESPACE
fi
