#!/bin/bash
IP=$(ip route get 8.8.8.8 | awk -F'src ' 'NR==1 { split($2,a," "); print a[1] }')
KEY="`dirname $0`/`dnsdomainname -s`.key"
CSR="`dirname $0`/`dnsdomainname -s`.csr"

SAN=$(if [ `dnsdomainname -d` ]; then echo -n "DNS:`dnsdomainname -f`,DNS:`dnsdomainname -s`"; else echo -n "DNS:`dnsdomainname -f`"; fi)
SAN="${SAN},IP:$IP"
#SAN="${SAN}$(for I in `dnsdomainname -i |grep -oE '([0-9]{1,3}[\.]){3}[0-9]{1,3}' |sort |uniq`; do echo -n ",IP:$I"; done)"

REQ_V3="
[ req ]
default_bits          = 2048
encrypt_key           = no
default_md            = sha384
distinguished_name    = req_dn
req_extensions        = req_v3

[ req_dn ]

[ req_v3 ]
keyUsage              = critical, digitalSignature, keyEncipherment
extendedKeyUsage      = serverAuth
subjectKeyIdentifier  = hash
subjectAltName        = ${SAN}
"

openssl req -config <(echo "$REQ_V3") -new -keyout $KEY -out $CSR -subj "/C=CZ/O=Example a.s./OU=IT/OU=Cockpit/CN=`dnsdomainname -s`"
openssl req -text -noout -in $CSR

unset IP
unset SAN
unset KEY
unset CSR
