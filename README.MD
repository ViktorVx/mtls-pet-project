## Password for all 
```shell
password=qwerty123
```
## CA certs
Generate CA encrypted private key
```shell
openssl genrsa -des3 -out kamaok.org.ua.key 2048
```
Generate CA cert/public key 
```shell
openssl req -x509 -new -nodes -key ca.key -sha256 -days 8000 -out ca.crt
```