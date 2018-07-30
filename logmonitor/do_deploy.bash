#!/bin/bash

if [ $USER != "netx" ]; then
    echo "this script must be run as the netx user - you probably meant to run deploy_logmonitor_config.bash instead"
    exit 1;
fi

declare -A servers
servers=(
    [dev]="aws-damutildev-tts aws-damappdev-tts"
    [devapp]="aws-damappdev-tts"
    [devutil]="aws-damutildev-tts"
    [tst]="aws-damutiltst1-dm aws-damutiltst2-dm aws-damapptst1-dm aws-damapptst2-dm"
    [tstapp]="aws-damapptst1-dm aws-damapptst2-dm"
    [tstutil]="aws-damutiltst1-dm aws-damutiltst2-dm"
    [prod]="aws-damutil1-dm aws-damutil2-dm aws-damapp1-dm aws-damapp2-dm"
    [prodapp]="aws-damapp1-dm aws-damapp2-dm"
    [produtil]="aws-damutil1-dm aws-damutil2-dm"
)

if [ "$#" -lt 1 ]; then
    echo "You must specify at least one set of servers for deployment: (dev|devapp|devutil|tst|tstapp|tstutil|prod|prodapp|produtil)"
    exit 1;
fi


# cd to the proper working directory
cd /usr/local/nga/bin/netxdeploy/netx/logmonitor

for e in $@; do
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

