export VAULT_ADDR=<vault_url>
export DOMAIN=example.ru
export DOMAIN_PREF=examole-dot-ru
export VAULT_TOKEN=<token>
export SUBDOMAIN=client1

vault login token=$VAULT_TOKEN

vault write -format=json pki_int_ca/issue/$DOMAIN_PREF-client \
    common_name="$SUBDOMAIN.$DOMAIN" \
    alt_names="$SUBDOMAIN.$DOMAIN" \
    ttl="8760h" > $SUBDOMAIN.$DOMAIN.crt.json



cat $SUBDOMAIN.$DOMAIN.crt.json | jq -r .data.certificate > clients/$SUBDOMAIN.$DOMAIN.crt.pem
cat $SUBDOMAIN.$DOMAIN.crt.json | jq -r .data.issuing_ca >> clients/$SUBDOMAIN.$DOMAIN.crt.pem
cat $SUBDOMAIN.$DOMAIN.crt.json | jq -r .data.private_key > clients/$SUBDOMAIN.$DOMAIN.crt.key
openssl x509 -outform der -in clients/$SUBDOMAIN.$DOMAIN.crt.pem -out  clients/$SUBDOMAIN.$DOMAIN.crt.der

openssl pkcs12 -export -out clients/$SUBDOMAIN.$DOMAIN.crt.p12 -in clients/$SUBDOMAIN.$DOMAIN.crt.pem -inkey clients/$SUBDOMAIN.$DOMAIN.crt.key -passin pass:root -passout pass:root

