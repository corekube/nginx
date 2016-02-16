#!/bin/bash

cat > nginx-rc.yaml << EOF
 apiVersion: v1
 kind: ReplicationController
 metadata:
   name: nginx-rc
   labels:
     name: nginx-rc
   namespace: nginx-dev
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
           ports:
             - name: http
               containerPort: 80
             - name: https
               containerPort: 443
           volumeMounts:
             - name: nginx-config-secret
               mountPath: /etc/nginx-config-secret
               readOnly: true
             - name: nginx-ssl-secret
               mountPath: /etc/nginx-ssl-secret
               readOnly: true
             - name: nginx-nfs-pvc
               mountPath: /srv/
               readOnly: false
       volumes:
         - name: nginx-config-secret
           secret:
             secretName: nginx-config-secret
         - name: nginx-ssl-secret
           secret:
             secretName: nginx-ssl-secret
         - name: nginx-nfs-pvc
           persistentVolumeClaim:
             claimName: nginx-nfs-pvc
EOF
