#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--salesforceUsername) salesforceUsername="$2"; shift ;;
        -c|--clientId) clientId="$2"; shift ;;
        -k|--serverKey) serverKey="$2"; shift ;;
        -o|--orgType) orgType="$2"; shift ;;
        -i|--instanceUrl) instanceUrl="$2"; shift;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

function authenticate() {
    local salesforce_username=$1
    local client_id=$2
    local server_key=$3
    local org_type=$4
    local instance_url=$5

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

    if [ "$org_type" = "ORG" ]; then
      sfdx force:auth:jwt:grant -u $salesforce_username -i $client_id -f server.key -s -r $instance_url
    else
      sfdx force:auth:jwt:grant -u $salesforce_username -i $client_id -f server.key -d -r $instance_url
    fi
  }

authenticate $salesforceUsername $clientId $serverKey $orgType $instanceUrl
