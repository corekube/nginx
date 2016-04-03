#!/bin/bash

namespace=`kubectl config view | grep integration-test | awk -F ": " '{print $2}'`
echo $namespace
#sed -e "s#namespace.*#namespace=$namespace#g" k8s/deployment/dev/create-nginx-deployment.yaml.sh > /tmp/create-nginx-deployment.yaml.sh
