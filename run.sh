#!/bin/sh

set -e

# We used to commit submodule changes to this repo, but now update them automatically via update.sh
# The following lines prevent any pulled changes from appearing in VS Code
# and confusing developers who often only care about redcap_rsvc
git config submodule.redcap_cypress.ignore all
git config submodule.redcap_docker.ignore all

redcapVersion=`cat redcap_cypress/.circleci/config.yml |grep 'REDCAP_VERSION:'|cut -d'"' -f 2`
if [ ! -d "redcap_source/redcap_v$redcapVersion" ]; then
    echo "The version of REDCap used for testing has changed.  The new version must be downloaded."
    ./download_redcap.sh $redcapVersion
fi

# Ensure the correct version of REDCap is used even if we're switching back and forth between redcap_cypress branches.
sed -i '/  "redcap_version": ".*",/c\  "redcap_version": "'${redcapVersion}'",' redcap_cypress/cypress.env.json

cd redcap_docker
docker compose up -d
cd ..

htmlDirLineCount=`cat redcap_docker/docker-compose.yml | grep -v '#' | grep '../redcap_source' | wc -l`
if [ $htmlDirLineCount = 0 ]; then
    # Reaching this point means the redcap_source dir is not being mounted in the container via the volumes section
    # of docker-composer.yml, and should be copied into the container instead.
    # We used to mount the redcap_source dir as a docker volume,
    # but this made many features take roughly 3 times as long on Windows,
    # due to cross filesystem performance limitations and Microsoft Defender on the fly scans.

    cd redcap_source

    # The following commands must give identical output on docker, git bash, mac terminal, etc.
    # The trailing slash is removed to match output between platforms,
    # and so the output can be uses for tar's "--exclude-from" option below.
    lsCommand='ls -1d redcap_v* 2>/dev/null | cut -d/ -f 1'

    sh -c "$lsCommand" > temp/dev-file-list
    set +e # Disable failing on errors in case all redcap_v* dirs have been removed and to capture the diff return code
    docker exec redcap_docker-app-1 sh -c "$lsCommand" > temp/docker-file-list
    diff temp/dev-file-list temp/docker-file-list > /dev/null
    filesDiffer=$?
    set -e

    if [ "$filesDiffer" -ne "0" ]; then
        echo Copying new REDCap version directories into the docker container...
        tar -cz --exclude-from=temp/docker-file-list -f ../redcap_source.tar.gz .
        docker cp ../redcap_source.tar.gz redcap_docker-app-1:/var/www/html/redcap_source.tar.gz
        rm ../redcap_source.tar.gz
        docker exec redcap_docker-app-1 sh -c "
            cd /var/www/html
            tar xzf redcap_source.tar.gz
            rm redcap_source.tar.gz
            
            # We used to use chown here, but that broke when we switched to a different docker base image.
            # Changing the permissions to 777 should work regardless of any future base image changes
            chmod 777 temp edocs
        " 
    fi
    
    cd ..
fi

cd redcap_cypress
# We add the "--no" arguments to simplify output for less technical users.
# We don't really care about vulnerabilities since we're not hosting this project
npm install --no-fund --no-audit 

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