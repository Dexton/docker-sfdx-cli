#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -o|--orgType) orgType="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

function set_username() {
    local $org_type=$1
    echo "----- BEGIN defaultusername -----"
    if [ "$org_type" = "ORG" ]; then
        local instanceUrl=$(cat dist/org.json | jq -r '.result.instanceUrl')
        local accessToken=$(cat dist/org.json | jq -r '.result.accessToken')
        local property_to_set=defaultusername
    else
        local instanceUrl=$(cat dist/devhub.json | jq -r '.result.instanceUrl')
        local accessToken=$(cat dist/devhub.json | jq -r '.result.accessToken')
        local property_to_set=defaultdevhubusername
    fi
    
    sfdx config:set instanceUrl=$instanceUrl

    local cmd="sfdx force:config:set ${property_to_set}=${property_to_set} --json" && (echo $cmd >&2)
    local output=$($cmd) && (echo $output | jq '.' >&2)

    echo "----- END defaultusername -----"
  }

  set_username $orgType