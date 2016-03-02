#!/bin/bash

cat > nginx-deployment.yaml << EOF
 apiVersion: extensions/v1beta1
 kind: Deployment
 metadata:
   name: nginx-deployment
   labels:
     name: nginx-deployment
     rev: ${WERCKER_GIT_COMMIT}
   namespace: nginx-prod
 spec:
   replicas: 3
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
               readOnly: false
           env:
             - name: GIT_SYNC_REPO
               value: https://github.com/corekube/web
             - name: GIT_SYNC_BRANCH
               value: master
             - name: GIT_SYNC_REV
               value: origin/master
             - name: GIT_SYNC_DEST
               value: /git
             - name: GIT_SYNC_WAIT
               value: "120"
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
               readOnly: false
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
