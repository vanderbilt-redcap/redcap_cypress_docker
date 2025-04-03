# Creating An Automation Environment

If desired, it is complex but possible to create your own environment to run all automated tests yourself and fully reproduce Vanderbilt's validation process at your institution.  Vanderbilt is unable to assist in setting up such an environment for other institions, but provides this basic documentation as a starting point.

REDCap's automated tests should be executed against a REDCap test server instance and/or continuous integration pipeline mirroring your site's production REDCap instance.  Vanderbilt's [CircleCI Configuration](https://github.com/vanderbilt-redcap/redcap_cypress/blob/master/.circleci/config.yml) may be a useful starting point.  Rerunning tests against using a similar configuration will not provide feedback specific to your institution, or any results meaningfully different than Vanderbilt's validation process.

The following steps may be a useful checklist when configuring your institution's automation environment:
1.  **Checkout REDCap and related source code** **intended for deployment** (includes REDCap source + could include hooks, plugins, EMs, etc.)
1.  Checkout **redcap_cypress** repository
1.  Generate **cypress.env.json** that matches the configuration you need. You could use** cypress.env.json.example** as a starting point.  Set **redcap_version** and **MySQL** environment variables as needed for environment.
1.  Set desired **redcap_rsvc** version in **package.json** (e.g. `"redcap_rsvc": "git://github.com/vanderbilt-redcap/redcap_rsvc#v15.0.9"`)
1.  Install Cypress and RCTF dependencies: `npm install`
1.  Install REDCap RSVC Feature tests **(as defined in **package.json**): `npm run redcap_rsvc:install`
1.  Start test instance of REDCap (if not already running).  Command is specific to test instance implementation.
1.  Run Cypress tests (e.g. `CYPRESS_prettyEnabled=true npx cypress run --record --key $RECORD_KEY --browser chrome`)

How that specific code above looks will widely vary based on your environment.
