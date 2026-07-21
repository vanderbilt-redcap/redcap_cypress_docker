# Changelog

Notable changes to all related/child projects are centralized in this file as a single source of truth for updates affecting any part of the **REDCap Cypress Testing Ecosystem**, ensuring consistency across repositories.

The **REDCap Cypress Testing Ecosystem** includes the following [vanderbilt-redcap](https://github.com/vanderbilt-redcap) repositories:

- **Developer Toolkit**: [`redcap_cypress_docker`](https://github.com/vanderbilt-redcap/redcap_rsvc) – Dockerized REDCap test environment for writing REDCap Cypress Gherkin feature tests.
- **RCTF Step Definition Library**: [`rctf`](https://github.com/vanderbilt-redcap/rctf) - Shared step definitions and helper commands that power REDCap Cypress Test Suite.
- **Test Suite Template**: [`redcap_cypress`](https://github.com/vanderbilt-redcap/redcap_rsvc) – Base template for building a REDCap Cypress test suite.

Please [open a GitHub issue](https://github.com/vanderbilt-redcap/redcap_cypress_docker/issues/new/choose) or [submit a PR](https://github.com/vanderbilt-redcap/redcap_cypress_docker/compare) if you notice changes that should be added.

## 17.2.3 - 2026-07-15

-  A [Supported Step Syntax](README.md#supported-step-syntax) section was added to make it easy to become familiar with the most commonly used step definitions. 

## 17.2.1 - 2026-07-03

- Steps include 'the input/textarea/password field' were simplified because extraneous language implied that the step was doing something it wasn't.  The behavior of each step did not change, but the following new language is required moving forward:
    - In only the aforementioned steps, the string 'labeled' has replaced the following:
        - labeled exactly
        - for the field labeled
        - for the Discrepant field labeled
        - within the Record Locking Customization table for the Data Collection Instrument named
    - In only the aforementioned steps, suffixes including 'on/in/within the dialog/tooltip/etc.' have been removed.

## 17.1.1 - 2026-05-22

- Writing Cypress tests within External Modules is now officially supported.  See [README.md](README.md#writing-tests-for-external-modules) for details.
- Removed the following steps that were brittle around page load timing
    - Removed steps like `I (should )see a dialog containing the following text: "a"` in favor of `I should see "a"`
    - Removed steps like `I click the element containing the following text: "a"` in favor of `I click on "a"`
- Removed the following steps that broke on REDCap updates in favor of more generic steps like those after the 'Pending Requests' line in [B.6.4.1200.](https://github.com/vanderbilt-redcap/redcap_rsvc/blob/staging/Feature%20Tests/B/Project%20Setup_4/B.6.4.1200.%20-%20Delete%20Project.feature)
    - `I should see the "a" request created for the project named "b" within the "c" table`
    - `I click on the "a" icon for the "b" request created for the project named "c" within the "d" table`
- Removed brittle steps like `I select record ID "1" from arm name "Arm 1: Arm 1" on the Add / Edit record page` with more mature generic steps like `I select "Arm 2" on the dropdown field labeled "Arm 1"` and `I select "1" on the dropdown field labeled "select record"`.

## 16.0.11 - 2026-02-26

- Removed intermittently failing steps like `When I click on the "View Report" button for the "My Report" report in the My Reports & Exports table` in favor of more reliable steps like `I click on the button labeled "View Report" in the row labeled "My Report"`

## 16.0.4 - 2025-12-18

- Support for [snippets in VS Code](https://github.com/vanderbilt-redcap/redcap_cypress/wiki/Writing-%26-Maintaining-Tests#option-b-vs-code-snippets) was added to make it easier to quickly include commonly repeated blocks of steps.

## 15.8.4 - 2025-11-06

- The word `should` must be added to steps like `And I see "some important text"` as follows: `And I should see "some important text"`
    - This is part of greater efforts to normalize step syntax and reduce support requirements.  Requiring `should` was decided because that syntax was used in the large majority of [redcap_rsvc](https://github.com/vanderbilt-redcap/redcap_rsvc) steps.

## 15.8.1 - 2025-10-22

- The word `exactly` must be removed from steps like `And I click on the link labeled exactly "Logging"`.
    - The implementation behind `exactly` syntax did not work consistently across all step definitions in all scenarios.  Including the word `exactly` was unintuitively not causing any difference in behavior in the large majority of use cases in [redcap_rsvc](https://github.com/vanderbilt-redcap/redcap_rsvc), and the rest were perhaps more appropriately addressed by making step language more clear.  We decided to remove `exactly` syntax rather than fix it because the newer `getLabeledElement()` RCTF command favors exact string matching automatically, only resorting to partial matching if an exact match is not found.  We are in the process of moving toward using `getLabeledElement()` in all relevant RCTF step definitions to ensure a single shared implementation & consistent behavior across all step definitions.
