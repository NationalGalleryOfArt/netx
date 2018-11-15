#!/bin/bash

/bin/echo -----BEGIN CERTIFICATE-----
/usr/bin/curl -s -o - "https://sts.nga.gov/FederationMetadata/2007-06/FederationMetadata.xml" | /usr/bin/xmllint -format /tmp/adfs_saml.xml  | /bin/grep "<X509Certificate" | /usr/bin/head -1 | /bin/cut -d '>' -f 2 | /bin/cut -d '<' -f 1 | /usr/bin/fold -w 64
/bin/echo -----END CERTIFICATE-----
