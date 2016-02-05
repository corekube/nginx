#!/bin/bash

cat > nginx-rc.yaml << EOF
 apiVersion: v1
 kind: ReplicationController
 metadata:
   name: nginx-rc
   labels:
     name: nginx-rc
   namespace: dev
 spec:
   replicas: 1
   selector:
     name: nginx
     deployment: ${WERCKER_GIT_COMMIT}
   template:
     metadata:
       labels:
         name: nginx
         deployment: ${WERCKER_GIT_COMMIT}
     spec:
       containers:
         - name: nginx
           image: ${DOCKER_REPO}:${WERCKER_GIT_COMMIT}
           env:
             - name: ENABLE_SSL
               value: "true"
           ports:
             - name: http
               containerPort: 80
             - name: https
               containerPort: 443
           volumeMounts:
             - name: nginx-secret
               mountPath: /etc/nginx-secret
               readOnly: true
       imagePullSecrets:
         - name: docker-registry-config
       volumes:
         - name: nginx-secret
           secret:
             secretName: nginx-secret
EOF
