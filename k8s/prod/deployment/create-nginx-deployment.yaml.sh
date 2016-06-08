#!/bin/bash

cat > nginx-deployment.yaml << EOF
 apiVersion: extensions/v1beta1
 kind: Deployment
 metadata:
   name: nginx-deployment
 spec:
   replicas: 3
   selector:
     matchLabels:
      app: nginx
      env: prod
   template:
     metadata:
       name: nginx
       labels:
         app: nginx
         env: prod
         rev: "${BUILD_COMMIT}"
     spec:
       containers:
         - name: nginx
           image: ${DOCKER_REPO}:${IMAGE_TAG}
           ports:
             - name: http
               containerPort: 80
             - name: https
               containerPort: 443
           readinessProbe:
             httpGet:
               path: /
               port: 443
               scheme: HTTPS
             initialDelaySeconds: 5
             timeoutSeconds: 1
           livenessProbe:
             httpGet:
               path: /
               port: 443
               scheme: HTTPS
             initialDelaySeconds: 10
             timeoutSeconds: 5
           volumeMounts:
             - name: nginx-config
               mountPath: /etc/config
             - name: nginx-nfs-pvc
               mountPath: /srv/
       volumes:
         - name: nginx-config
           configMap:
             name: nginx-config
         - name: nginx-nfs-pvc
           persistentVolumeClaim:
             claimName: nginx-nfs-pvc
EOF
