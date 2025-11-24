#!/usr/bin/env bash

set -e

if [ ! -d "redcap_cypress" ]; then
    git clone git@github.com:vanderbilt-redcap/redcap_cypress.git
    git clone git@github.com:vanderbilt-redcap/redcap_docker.git

    #Move Base Configurations for Cypress
    cp ./redcap_cypress/cypress.config.js.example ./redcap_cypress/cypress.config.js
    awk '{ gsub(/"temp_folder": ".*",/, "\"temp_folder\": \"/var/www/html/temp\","); print }' ./redcap_cypress/cypress.env.json.example > ./redcap_cypress/cypress.env.json

    #Install the REDCap RSVC repository so automated feature tests can run
    cd redcap_cypress
    git clone git@github.com:vanderbilt-redcap/redcap_rsvc.git
    cd ..
fi

redcapVersion=`cat redcap_cypress/.circleci/config.yml |grep 'REDCAP_VERSION:'|cut -d'"' -f 2`
if [ ! -d "redcap_source/redcap_v$redcapVersion" ]; then
    echo "The version of REDCap used for testing has changed.  The new version must be downloaded."
    ./download_redcap.sh $redcapVersion
fi

# Ensure the correct version of REDCap is used even if we're switching back and forth between redcap_cypress branches.
awk '{ gsub(/"redcap_version": ".*",/, "\"redcap_version\": \"'$redcapVersion'\","); print }' redcap_cypress/cypress.env.json > awk-temp && mv awk-temp redcap_cypress/cypress.env.json

cd redcap_docker
docker compose up -d
cd ..

saveCoveragePath=redcap_source/save-code-coverage.php
if [ ! -e $saveCoveragePath ]; then
    # PHP will crash if this file doesn't exist due to the auto_prepend_file INI directive
    touch $saveCoveragePath
fi

htmlDirLineCount=`cat redcap_docker/docker-compose.yml | grep 'redcap_source/:/var/www/html' | awk '{$1=$1;print}' | grep -v '^#' | wc -l`
if [ $htmlDirLineCount = 0 ]; then
    # Reaching this point means the redcap_source dir is not being mounted in the container via the volumes section
    # of docker-compose.yml, and should be copied into the container instead.
    # We used to mount the redcap_source dir as a docker volume,
    # but this made many features take roughly 3 times as long on Windows,
    # due to cross filesystem performance limitations and Microsoft Defender on the fly scans.

    cd redcap_source

    if docker exec redcap_docker-app-1 test -d redcap_v$redcapVersion; then
        # No need to copy if the current redcap version is already there
        echo
    else
        # This could be an initial run or a newly added redcap version.
        echo Copying new REDCap version directories into the docker container...
        
        # This command copies the current redcap_v* dir and ever other file under redcap_source except other redcap_v* dirs.
        ls -1| grep -v redcap_v | cat - <(echo redcap_v$redcapVersion) | grep -v external_modules | xargs -I {} docker cp "{}" redcap_docker-app-1:/var/www/html

        # We used to use chown here, but that broke when we switched to a different docker base image.
        # Changing the permissions to 777 should work regardless of any future base image changes
        docker exec redcap_docker-app-1 chmod 777 temp edocs
    fi
    
    cd ..
fi

cd redcap_cypress
# We add the "--no" arguments to simplify output for less technical users.
# We don't really care about vulnerabilities since we're not hosting this project
npm install --no-fund --no-audit 
npm explore rctf -- npm run generate:hints

rctfPath="../../rctf/"
if [ -d "$rctfPath" ]; then
    npm link $rctfPath
fi

# Ideally we'd call "npm run redcap_rsvc:move_files" here instead of the following lines,
# but we can't do that currently because "redcap_rsvc:move_files" contains
# a "move-cli node_modules/redcap_rsvc redcap_rsvc" command which only makes sense in
# a cloud environment in its current form (would cause problems for local development).
rm -rf cypress/fixtures/cdisc_files cypress/fixtures/dictionaries cypress/fixtures/import_files
cp -a redcap_rsvc/Files/* cypress/fixtures/

continueFeaturePath="cypress/features/Continue Last Run.feature"
if [ ! -f "$continueFeaturePath" ]; then
    echo "Feature: Continue Last Run
    Scenario: Continue Last Run
        Given I replace this step with whatever step(s) I want to test on the fly" > "$continueFeaturePath"
fi

if [[ "$OSTYPE" == "msys" ]]; then
    # Work around this issue in Git Bash: https://github.com/cypress-io/cypress/issues/789
    SHELL=''
fi

npx cypress open --e2e --browser chrome