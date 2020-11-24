#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u|--username) currentUsername="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

function delete_scratch_orgs() {
    echo 'Delete the org'
    local currentUsername=$1
    local cmd="sfdx force:data:record:delete -u $1  --sobjecttype ScratchOrgInfo --where "'"SignupUsername='$currentUsername'"'" --json" && (echo $cmd >&2)
    local output=$($cmd) && (echo $output | jq '.' >&2)
    echo 'Done deleting the Org'
}
delete_scratch_orgs $currentUsername