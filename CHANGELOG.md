# Changelog

Notable changes to all related/child projects are centralized in this file as a single source of truth for updates affecting any part of the **REDCap Cypress Testing Ecosystem**, ensuring consistency across repositories.

The **REDCap Cypress Testing Ecosystem** includes the following [vanderbilt-redcap](https://github.com/vanderbilt-redcap) repositories:

- **Developer Toolkit**: [`redcap_cypress_docker`](https://github.com/vanderbilt-redcap/redcap_rsvc) – Dockerized REDCap test environment for writing REDCap Cypress Gherkin feature tests.
- **RCTF Step Definition Library**: [`rctf`](https://github.com/vanderbilt-redcap/rctf) - Shared step definitions and helper commands that power REDCap Cypress Test Suite.
- **Test Suite Template**: [`redcap_cypress`](https://github.com/vanderbilt-redcap/redcap_rsvc) – Base template for building a REDCap Cypress test suite.

Please [open a GitHub issue](https://github.com/vanderbilt-redcap/redcap_cypress_docker/issues/new/choose) or [submit a PR](https://github.com/vanderbilt-redcap/redcap_cypress_docker/compare) if you notice changes that should be added.

## 17.3.6 - 2026-08-27

- Table content matching is now much more strict:
    - The following applies to `I should see a table header and rows containing the following values` steps and variations thereof.
    - Strictness was increased because scenarios were encountered where table matching steps would report success even though the table was not actually displayed as expected.
    - Column & row order is now required to match.
    - An empty first cell now means that the contents of that row in gherkin should be considered part of the previous row on the page. This has long been a common assumption among gherkin writers, but that was not actually the behavior until now. 
    - The first header of the first row can no longer be blank.
    - Cell content now requires a strict match. Previously a gherkin table cell value of `a c` would be incorrectly considered a successful match when `a b c` was the actual value present.
    - Likely other more nuanced changes related to strict matching.
- Removed the following language in favor of `in the row labeled` language that works more reliably, and has been used exclusively by redcap_rsvc has used in these cases for many months:
    - `in the "Main project settings" section`
    - `in the "xyz" row in the "Enable optional modules and customizations" section` 
- Steps using the language "enter Choices" now throw an error recommending the following syntax instead:
    - `I enter "1, One{enter}2, Two" in the textarea field labeled "Choices"`
- Any steps using the work "enter" to enter text have been normalized to remove the existing text first.
    - This effectively makes "enter" and "clear and enter" behave identically.  We plan to remove the "clear and" prefix at a later date to help normalize language.
    - The reasoning behind this change is that manual testers generally interpret "enter" to mean "clear and enter", creating a discrepancy between manual & automated test outcomes. Making all "enter" steps replace any preexisting text resolves this discrepancy.
- The following step has been added to support REDCap+ testing:
    - `I enter a REDCap+ subscription key into the textarea field labeled "Enter a REDCap+ subscription key"`
    - To disable REDCap+ tests, add/set 'skip_redcap_plus_tests' to true in cypress.env.json.
    - To enable REDCap+ tests, either add/set 'redcap_plus_subscription_key' in cypress.env.json, or set the 'REDCAP_PLUS_SUBSCRIPTION_KEY' system environment variable.

## 17.2.3 - 2026-07-15

- A [Supported Step Syntax](README.md#supported-step-syntax) section was added to make it easy to become familiar with the most commonly used step definitions. 

## 17.2.1 - 2026-07-03

- Steps including `the input/textarea/password field` language were simplified because extraneous language implied that the step was doing something it wasn't.  The behavior of each step did not change, but the following new language is required moving forward:
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
