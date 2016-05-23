# nginx

[![wercker status](https://app.wercker.com/status/21a779b13c0e2bd3e67bc0e4c17ded36/m "wercker status")](https://app.wercker.com/project/bykey/21a779b13c0e2bd3e67bc0e4c17ded36)

A nginx Docker container that is deployed on Kubernetes to serve local, static content over HTTPS using [letsencrypt.org](https://letsencrypt.org) certificates.

This nginx webserver:

  1. Configures nginx according to settings outlined in a ConfigMap named `nginx-config` (included in code):
    * Configuration settings to be used in nginx are provided via a Kubernetes ConfigMap named `nginx-config`, defined as such as:

      ```
       apiVersion: v1
       kind: ConfigMap
       metadata:
         name: nginx-config
       data:
         server.name: "corekube.com"
         enable.ssl: "true"
      ```
    * Configures nginx's SSL/TLS certs according to settings outlined in a ConfigMap named `ssl-secret` (not included in code)
      * The required certs are based off of the [letsencrypt.org](https://letsencrypt.org) cert directory structure in `/etc/letsencrypt/live/<DOMAIN>` and are expected to be defined in `ssl-secret` as such:
  
        ```
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: ssl-secret
        data:
          fullchain.pem: |
            <FULLCHAIN>
          cert.pem: |
            <CERT>
          privkey.pem: |
            <PRIVKEY>
          dhparams.pem: |
            <DHPARAMS>
          chain.pem: |
            <CHAIN>
        ```
  2.  Faciliates the ACME request that [letsencrypt.org](https://letsencrypt.org) requires when attempting to validate the Domain and renew its certs, given that:
  
    * The [letsencrypt.org](https://letsencrypt.org) directory, `/etc/letsencrypt`, is mounted in `/srv/` as `/srv/etc/letsencrypt`.

      * In this particular case, we're accessing an NFS server provided by a Kubernetes Volume named `nginx-nfs-pvc`, but this setup is not strictly required
    * The nginx configuration has an alias for the ACME request, in the following format, to utilize the `/srv/etc/letsencrypt` directory when a renewal is requested:

        ```
        server {
          ...
          location /.well-known/acme-challenge {
            alias /srv/etc/letsencrypt/webrootauth/.well-known/acme-challenge;
          }
        }
        ```
  3. And lastly, serves the static HTML stored in the root directory, specified by `root.dir` in the `nginx-config` ConfigMap
