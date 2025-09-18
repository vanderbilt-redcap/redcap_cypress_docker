#!/usr/bin/env bash

git clone git@github.com:vanderbilt-redcap/redcap_cypress.git
git clone git@github.com:vanderbilt-redcap/redcap_docker.git

#Move Base Configurations for Cypress
cp ./redcap_cypress/cypress.config.js.example ./redcap_cypress/cypress.config.js
awk '{ gsub(/"temp_folder": ".*",/, "\"temp_folder\": \"/var/www/html/temp\","); print }' ./redcap_cypress/cypress.env.json.example > ./redcap_cypress/cypress.env.json

#Install the REDCap RSVC repository so automated feature tests can run
cd redcap_cypress
git clone git@github.com:vanderbilt-redcap/redcap_rsvc.git
