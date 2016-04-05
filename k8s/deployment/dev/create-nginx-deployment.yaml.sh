#!/bin/bash

cat > nginx-deployment.yaml << EOF
 apiVersion: extensions/v1beta1
 kind: Deployment
 metadata:
   name: nginx-deployment
   labels:
     name: nginx-deployment
     rev: ${WERCKER_GIT_COMMIT}
 spec:
   replicas: 1
   template:
     metadata:
       labels:
         name: nginx
     spec:
       containers:
         - name: nginx
           image: ${DOCKER_REPO}:${WERCKER_GIT_COMMIT}
           env:
             - name: SERVER_NAME
               valueFrom:
                 configMapKeyRef:
                   name: nginx-config
                   key: server.name
             - name: ENABLE_SSL
               valueFrom:
                 configMapKeyRef:
                   name: nginx-config
                   key: enable.ssl
           ports:
             - name: http
               containerPort: 80
             - name: https
               containerPort: 443
           livenessProbe:
             httpGet:
               path: /
               port: 443
               scheme: HTTPS
             initialDelaySeconds: 10
             periodSeconds: 30
             timeoutSeconds: 5
           readinessProbe:
             httpGet:
               path: /
               port: 443
               scheme: HTTPS
             initialDelaySeconds: 30
             timeoutSeconds: 1
           volumeMounts:
             - name: ssl-config
               mountPath: /etc/ssl-config
             - name: nginx-nfs-pvc
               mountPath: /srv/
       volumes:
         - name: nginx-config
           configMap:
             name: nginx-config
         - name: ssl-config
           configMap:
             name: ssl-config
         - name: nginx-nfs-pvc
           persistentVolumeClaim:
             claimName: nginx-nfs-pvc
EOF
