#!/bin/bash

target_user="netx"
if [ "$(whoami)" != "$target_user" ]; then
  echo "exec sudo -u \"$target_user\" -- \"$0\" \"$@\""
  exec sudo -u "$target_user" -- "$0" "$@"
fi

source /usr/local/nga/bin/netxdeploy/netx/netx_servers.config

if [ "$#" -lt 1 ]; then
    echo "You must specify at least one set of servers for deployment: (dev|devapp|devutil|tst|tstapp|tstutil|prod|prodapp|produtil)"
    exit 1;
fi

# cd to the proper working directory
cd /usr/local/nga/bin/netxdeploy/netx/logmonitor

for e in "$@"
do
    serverlist=${servers[${e}]};
    for server in ${serverlist}; do 
        echo "scp ./applogmonitor.config netx@$server:/usr/local/nga/etc/applogmonitor.config"
        scp ./applogmonitor.config netx@$server:/usr/local/nga/etc/applogmonitor.config
        if [ $? -ne 0 ]; then
            echo "Problem copying applogmonitor.config to $server.  Aborting";
            exit $retval
        fi
    done
done

