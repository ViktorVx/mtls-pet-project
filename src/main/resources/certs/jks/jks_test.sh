#!/bin/bash
pwd=qwerty123
# Clear
rm *.pem
rm *.index*
rm *.serial*
# CA
touch ca.db.index
echo "1000" > ca.db.serial
openssl genrsa -aes256 -passout pass:$pwd -out ca.key.pem 4096
openssl req -key ca.key.pem -passin pass:$pwd -new -out ca.csr.pem <<< $'ru\nMO\nMoscow\nSbt\nTeam\nteam.test.org\nteam@ya.org\nqwerty123'
openssl x509 -signkey ca.key.pem -in ca.csr.pem -req -days 365 -out ca.crt.pem -passin pass:$pwd
# MQ
openssl genrsa -aes256 -passout pass:$pwd -out mq.key.pem 2048
openssl req -key mq.key.pem -passin pass:$pwd -new -out mq.csr.pem <<< $'ru\nMO\nMoscow\nSbt\nMQ\nmq.test.org\nmq@ya.org\nqwerty123'

openssl ca -config ca.conf -passin pass:$pwd -out mq.crt.pem -infiles mq.csr.pem <<< $'y\ny'
openssl verify -CAfile ca.crt.pem mq.crt.pem
# DB
openssl genrsa -aes256 -passout pass:$pwd -out db.key.pem 2048
openssl req -key db.key.pem -passin pass:$pwd -new -out db.csr.pem <<< $'ru\nMO\nMoscow\nSbt\nDB\ndb.test.org\ndb@ya.org\nqwerty123'

openssl ca -config ca.conf -passin pass:$pwd -out db.crt.pem -infiles db.csr.pem <<< $'y\ny'
openssl verify -CAfile ca.crt.pem db.crt.pem

