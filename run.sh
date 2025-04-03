#!/bin/sh

set -e

cd redcap_docker
docker compose up -d
cd ..

htmlDirLineCount=`docker inspect -f '{{ .Mounts }}' redcap_docker-app-1 | grep /var/www/html | wc -l`
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
    lsCommand='ls -1d redcap_v* | cut -d/ -f 1'

    sh -c "$lsCommand" > temp/dev-file-list
    set +e # Disable failing on errors in case all redcap_v* dirs have been removed and to capture the diff return code
    docker exec redcap_docker-app-1 sh -c "$lsCommand" > temp/docker-file-list
    diff temp/dev-file-list temp/docker-file-list > /dev/null
    filesDiffer=$?
    set -e

    if [ $filesDiffer ]; then
        echo Copying new REDCap version directories into the docker container...
        tar -cz --exclude-from=temp/docker-file-list -f ../redcap_source.tar.gz .
        docker cp ../redcap_source.tar.gz redcap_docker-app-1:/var/www/html/redcap_source.tar.gz
        rm ../redcap_source.tar.gz
        docker exec redcap_docker-app-1 sh -c "
            cd /var/www/html
            tar xzf redcap_source.tar.gz
            rm redcap_source.tar.gz
        " 
    fi
    
    cd ..
fi

# We've seen these directory permissions get reset for unknown reasons
# Until we identify why this happens, the following should resolve it.
docker exec redcap_docker-app-1 sh -c 'chown www-data temp edocs'

cd redcap_cypress
npm install --no-fund
npm run redcap_rsvc:validate_features

# Ideally we'd call "npm run redcap_rsvc:move_files" here instead of the following lines,
# but we can't do that currently because "redcap_rsvc:move_files" contains
# a "move-cli node_modules/redcap_rsvc redcap_rsvc" command which only makes sense in
# a cloud environment in its current form (would cause problems for local development).
rm -rf cypress/fixtures/cdisc_files cypress/fixtures/dictionaries cypress/fixtures/import_files
cp -a redcap_rsvc/Files/* cypress/fixtures/

if [[ "$OSTYPE" == "msys" ]]; then
    # Work around this issue in Git Bash: https://github.com/cypress-io/cypress/issues/789
    SHELL=''
fi

npx cypress open