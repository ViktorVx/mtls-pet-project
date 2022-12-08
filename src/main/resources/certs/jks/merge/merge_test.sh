#!/bin/bash
pwd=qwerty123
keytool -importkeystore -srcalias dbkeypair -destalias dbkeypair -srckeystore db.p12 \
-srcstoretype pkcs12 -destkeystore mq.jks -deststoretype JKS <<< $'qwerty123\nqwerty123\nqwerty123'

keytool -list -keystore ../db/db.jks <<< $'qwerty123'
keytool -list -keystore ../mq/mq.jks <<< $'qwerty123'
keytool -list -keystore mq.jks <<< $'qwerty123'