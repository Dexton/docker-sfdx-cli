#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--packageName) packageName="$2"; shift ;;
        -f|--pathFolder) pathFolder="$2"; shift ;;
        -b|--branch) branch="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

function build_package_version() {
      echo "------- BUILD PACKAGE VERSION  ----------"
      # Update all submodules if present
      git submodule update --init

      # Find the packageName and the pathFolder ( where the force-app data is stored )
      local packageName=$1
      local pathFolder=$2
      local branch=$3

      # If standardValueSets are present in the mdapi they need to be copied over
      # you can have metadata that is covered
      [ -d "./mdapi/force-app/standardValueSets" ] && cp -rf ./mdapi/force-app/standardValueSets ${pathFolder}/main/default/

      if [ "$branch" = "main" ] || [ -z "$branch" ]; then
        local cmd="sfdx force:package:version:create -p $packageName -w 100 -x --json"
      else
        local cmd="sfdx force:package:version:create -p $packageName -w 100 -x -b $branch --json"
      fi
      echo $cmd >&2
      local output=$($cmd) && (echo $output | jq '.' >&2)

      local subscriber_package_version_id=$(jq -r '.result.SubscriberPackageVersionId' <<< $output)

      if [[ -z "$subscriber_package_version_id" || $subscriber_package_version_id == null ]]; then
        echo "ERROR No subscriber package version found for package '$packageName'" >&2
        echo "------- OUTPUT  ----------"
        echo $output
        echo "------- END OUTPUT ----------"
        exit 1
      fi

      [ ! -d "./dist/" ] && mkdir ./dist/
      echo $output > ./dist/build.json
      # Send back the package version id as the output from this command
      echo $subscriber_package_version_id
      echo "------- END BUILD PACKAGE VERSION  ----------"
  }

  build_package_version $packageName $pathFolder $branch
