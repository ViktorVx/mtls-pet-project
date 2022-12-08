#!/bin/bash
pwd=qwerty123
rm -f mq.p12
rm -f mq.jks
openssl pkcs12 -export -name mqkeypair -in mq.crt.pem -certfile mq.crt.pem -inkey mq.key.pem -passin pass:$pwd -passout pass:$pwd -out mq.p12
keytool -importkeystore -srcalias mqkeypair -destalias mqkeypair -srckeystore mq.p12 -srcstoretype pkcs12 -destkeystore mq.jks -deststoretype JKS <<< $'qwerty123\nqwerty123\nqwerty123'

keytool -list -keystore mq.jks <<< $'qwerty123'
