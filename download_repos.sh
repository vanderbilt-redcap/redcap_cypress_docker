#!/usr/bin/env bash

git submodule update --init --recursive
git submodule update --recursive --remote

#Move Base Configurations for Cypress
cp ./config/cypress.config.js ./redcap_cypress/cypress.config.js
cp ./config/cypress.env.json ./redcap_cypress/cypress.env.json

#Install the REDCap RSVC repository so automated feature tests can run
cd redcap_cypress || exit
git clone git@github.com:vanderbilt-redcap/redcap_rsvc.git
git submodule add git@github.com:vanderbilt-redcap/redcap_rsvc.git redcap_rsvc
