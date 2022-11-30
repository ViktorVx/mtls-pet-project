## Password for all 
```shell
password=qwerty123
```
## CA certs
Generate CA private key
```shell
openssl genrsa -aes256 -out ca.key.pem 4096
```
Generate CA cert
```shell
openssl req -config openssl.cnf \
-key ca.key.pem \
-new -x509 -days 7300 -sha256 -extensions v3_ca \
-out ca.cert.pem
```
Check CA cert
```shell
openssl x509 -noout -text -in ca.cert.pem
```

## Intermediate certs
Create crlnumber file for invalid certs
```shell
echo 1000 > crlnumber
```
Generate intermediate private key
```shell
openssl genrsa -aes256 -out intermediate00.key.pem 4096
```
Generate CSR(certificate signing request) for intermediate cert
```shell
openssl req -config openssl.cnf -new -sha256 \
-key intermediate00.key.pem -out intermediate00.csr.pem
```
Generate intermediate cert signed by root CA
```shell
openssl ca -config ../openssl.cnf -extensions v3_intermediate_ca \
-days 3650 -notext -md sha256 \
-in intermediate00.csr.pem \
-out intermediate00.cert.pem
```