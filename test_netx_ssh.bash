#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source ${DIR}/netx_servers.config

if [ "$#" -lt 1 ]; then
    echo "You must specify at least one set of servers for SSH testing: (dev|devapp|devutil|test|testapp|testutil|prod|prodapp|produtil)"
    exit 1;
fi

echo "Testing SSH connectivity as netx user..."

# Get the actual user (not root if using sudo)
if [ -n "$SUDO_USER" ]; then
    current_user="$SUDO_USER"
else
    current_user=$(whoami)
fi

for e in "$@"
do
    serverlist=${servers[${e}]};
    echo "Testing environment: $e"
    for server in ${serverlist}; do 
        echo -n "Testing netx@$server... "
        
        # Test SSH connection as netx user with a simple command
        sudo -u netx ssh -o ConnectTimeout=10 -o BatchMode=yes netx@$server "hostname" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "SUCCESS"
        else
            echo "FAILED"
        fi
    done
done

echo "SSH connectivity test complete"