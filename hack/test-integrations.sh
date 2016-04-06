#!/bin/bash

FAKE_SERVER_NAME=example.com
PROJ_NAME=nginx
DEPLOYMENT_NAME=$PROJ_NAME-deployment

# Tests are based on k8s resources in the following env
# - options are: dev, stage, prod
PROJ_ENV=dev

# get namespace used in current config context
NAMESPACE=`kubectl config view | grep integration-test | awk -F ": " '{print $2}'`

# create nginx ConfigMap
CONFIGMAP_NAME=nginx-config
kubectl create configmap $CONFIGMAP_NAME \
  --from-literal=server.name="$FAKE_SERVER_NAME" \
  --from-literal=enable.ssl="true"

# create ssl ConfigMap
CONFIGMAP_NAME=ssl-config
kubectl create configmap $CONFIGMAP_NAME \
  --from-file=fullchain.pem="./wercker/fake-ssl/fullchain.pem" \
  --from-file=chain.pem="./wercker/fake-ssl/chain.pem" \
  --from-file=privkey.pem="./wercker/fake-ssl/privkey.pem" \
  --from-file=cert.pem="./wercker/fake-ssl/cert.pem" \
  --from-file=dhparams.pem="./wercker/fake-ssl/dhparams.pem"

# create PV
PV=$(cat <<EOF
{
  "kind": "PersistentVolume",
  "apiVersion": "v1",
  "metadata": {
      "name": "nfs-pv-${WERCKER_GIT_COMMIT:0:5}"
  },
  "spec": {
      "capacity": {
          "storage": "100M"
      },
      "nfs": {
          "server": "$PV_SERVER",
          "path": "$PV_PATH"
      },
      "accessModes": [
          "ReadWriteMany"
      ],
      "persistentVolumeReclaimPolicy": "Retain"
  }
}
EOF
)
echo $PV | kubectl create -f -

# create PVC
pushd k8s/pvc/$PROJ_ENV/ > /dev/null
  kubectl create -f nfs-pvc.yaml
popd > /dev/null

# create DEPLOYMENT
pushd k8s/deployment/$PROJ_ENV/ > /dev/null
  DOCKER_REPO=corekube/$PROJ_NAME \
    WERCKER_GIT_COMMIT=${WERCKER_GIT_COMMIT:-`git rev-parse HEAD`} \
    ./create-$PROJ_NAME-deployment.yaml.sh
  kubectl create -f $PROJ_NAME-deployment.yaml
popd > /dev/null

# create SVC
pushd k8s/svc/$PROJ_ENV/ > /dev/null
  sed -e "s#nodePort:.*##g" $PROJ_NAME-svc.yaml > /tmp/$PROJ_NAME-svc.yaml
  kubectl create -f /tmp/$PROJ_NAME-svc.yaml
popd > /dev/null

# wait for deployment to be 'Running'
# when SLEEP_INTERVAL=1, iterations is used as a timeout for this many seconds
ITERATIONS=300
SLEEP_INTERVAL=1

isReady(){
  replicasNotReady=`kubectl get deployment -l name=$1 -o go-template="{{range.items}}{{.status.unavailableReplicas}}{{end}}"`

  if [ "$replicasNotReady" == "<no value>" ]; then
    return 0
  fi

  return 1
}

i=0
while [ "$i" -lt $ITERATIONS ]; do
  STATUS=`kubectl get deployment -l name=$PROJ_NAME-deployment`
  echo "$STATUS"

  if isReady $PROJ_NAME-deployment; then
    kubectl describe po -l name=$PROJ_NAME
    echo "==============================="
    echo "Deployment creation successful."
    echo "==============================="
    exit 0
  fi

  sleep $SLEEP_INTERVAL;
  i=$((i+1))
done

kubectl describe po -l name=$PROJ_NAME
echo "==============================="
echo "Deployment creation failed."
echo "==============================="
exit 1
