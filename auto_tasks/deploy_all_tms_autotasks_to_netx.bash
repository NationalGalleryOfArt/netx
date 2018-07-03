#!/bin/bash

# switch to the netx user first
sudo su - netx -c "/usr/local/nga/bin/netxdeploy/netx/auto_tasks/do_deploy.bash $@"

