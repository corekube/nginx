# nginx

[![wercker status](https://app.wercker.com/status/21a779b13c0e2bd3e67bc0e4c17ded36/m "wercker status")](https://app.wercker.com/project/bykey/21a779b13c0e2bd3e67bc0e4c17ded36)

A nginx Docker container that is deployed on Kubernetes to serve local, static content over HTTPS using [letsencrypt.org](https://letsencrypt.org) certificates.

This nginx webserver:

  1. Configures nginx according to settings outlined in ConfigMaps:
    * Configuration settings to be used in nginx are provided via a Kubernetes ConfigMap named `nginx-config`, defined as such as:

      ```
       apiVersion: v1
       kind: ConfigMap
       metadata:
         name: nginx-config
       data:
         nginx: |
           #!/bin/bash

           # settings
           export ENABLE_SSL="true"
           export SERVER_NAME="corekube.com"

           # directory paths
           ## letsencrypt
           export LETSENCRYPT_DIR="/srv/etc/letsencrypt"
           export SSL_CERTS_DIR="$LETSENCRYPT_DIR/live/corekube.com"
           export LETSENCRYPT_ACME_DIR="$LETSENCRYPT_DIR/webrootauth/.well-known/acme-challenge"
           ## nginx
           export ROOT_DIR="/srv/data/prod/dest"
      ```
    * SSL/TLS certs to be used with nginx are provided via a Kubernetes Volume named `nginx-nfs-pvc`
      * The required certs are based off of the [letsencrypt.org](https://letsencrypt.org) cert directory structure in `/etc/letsencrypt/live/<DOMAIN>` and the Volume path mounted should expose the `/etc/letsencrypt` directory in its entirety. You can specify the location of the `/etc/letsencrypt` directory in your volume, in `nginx-config`.

  2.  Faciliates the ACME request that [letsencrypt.org](https://letsencrypt.org) requires when attempting to validate the Domain and renew its certs, given that:
  
    * The [letsencrypt.org](https://letsencrypt.org) directory, `/etc/letsencrypt`, is mounted via a Kubernetes Volume.

    * The nginx configuration has an alias for the ACME request as a location, in the following format, to reference the Volume where the certs are stored:

        ```
        server {
          ...
          location /.well-known/acme-challenge {
            alias {{LETSENCRYPT_ACME_DIR}};
          }
        }
        ```
  3. And lastly, serves the static HTML stored in the root directory, specified by `ROOT_DIR` in the `nginx-config` ConfigMap
