# generate PKI vault hashicorp
each script fix:
- vault address like `https://vault.example.com:443`
- vault token like your root token ) 
- domain

### generate ca and Intermediate 
- `bash ./ca_generate.sh`

### run your neded script 

- `bash ./cert-server.sh`
- `bash ./cert-client.sh`

## nginx 
- for use tls  auth  use config `nginx.exempe.conf`


##### PPS
this pki also you can use for k8s certmanager 