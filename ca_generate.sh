export VAULT_ADDR=<vault_url>
export DOMAIN=example.ru
export DOMAIN_PREF=examole-dot-ru
export VAULT_TOKEN=<vault_token>

vault login token=$VAULT_TOKEN


mkdir -p clients
mkdir -p out
vault secrets enable \
    -path=pki_root_ca \
    -description="PKI Root CA $DOMAIN" \
    -max-lease-ttl="262800h" \
    pki

vault write -format=json pki_root_ca/root/generate/internal \
    common_name="$DOMAIN Root Certificate Authority" \
    country="Russian Federation" \
    locality="RnD" \
    street_address="Red Square 1" \
    postal_code="101000" \
    organization="$DOMAIN LLC" \
    ou="IT" \
    ttl="262800h" > pki-root-ca.json

cat pki-root-ca.json | jq -r .data.certificate > rootCA.pem

vault write pki_root_ca/config/urls \
    issuing_certificates="$VAULT_ADDR/v1/pki_root_ca/ca" \
    crl_distribution_points="$VAULT_ADDR/v1/pki_root_ca/crl"


vault secrets enable \
    -path=pki_int_ca \
    -description="PKI Intermediate CA $DOMAIN" \
    -max-lease-ttl="175200h" \
    pki

vault write -format=json pki_int_ca/intermediate/generate/internal \
   common_name="Intermediate CA $DOMAIN" \
   country="Russian Federation" \
   locality="RnD" \
   street_address="Red Square 1" \
   postal_code="101000" \
   organization="$DOMAIN LLC" \
   ou="IT" \
   ttl="175200h" | jq -r '.data.csr' > pki_intermediate_ca.csr


vault write -format=json pki_root_ca/root/sign-intermediate csr=@pki_intermediate_ca.csr \
   country="Russia Federation" \
   locality="RnD" \
   street_address="Red Square 1" \
   postal_code="101000" \
   organization="$DOMAIN LLC" \
   ou="IT" \
   format=pem_bundle \
   ttl="175200h" | jq -r '.data.certificate' > intermediateCA.cert.pem

vault write pki_int_ca/intermediate/set-signed \
    certificate=@intermediateCA.cert.pem

vault write pki_int_ca/config/urls \
    issuing_certificates="$VAULT_ADDR/v1/pki_int_ca/ca" \
    crl_distribution_points="$VAULT_ADDR/v1/pki_int_ca/crl"

vault write pki_int_ca/roles/$DOMAIN_PREF-server \
    country="Russia Federation" \
    locality="RnD" \
    street_address="Red Square 1" \
    postal_code="101000" \
    organization="$DOMAIN LLC" \
    ou="IT" \
    allowed_domains="$DOMAIN" \
    allow_subdomains=true \
    max_ttl="87600h" \
    key_bits="2048" \
    key_type="rsa" \
    allow_any_name=false \
    allow_bare_domains=false \
    allow_glob_domain=false \
    allow_ip_sans=true \
    allow_localhost=false \
    client_flag=false \
    server_flag=true \
    enforce_hostnames=true \
    key_usage="DigitalSignature,KeyEncipherment" \
    ext_key_usage="ServerAuth" \
    require_cn=true


vault write pki_int_ca/roles/$DOMAIN_PREF-client \
    country="Russia Federation" \
    locality="RnD" \
    street_address="Red Square 1" \
    postal_code="101000" \
    organization="$DOMAIN LLC" \
    ou="IT" \
    allow_subdomains=true \
    max_ttl="87600h" \
    key_bits="2048" \
    key_type="rsa" \
    allow_any_name=true \
    allow_bare_domains=false \
    allow_glob_domain=false \
    allow_ip_sans=false \
    allow_localhost=false \
    client_flag=true \
    server_flag=false \
    enforce_hostnames=false \
    key_usage="DigitalSignature" \
    ext_key_usage="ClientAuth" \
    require_cn=true


# vault write pki_int_ca/tidy   safety_buffer=5s tidy_cert_store=true tidy_revocation_list=true