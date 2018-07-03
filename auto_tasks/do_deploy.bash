#!/bin/bash

if [ $USER != "netx" ]; then
    echo "this script must be run as the netx user - you probably meant to run deploy_tms_data_configs.bash instead"
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
cd /usr/local/nga/bin/netxdeploy/netx/auto_tasks

# read secrets
source /usr/local/nga/etc/tmsprivateextract.conf
source /usr/local/nga/etc/netxapi.conf

credentials_json="[\"${netx_api_username}\", \"${netx_api_password}\"]"

header_json=`cat api_header.json`
header_json="${header_json/_method_/authenticate}"
header_json="${header_json/_params_/${credentials_json}}"

datasync=`cat syncedMetadata.xml`

# replace template with our secrets
datasync="${datasync/tmsprivateextract_username/${tmsprivateextract_username}}"
datasync="${datasync/tmsprivateextract_password/${tmsprivateextract_password}}"

mkdir -p target

# copy the NetX API header json to the target folder
echo "${header_json}" > ./target/auth.json

# create the master metadatasync file that will be deployed to all servers
echo "$datasync" > ./target/syncedMetadata.xml

for e in $@; do
    serverlist=${servers[${e}]};
    for server in ${serverlist}; do 
        #echo $server
        echo "scp ./target/syncedMetadata.xml netx@$server:/opt/netx/netx/config/"
        scp ./target/syncedMetadata.xml netx@$server:/opt/netx/netx/config/
        if [ $? -ne 0 ]; then
            echo "Problem copying syncedMetadata.xml to $server.  Aborting";
            exit $retval
        fi

        authresponse=`curl -s -i -D /dev/null -X POST "http://${server}:8080/x7/v1.2/json/" -H "Content-Type: text/json" --data-binary "@./target/auth.json" -o -`
        #echo $authresponse
        if [[ $authresponse =~ result\":\" ]]; then
            authresponse=`echo ${authresponse} | sed 's/\(.*\)result":"\([^"]*\)"\(.*\)/\2/'`
        else
            authresponse=""
        fi

        if [ $authresponse == "" ]; then
            echo "Could not authenticate to NetX on $server. Aborting..."
            exit 1;
        fi

        sessionid=$authresponse;

        header_json=`cat api_header.json`
        header_json="${header_json/_method_/setAutoTask}"
        for task in ./tasks-to-deploy/*.xml; do
            autotask_json=`cat ${task} | jq '.' -R --slurp`
            task_json="[\"${sessionid}\", ${autotask_json}]"
            #echo TASK:$task_json
            setautotask_json="${header_json/_params_/${task_json}}"
            fname=`echo "$task" | sed "s/.*\///"`
            echo "${setautotask_json}" > ./target/${fname}.json
            authresponse=`curl -s -i -D /dev/null -X POST "http://${server}:8080/x7/v1.2/json/" -H "Content-Type: text/json" --data-binary "@./target/${fname}.json" -o -`
            #echo $authresponse
            if [[ $authresponse =~ result\":true ]]; then
                echo "Deployed autotask $task successfully"
            else
                echo "Problem deploying autotask to server";
                exit 1;
            fi
        done
    done
done

# finally, remove all contents in the target folder (working directory)
\rm -r target
