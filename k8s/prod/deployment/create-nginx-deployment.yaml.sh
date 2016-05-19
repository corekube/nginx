#!/bin/bash

cat > nginx-deployment.yaml << EOF
 apiVersion: extensions/v1beta1
 kind: Deployment
 metadata:
   name: nginx-deployment
 spec:
   replicas: 3
   template:
     metadata:
       name: nginx
       labels:
         app: nginx
         env: prod
         tag: ${IMAGE_TAG}
     spec:
       containers:
         - name: nginx
           image: ${DOCKER_REPO}:${IMAGE_TAG}
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
             initialDelaySeconds: 5
             timeoutSeconds: 1
           volumeMounts:
             - name: ssl-secret
               mountPath: /etc/ssl-secret
             - name: nginx-nfs-pvc
               mountPath: /srv/
       volumes:
         - name: nginx-config
           configMap:
             name: nginx-config
         - name: ssl-secret
           configMap:
             name: ssl-secret
         - name: nginx-nfs-pvc
           persistentVolumeClaim:
             claimName: nginx-nfs-pvc
EOF
