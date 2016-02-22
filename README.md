# nginx

A nginx Docker image that is deployed on Kubernetes to serve static content over HTTPS using [letsencrypt.org](https://letsencrypt.org) certificates.

This nginx webserver:

  1. Allows the enablement of SSL/TLS, given that:
    * Configuration settings to be used in nginx are provided via a Kubernetes Secret named `nginx-config-secret`, defined as such as:

      ```
       apiVersion: v1
       kind: Secret
       metadata:
         name: nginx-config-secret
         namespace: nginx-<NAMESPACE>
       type: Opaque
       data:
         env: <CONFIG_BASE64>
      ```
      where the embedded config data is:
      
      ```
      export SERVER_NAME=example.com
      export ENABLE_SSL=true
      ```
    * All the necessary SSL/TLS certs be provided via a Kubernetes Secret named `nginx-ssl-secret`
      * The required certs are based off of the [letsencrypt.org](https://letsencrypt.org) cert directory structure in `/etc/letsencrypt/live/<DOMAIN>` and are expected to be defined in `nginx-ssl-secret` as such:
  
        ```
        apiVersion: v1
        kind: Secret
        metadata:
          name: nginx-ssl-secret
          namespace: nginx-<NAMESPACE>
        type: Opaque
        data:
          fullchain.pem: <FULLCHAIN_BASE64>
          cert.pem: <CERT_BASE64>
          privkey.pem: <PRIVKEY_BASE64>
          dhparams.pem: <DHPARAMS_BASE64>
          chain.pem: <CHAIN_BASE64>
        ```
  2.  Faciliates the ACME request that [letsencrypt.org](https://letsencrypt.org) needs when attempting to validate the Domain and renew its certs, given that:
  
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
