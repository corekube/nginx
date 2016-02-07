#!/bin/bash

cat > nginx-rc.yaml << EOF
 apiVersion: v1
 kind: ReplicationController
 metadata:
   name: nginx-rc
   labels:
     name: nginx-rc
   namespace: stage
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
             - name: nginx-config-secret
               mountPath: /etc/nginx-config-secret
               readOnly: true
             - name: letsencrypt-pvc
               mountPath: /letsencrypt
       imagePullSecrets:
         - name: docker-registry-config
       volumes:
         - name: nginx-config-secret
           secret:
             secretName: nginx-config-secret
         - name: letsencrypt-pvc
           persistentVolumeClaim:
             claimName: letsencrypt-pvc
EOF
