export VAULT_ADDR=<vault_url>
export DOMAIN=example.ru
export DOMAIN_PREF=examole-dot-ru
export VAULT_TOKEN=<vault_token>
export SUBDOMAIN=oneserver

vault login token=$VAULT_TOKEN

vault write -format=json pki_int_ca/issue/$DOMAIN_PREF-server \
    common_name="$SUBDOMAIN.$DOMAIN" \
    alt_names="$SUBDOMAIN.$DOMAIN" \
    ttl="8760h" > $SUBDOMAIN.$DOMAIN.crt.json



cat $SUBDOMAIN.$DOMAIN.crt.json | jq -r .data.certificate > out/$SUBDOMAIN.$DOMAIN.crt.pem
cat $SUBDOMAIN.$DOMAIN.crt.json | jq -r .data.issuing_ca >> out/$SUBDOMAIN.$DOMAIN.crt.pem
cat $SUBDOMAIN.$DOMAIN.crt.json | jq -r .data.private_key > out/$SUBDOMAIN.$DOMAIN.crt.key
openssl x509 -outform der -in out/$SUBDOMAIN.$DOMAIN.crt.pem -out  out/$SUBDOMAIN.$DOMAIN.crt.der


vault write pki_int_ca/tidy   safety_buffer=5s tidy_cert_store=true tidy_revocation_list=true