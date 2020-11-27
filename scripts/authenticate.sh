#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -o|--orgType) orgType="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

function authenticate() {
    [ ! -d "./dist/" ] && mkdir ./dist/

    if [ "$org_type" = "ORG" ]; then
      local SF_USERNAME=SF_${BITBUCKET_BRANCH^^}_USERNAME
      local SF_CLIENT=SF_${BITBUCKET_BRANCH^^}_CLIENTID
      local SF_INSTANCE=SF_${BITBUCKET_BRANCH^^}_INSTANCEURL
      local ORG_NAME=org
    else
      local SF_USERNAME=SF_DEVHUB_USERNAME
      local SF_CLIENT=SF_DEVHUB_CLIENTID
      local SF_INSTANCE=SF_DEVHUB_INSTANCEURL
      local ORG_NAME=devhub
    fi
  
    local salesforce_username=${!SF_USERNAME}
    local client_id=${!SF_CLIENT}
    local server_key=$SF_SERVERKEY
    local org_type=$1
    local instance_url=$SF_INSTANCE

    if [ ! $salesforce_username ]; then
      echo "ERROR No SF_USERNAME provided in the environment variables, can't continue" >&2
      exit 1;
    fi

    if [ ! $client_id ]; then
      echo "ERROR No CLIENT_ID provided in the environment variables, can't continue" >&2
      exit 1;
    fi

    if [ ! $server_key ]; then
      echo "ERROR No SERVER_KEY provided in the environment variables, can't continue" >&2
      exit 1;
    fi

    if [[ ${instance_url} != *"https"* ]];then
        instance_url="https://login.salesforce.com"
    fi

    echo "salesforce_username=$salesforce_username" >&2
    echo "client_id=$client_id" >&2
    echo "server_key=$server_key" >&2
    echo "org_type=$org_type" >&2
    echo "instance_url=$instance_url" >&2

    # Take the ServerKey from environment, decrypt the base64 nad put it into the Key
    (umask  077 ; echo $server_key | base64 -d > server.key)
      
    local cmd="sfdx force:auth:jwt:grant -u $salesforce_username -i $client_id -f server.key -s -r $instance_url -a $ORG_NAME" && (echo $cmd >&2)
    local output=$($cmd) && (echo $output >&2)
    sfdx force:org:display -u ${ORG_NAME} --json > dist/${ORG_NAME}.json

    local exit_code=$(cat dist/${ORG_NAME}.json | jq -r '.exitCode') && (echo $exit_code >&2)
    if [[ ( -n "$exit_code" ) && ( $exit_code -gt 0 ) ]]; then
      echo "ERROR KILLING MYSELF"
      exit 1
    fi

  }

authenticate $orgType
