#!/bin/bash

cd /home/netx/netx/saml
./get_saml_signing_cert.bash > /tmp/current_test.cert
res=`/usr/bin/diff -q last_signing.cert /tmp/current_test.cert`

if [ $? != 0 ]; then
    /bin/echo "NGA's STS SAML Signing Cert seems to have changed" | /bin/mail -s "Alert: SAML Signing Cert Change Detected" linuxpostmaster@nga.gov
fi
