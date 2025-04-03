#!/bin/sh

# The following line is important to ensure this script stops if this repo or submodules have oustanding changes that would prevent a git pull.
set -e

getUpdateScriptInfo () {
  ls -l update.sh
}

oldUpdateScriptInfo=`getUpdateScriptInfo`

git checkout main > /dev/null
git pull --recurse-submodules

if [ "$oldUpdateScriptInfo" != "`getUpdateScriptInfo`" ]; then
    echo A changed to update.sh was detected.  Restarting this script...
    ./update.sh
    exit
fi

cd redcap_cypress/redcap_rsvc
git fetch https://github.com/vanderbilt-redcap/redcap_rsvc staging
rsvcBranchName=`git rev-parse --abbrev-ref HEAD`
if [ "$rsvcBranchName" = "staging" ] || [ "$rsvcBranchName" = "main" ]; then
    # Developers shouldn't be working directly these branches.
    # This may be an initial run before any development has started.
    # Regardless, just checkout the latest
    git -c advice.detachedHead=false checkout FETCH_HEAD > /dev/null
else
    commitsBehindStaging=`git log --oneline ..FETCH_HEAD | wc -l`
    if [ $commitsBehindStaging != 0 ]; then
        echo
        echo Please merge the latest from the 'staging' branch into your redcap_rsvc branch.
        echo This is not performed automatically to avoid interfering with any active development. 
        exit
    fi
fi
cd ../..

cd redcap_docker
docker compose down # This ensures a running container is restarted, which can fix various docker issues.
docker compose up -d --build # This ensures the container is rebuilt to include any Dockerfile changes, other updates, or fix various issues.
