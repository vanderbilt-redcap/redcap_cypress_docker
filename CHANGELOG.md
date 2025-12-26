# Changelog

Notable changes to all related/child projects are centralized in this file so that we have a single source of truth for all changes affecting any part of the REDCap cypress testing ecosystem.  Please open a github issue or PR if you notice any other changes that you believe should be added here.

## 16.0.4 - 2025-12-18

- Support for [snippets in VS Code](https://github.com/vanderbilt-redcap/redcap_cypress/wiki/Writing-%26-Maintaining-Tests#option-b-vs-code-snippets) was added to make it easier to quickly include commonly repeated blocks of steps.

## 15.8.4 - 2025-11-06

- The word `should` must be added to steps like `And I see "some important text"` as follows: `And I should see "some important text"`
    - This is part of greater efforts to normalize step syntax and reduce support requirements.  Requiring `should` was decided because that syntax was used in the large majority of [redcap_rsvc](https://github.com/vanderbilt-redcap/redcap_rsvc) steps.

## 15.8.1 - 2025-10-22

- The word `exactly` must be removed from steps like `And I click on the link labeled exactly "Logging"`.
    - The implementation behind `exactly` syntax did not work consistencly across all step definitions in all scenarios.  Including the word `exactly` was unintuitively not causing any difference in behavior in the large majority of use cases in [redcap_rsvc](https://github.com/vanderbilt-redcap/redcap_rsvc), and the rest were perhaps more appropriately addressed by making step language more clear.  We decided to remove `exactly` syntax rather than fix it because the newer `getLabeledElement()` RCTF command favors exact string matching automatically, only resorting to partial matching if an exact match is not found.  We are in the process of moving toward using `getLabeledElement()` in all relevant RCTF step definitions to ensure a single shared implementation & consistent behavior across all step definitions.