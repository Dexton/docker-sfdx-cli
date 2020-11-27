#!/bin/bash
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u|--salesforceUsername) SALESFORCE_USERNAME="$2"; shift ;;
        -u|--packageVersionId) PACKAGE_VERSION_ID="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

function install_package_version() {
    local salesforce_username=$1
    local package_version_id=$2

    echo "package_version_id=$package_version_id" >&2
    echo "salesforce_username=$salesforce_username" >&2

    if [ ! $salesforce_username ]; then
      echo "ERROR No salesforce_username provided in the environment variables, can't continue" >&2
      exit 1;
    fi

    if [[ -z "$package_version_id" || $package_version_id == null ]]; then
      echo "ERROR No package version id provided to 'install_package_version' function" >&2
      exit 1
    fi

    # install the package
    local cmd="sfdx force:package:install -u $salesforce_username --package $package_version_id --wait 60 --publishwait 10 -r -s AllUsers --noprompt --json" && (echo $cmd >&2)
    local output=$($cmd) && (echo $output | jq '.' >&2)

    # assert no error response
    local exit_code=$(jq -r '.exitCode' <<< $output) && (echo $exit_code >&2)
    if [[ ( -n "$exit_code" ) && ( $exit_code -gt 0 ) ]]; then
      exit 1
    fi

}

install_package_version $SALESFORCE_USERNAME $PACKAGE_VERSION_ID