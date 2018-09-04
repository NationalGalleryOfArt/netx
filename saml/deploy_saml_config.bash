#!/bin/bash

target_user="netx"
if [ "$(whoami)" != "$target_user" ]; then
  echo "exec sudo -u \"$target_user\" -- \"$0\" \"$@\""
  exec sudo -u "$target_user" -- "$0" "$@"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source ${DIR}/../netx_servers.config

if [ "$#" -lt 1 ]; then
    echo "You must specify at least one set of servers for deployment: (dev|devapp|devutil|tst|tstapp|tstutil|prod|prodapp|produtil)"
    exit 1;
fi

for e in "$@"
do
    serverlist=${servers[${e}]};
    for server in ${serverlist}; do 
        echo "scp ${DIR}/samlServices.xml netx@$server:/opt/netx/netx/config/samlServices.xml"
        scp ${DIR}/samlServices.xml netx@$server:/opt/netx/netx/config/samlServices.xml
        if [ $? -ne 0 ]; then
            echo "Problem copying samlServices.xml to $server.  Aborting";
            exit $retval
        fi

        echo "scp ${DIR}/samlServices.xml netx@$server:/opt/netx/netx/config/samlServices.xml"
        scp ${DIR}/nga_token_signing_x509.cer netx@$server:/opt/netx/netx/config/nga_token_signing_x509.cer
        if [ $? -ne 0 ]; then
            echo "Problem copying nga_token_signing_x509.cer to $server.  Aborting";
            exit $retval
        fi

        echo "You are not finished.  The NetX application must be restarted on $server in order for the saml configuration to take effect.";
        read -e -p "Restart now? [y/n]: " -i "n" restartNow
        if [ $restartNow == "y" ]; then
            read -e -p "Account to use for restart (must be in sudoers): [y/n]: " -i "d-beaudet-adm" restartAccount
            stty -echo
            ssh $restartAccount@$server sudo -S systemctl restart netx
            echo "application restart requested via systemd"
            stty echo
        fi

    done
done


