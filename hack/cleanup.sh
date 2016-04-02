#!/bin/bash

# get namespace used in current config context
NAMESPACE=`kubectl config view | grep integration-test | awk -F ": " '{print $2}'`

kubectl delete namespace $NAMESPACE
kubectl delete pv nfs-pv-${WERCKER_GIT_COMMIT:0:5}
