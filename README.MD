#### Password for all 
```shell
password=qwerty123
```
#### Root dir
```shell
/certs
```
#### Guide 
[EN] https://jamielinux.com/docs/openssl-certificate-authority/ <br/>
[RU] https://sgolubev.ru/openssl-ca/

## CA certs
Prepare folders for ca directory
```shell
mkdir ca/certs ca/crl ca/newcerts ca/private
touch ca/index.txt
touch ca/openssl.cnf
echo 1000 > ca/serial
```
Fulfill openssl.cnf file with data
```
[ ca ]
#man ca
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = ..
certs             = $dir
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/private/.rand

# The root key and root certificate.
private_key       = $dir/ca.key.pem
certificate       = $dir/ca.cert.pem

# For certificate revocation lists.
crlnumber         = $dir/crlnumber
crl               = $dir/crl/ca.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_strict

[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
# See the POLICY FORMAT section of man ca.
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ policy_loose ]
# Allow the intermediate CA to sign a more diverse range of certificates.
# See the POLICY FORMAT section of the `ca` man page.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
# Options for the `req` tool (`man req`).
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

# Extension to add when the -x509 option is used.
x509_extensions     = v3_ca

[ req_distinguished_name ]
# See https://en.wikipedia.org/wiki/Certificate_signing_request.
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
organizationName                = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

# Optionally, specify some defaults.
countryName_default             = ru
stateOrProvinceName_default     = Russia
localityName_default            = Moscow
organizationName_default       = Horns and hooves Inc
#organizationalUnitName_default  = DEV
#emailAddress_default            = victorptrv@yandex.ru

[ v3_ca ]
# Extensions for a typical CA (`man x509v3_config`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
# Extensions for a typical intermediate CA (`man x509v3_config`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
# Extensions for client certificates (`man x509v3_config`).
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ server_cert ]
# Extensions for server certificates (`man x509v3_config`).
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ crl_ext ]
# Extension for CRLs (`man x509v3_config`).
authorityKeyIdentifier=keyid:always

[ ocsp ]
# Extension for OCSP signing certificates (`man ocsp`).
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning
```
Generate CA private key
```shell
openssl genrsa -aes256 -out ca/private/ca.key.pem 4096
```
Generate CA cert
```shell
openssl req -config ca/openssl.cnf \
-key ca/private/ca.key.pem \
-new -x509 -days 7300 -sha256 -extensions v3_ca \
-out ca/ca.cert.pem
```
Check CA cert
```shell
openssl x509 -noout -text -in ca/ca.cert.pem
```

## Intermediate certs
Create folders
```shell
mkdir "ca/intermediate"
mkdir ca/intermediate/certs ca/intermediate/crl ca/intermediate/csr ca/intermediate/newcerts ca/intermediate/private
touch ca/intermediate/index.txt
echo 1000 > ca/intermediate/serial
echo 1000 > ca/intermediate/crlnumber
touch ca/intermediate/openssl.cnf
```
Copy data from ca/openssl.cnf to ca/intermediate/openssl.cnf and change
```editorconfig
[ CA_default ]
dir             = /ca/intermediate
private_key     = $dir/private/intermediate.key.pem
certificate     = $dir/certs/intermediate.cert.pem
crl             = $dir/crl/intermediate.crl.pem
policy          = policy_loose
```
Generate intermediate private key
```shell
openssl genrsa -aes256 -out ca/intermediate/private/intermediate.key.pem 4096
```
Generate CSR(certificate signing request) for intermediate cert
```shell
openssl req -config ca/intermediate/openssl.cnf -new -sha256 \
-key ca/intermediate/private/intermediate.key.pem -out ca/intermediate/csr/intermediate.csr.pem
```
Generate intermediate cert signed by root CA
```shell
openssl ca -config ca/openssl.cnf -extensions v3_intermediate_ca \
-days 3650 -notext -md sha256 \
-in ca/intermediate/csr/intermediate.csr.pem \
-out ca/intermediate/intermediate.cert.pem
```
Check intermediate cert
```shell
openssl x509 -noout -text -in ca/intermediate/intermediate.cert.pem
```
Check intermediate cert with root CA
```shell
openssl verify -CAfile ca/ca.cert.pem ca/intermediate/intermediate.cert.pem
```
## Certificates chain
Create cert chain with root CA and intermediate
```shell
cat ca/intermediate/intermediate.cert.pem ca/ca.cert.pem > ca/intermediate/certs/intermediate-ca-chain.cert.pem
```
## Generate certs for clients (nodes)
Generate private key
```shell
openssl genrsa -aes256 -out nodes/node0/node0.key.pem 2048
```
### Server certs
Generate server cert CSR
```shell
openssl req -config ca/intermediate/openssl.cnf \
-key nodes/node0/node0.key.pem \
-new -sha256 -out nodes/node0/node0.server.csr.pem
```
Create and sign server cert
```shell
openssl ca -config ca/intermediate/openssl.cnf \
-extensions server_cert -days 375 -notext -md sha256 \
-in nodes/node0/node0.server.csr.pem \
-out nodes/node0/node0.server.cert.pem
```
Check cert
```shell
openssl x509 -noout -text -in nodes/node0/node0.server.cert.pem
```
Check certs with chain
```shell
openssl verify -CAfile ca/intermediate/certs/intermediate-ca-chain.cert.pem \
nodes/node0/node0.server.cert.pem
```
### Client certs
Generate client cert CSR
```shell
openssl req -config ca/intermediate/openssl.cnf \
-key nodes/node0/node0.key.pem \
-new -sha256 -out nodes/node0/node0.client.csr.pem
```
Create and sign client cert
```shell
openssl ca -config ca/intermediate/openssl.cnf \
-extensions usr_cert -days 375 -notext -md sha256 \
-in nodes/node0/node0.client.csr.pem \
-out nodes/node0/node0.client.cert.pem
```
Check cert
```shell
openssl x509 -noout -text -in nodes/node0/node0.client.cert.pem
```
Check certs with chain
```shell
openssl verify -CAfile ca/intermediate/certs/intermediate-ca-chain.cert.pem \
nodes/node0/node0.client.cert.pem
```