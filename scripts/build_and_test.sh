#!/bin/bash
function build_and_test() {
    echo "----- BUILD AND TEST -----"

    # Check submodules if any
    git submodule update --init

    # Create the Scratch Org, install the dependant packages, push the scratch org and assign the Admin permission
    sfdx scratcher:create -d 1

    # Make directory to output test results
    # https://gitlab.com/help/ci/yaml/README.md#artifactsreports
    [ ! -d "./tests/apex/" ] && mkdir -p ./tests/apex
    [ ! -d "./dist/" ] && mkdir -p ./dist/

    # Save the output to an artifact
    local cmd="sfdx force:config:get defaultusername --json" && (echo $cmd >&2)
    local output=$($cmd) && (echo $output | jq '.' >&2)

    # Output the Scratch Org Name
    local scratch_org_username=$(jq -r '.result[0].value' <<< $output)
    echo $scratch_org_username > ./dist/username.txt

    # Run the Apex Test, output JUnit and output to ./tests/apex, wait for max 60 minutes
    sfdx force:apex:test:run -c -r junit -d ./tests/apex -w 60
    echo "----- END BUILD AND TEST -----"
  }

  build_and_test