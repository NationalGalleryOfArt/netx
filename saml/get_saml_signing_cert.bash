#!/bin/bash
curl -s -o /tmp/adfs_saml.xml "https://adfs.nga.gov/FederationMetadata/2007-06/FederationMetadata.xml"
/bin/echo -----BEGIN CERTIFICATE-----
xmllint --format /tmp/adfs_saml.xml | grep "<X509Certificate" | head -1 | cut -d '>' -f 2 | cut -d '<' -f 1 | fold -w 64
/bin/echo -----END CERTIFICATE-----

#/usr/bin/curl -s -o - "https://adfs.nga.gov/FederationMetadata/2007-06/FederationMetadata.xml" | /usr/bin/xmllint -format /tmp/adfs_saml.xml  | /bin/grep "<X509Certificate" | /usr/bin/head -1 | /bin/cut -d '>' -f 2 | /bin/cut -d '<' -f 1 | /usr/bin/fold -w 64
