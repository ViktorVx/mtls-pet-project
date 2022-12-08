#!/bin/bash
pwd=qwerty123
rm -f db.p12
rm -f db.jks
openssl pkcs12 -export -name dbkeypair -in db.crt.pem -certfile db.crt.pem -inkey db.key.pem -passin pass:$pwd -passout pass:$pwd -out db.p12
keytool -importkeystore -srcalias dbkeypair -destalias dbkeypair -srckeystore db.p12 -srcstoretype pkcs12 -destkeystore db.jks -deststoretype JKS <<< $'qwerty123\nqwerty123\nqwerty123'

keytool -list -keystore db.jks <<< $'qwerty123'
