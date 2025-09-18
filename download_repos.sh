#!/usr/bin/env bash

git clone git@github.com:vanderbilt-redcap/redcap_cypress.git
git clone git@github.com:vanderbilt-redcap/redcap_docker.git

#Move Base Configurations for Cypress
cp ./config/cypress.config.js ./redcap_cypress/cypress.config.js
cp ./config/cypress.env.json ./redcap_cypress/cypress.env.json

#Install the REDCap RSVC repository so automated feature tests can run
cd redcap_cypress
git clone git@github.com:vanderbilt-redcap/redcap_rsvc.git
