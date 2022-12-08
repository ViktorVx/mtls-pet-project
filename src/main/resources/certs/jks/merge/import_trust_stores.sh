#!/bin/bash
pwd=qwerty123

keytool -delete -noprompt -alias mqTrustStore -keystore mq.jks -storepass $pwd
keytool -delete -noprompt -alias dbTrustStore -keystore mq.jks -storepass $pwd

keytool -keystore mq.jks -importcert -alias mqTrustStore -file ca.crt.pem -storepass $pwd <<< $'y'
keytool -keystore mq.jks -importcert -alias dbTrustStore -file ca.crt.pem -storepass $pwd <<< $'y'

keytool -list -keystore mq.jks -storepass $pwd