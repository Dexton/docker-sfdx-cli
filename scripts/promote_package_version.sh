#!/bin/bash
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--packageId) packageId="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

function promote_package_version() {
    local SFDX_PACKAGE_ID=$1
        
    # No prompt promote if we are on the master
    sfdx force:package:version:promote -p $SFDX_PACKAGE_ID -n 
            
    local package_version_id=$2
    echo "package_version_id=$package_version_id" >&2
    local cmd="sfdx force:package:version:promote --package $package_version_id --noprompt --json" && (echo $cmd >&2)
    local output=$($cmd) && (echo $output | jq '.' >&2)
}

promote_package_version $packageId