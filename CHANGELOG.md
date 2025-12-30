# Changelog

Notable changes to all related/child projects are centralized in this file as a single source of truth for updates affecting any part of the **REDCap Cypress Testing Ecosystem**, ensuring consistency across repositories.

The **REDCap Cypress Testing Ecosystem** includes the following [vanderbilt-redcap](https://github.com/vanderbilt-redcap) repositories:

- **Developer Toolkit**: [`redcap_cypress_docker`](https://github.com/vanderbilt-redcap/redcap_rsvc) – Dockerized REDCap test environment for writing REDCap Cypress Gherkin feature tests.
- **RCTF Step Definition Library**: [`rctf`](https://github.com/vanderbilt-redcap/rctf) - Shared step definitions and helper commands that power REDCap Cypress Test Suite.
- **Test Suite Template**: [`redcap_cypress`](https://github.com/vanderbilt-redcap/redcap_rsvc) – Base template for building a REDCap Cypress test suite.

Please [open a GitHub issue](https://github.com/vanderbilt-redcap/redcap_cypress_docker/issues/new/choose) or [submit a PR](https://github.com/vanderbilt-redcap/redcap_cypress_docker/compare) if you notice changes that should be added.

## 16.0.4 - 2025-12-18

- Support for [snippets in VS Code](https://github.com/vanderbilt-redcap/redcap_cypress/wiki/Writing-%26-Maintaining-Tests#option-b-vs-code-snippets) was added to make it easier to quickly include commonly repeated blocks of steps.

## 15.8.4 - 2025-11-06

- The word `should` must be added to steps like `And I see "some important text"` as follows: `And I should see "some important text"`
    - This is part of greater efforts to normalize step syntax and reduce support requirements.  Requiring `should` was decided because that syntax was used in the large majority of [redcap_rsvc](https://github.com/vanderbilt-redcap/redcap_rsvc) steps.

## 15.8.1 - 2025-10-22

- The word `exactly` must be removed from steps like `And I click on the link labeled exactly "Logging"`.
    - The implementation behind `exactly` syntax did not work consistently across all step definitions in all scenarios.  Including the word `exactly` was unintuitively not causing any difference in behavior in the large majority of use cases in [redcap_rsvc](https://github.com/vanderbilt-redcap/redcap_rsvc), and the rest were perhaps more appropriately addressed by making step language more clear.  We decided to remove `exactly` syntax rather than fix it because the newer `getLabeledElement()` RCTF command favors exact string matching automatically, only resorting to partial matching if an exact match is not found.  We are in the process of moving toward using `getLabeledElement()` in all relevant RCTF step definitions to ensure a single shared implementation & consistent behavior across all step definitions.
