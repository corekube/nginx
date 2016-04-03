#!/bin/bash

cat > nginx-deployment.yaml << EOF
 apiVersion: extensions/v1beta1
 kind: Deployment
 metadata:
   name: nginx-deployment
   labels:
     name: nginx-deployment
     rev: ${WERCKER_GIT_COMMIT}
   namespace: nginx-dev
 spec:
   replicas: 1
   template:
     metadata:
       labels:
         name: nginx
     spec:
       containers:
         - name: git-sync
           image: metral/git-sync
           imagePullPolicy: Always
           volumeMounts:
             - name: markdown
               mountPath: /git
           env:
             - name: GIT_SYNC_REPO
               value: https://github.com/corekube/web
             - name: GIT_SYNC_BRANCH
               value: dev
             - name: GIT_SYNC_REV
               value: origin/dev
             - name: GIT_SYNC_DEST
               value: /git
             - name: GIT_SYNC_WAIT
               value: "60"
         - name: hugo
           image: metral/hugo
           imagePullPolicy: Always
           args:
             - server
             - --source=\${HUGO_SRC}
             - --theme=\${HUGO_THEME}
             - --baseUrl=\${HUGO_BASE_URL}
             - --destination=\${HUGO_DEST}
             - --appendPort=false
             - --watch
             - --disableLiveReload
           volumeMounts:
             - name: markdown
               mountPath: /src
             - name: html
               mountPath: /dest
           env:
             - name: HUGO_THEME
               value: hugo-multi-bootswatch
             - name: HUGO_BASE_URL
               value: ${SERVER_NAME}
         - name: nginx
           image: ${DOCKER_REPO}:${WERCKER_GIT_COMMIT}
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
             - name: nginx-config-secret
               mountPath: /etc/nginx-config-secret
               readOnly: true
             - name: nginx-ssl-secret
               mountPath: /etc/nginx-ssl-secret
               readOnly: true
             - name: nginx-nfs-pvc
               mountPath: /srv/
             - name: html
               mountPath: /usr/share/nginx/html
               readOnly: true
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
         - name: markdown
           emptyDir: {}
         - name: html
           emptyDir: {}
EOF
