#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source ${DIR}/netx_servers.config

# Use netx user's SSH key
netx_home=$(getent passwd netx | cut -d: -f6)
public_key_file="$netx_home/.ssh/id_rsa.pub"
if ! sudo test -f "$public_key_file"; then
    echo "Public key file not found: $public_key_file"
    echo "Please ensure your SSH key pair has been generated"
    exit 1
fi

if [ "$#" -lt 1 ]; then
    echo "You must specify at least one set of servers for key distribution: (dev|devapp|devutil|test|testapp|testutil|prod|prodapp|produtil)"
    exit 1;
fi

echo "Distributing SSH public key from: $public_key_file"

# Get the actual user (not root if using sudo)
if [ -n "$SUDO_USER" ]; then
    current_user="$SUDO_USER"
else
    current_user=$(whoami)
fi

for e in "$@"
do
    serverlist=${servers[${e}]};
    echo "Distributing to environment: $e"
    for server in ${serverlist}; do 
        echo "Installing public key on $server as netx user"
        
        # SSH in as current user, then use sudo to install the key for netx
        ssh -t "$current_user@$server" "sudo mkdir -p ~netx/.ssh && sudo chmod 700 ~netx/.ssh && echo '$(sudo cat $public_key_file)' | sudo tee -a ~netx/.ssh/authorized_keys > /dev/null && sudo chmod 600 ~netx/.ssh/authorized_keys && sudo chown -R netx:netx ~netx/.ssh"
        
        if [ $? -ne 0 ]; then
            echo "Problem installing SSH key on $server. Continuing with next server...";
        else
            echo "Successfully installed SSH key on $server"
        fi
    done
done

echo "SSH key distribution complete"