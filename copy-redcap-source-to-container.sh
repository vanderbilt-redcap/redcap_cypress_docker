#!/usr/bin/env bash

redcapSourcePath=`realpath "$1"`

# Make the script directory the working directory if it is called from elsewhere
cd `dirname -- "$0"`

expectedREDCapVersion='v99.99.99'
cypressBranch=`git -C redcap_cypress branch --show-current`
if [[ $cypressBranch != 'dev' ]]; then
  echo This script is only allow when the 'dev' branch is checked out for redcap_cypress.
  echo This is because we only want to allow modified REDCap\'s source for the version $expectedREDCapVersion,
  echo so that results for specific versions are always consistent.
  exit
elif ! test -f "$redcapSourcePath/Classes/REDCap.php"; then
  echo Please specify the path to the REDCap source directory whose contents you would like to copy to the cypress docker container.
  exit
fi

docker cp $redcapSourcePath/. redcap_docker-app-1:/var/www/html/redcap_$expectedREDCapVersion