# REDCap Cypress Developer Toolkit

The REDCap Cypress Developer Toolkit provides an automated framework for validating REDCap’s core functionality. Automated testing helps ensure system integrity, reduces manual testing burden, and supports institutions in meeting regulatory compliance requirements (e.g., 21 CFR Part 11).

The toolkit was the brain child of Adam De Fouw, who deserves most of the credit for getting it off the ground.  This and all related projects were originally developed by him and the RSVC Automated Testing Subcommittee (ATS).  They are now maintained by Vanderbilt University Medical Center (VUMC). RSVC continues to contribute to updates and actively uses the toolkit for REDCap validation efforts.

This repository includes scripts to download all the necessary components for a developer to begin developing automated feature tests on their developer machine.  This toolkit is based on the industry-standard [Cypress Testing Framework](https://github.com/cypress-io/cypress/blob/develop/README.md).

If you'd like to participate in our ongoing automation efforts, see our [Contribution Guidelines](CONTRIBUTING.md).


## What is Automated Testing?

Automated testing involves executing pre-scripted tests against a REDCap instance to validate that core functionality works as expected. These tests:
  - Ensure system stability after software updates
  - Reduce redundant manual testing for common workflows
  - Support regulatory compliance efforts by providing structured validation

Tests are executed in a controlled test environment and should never be run on a production system, as they modify project data.


## How Are Automated Tests Selected?

Not all REDCap features are suitable for automation. When determining which features should be tested automatically, the RSVC considers:

  - Reproducibility – Can the test be executed consistently across institutions?
  - Regulatory Impact – Does the feature support compliance with 21 CFR Part 11?
  - Complexity – Is automation feasible, or does the feature require manual review?
  - Test Stability – Does the test produce reliable results across different REDCap versions?

For each REDCap release, RSVC reviews system changes and determines which features should be tested manually and which can be automated.


# Overview

![Developer Toolkit](developer-toolkit.png)

### Software Prerequisites:

The following steps are intended to help set up a testing environment on a personal computer in order to aid with development and contribute changes back to this project.  If instead you're hoping to re-run all automated tests at your institution, see [Creating An Automated Testing Environment](creating-an-automated-testing-environment.md).

A developer needs the following software on their machine before installing this Developer Toolkit.

- WSL (only required for Windows)
  - If your institution does not give you full administrator access to your computer (like at VUMC), you may have to request temporary admin permissions in order to install WSL.
  - Follow [this tutorial](https://www.youtube.com/watch?v=QM3mzEJCzjY).
- Git (version control)

  - [For Windows](https://gitforwindows.org/)
  - For macOS options (choose one)
    - [Homebrew](https://brew.sh/): `brew install git`
    - [MacPorts](https://www.macports.org/): `sudo port install git`
    - [Xcode](https://developer.apple.com/xcode/) - shipped as a binary package
  - [For Linux](https://git-scm.com/download/linux)
- [Rancher Desktop](https://rancherdesktop.io/) - This is a drop-in replacement for [Docker Desktop](https://www.docker.com/products/docker-desktop/), which is still supported but not allowed at some organizations (like VUMC).
  - You may want to set Rancher to `Automatically start on login` and `Start in the background` under `Preferences -> Application -> Behavior`
  - If you've previously had Docker Desktop installed, you may have to run `docker context use default` before Rancher will work as expected.
- [Node.js](https://nodejs.org/en/download) - available for Windows, macOS, Linux
- [VS Code](https://code.visualstudio.com/) - This is the recommended [IDE](https://en.wikipedia.org/wiki/Integrated_development_environment), but others may be used as well (e.g. PhpStorm).  Be mindful that **Visual Studio Code** is most often referred to as **VS Code** in part to distinguish it from a different application simply called **Visual Studio** which we do not use.
- [Cucumber Extension for VS Code by cucumber.io](https://marketplace.visualstudio.com/items?itemName=CucumberOpen.cucumber-official)

### Add SSH Key To GitHub Account

1. Open a console (Git Bash on Windows, Terminal on Mac).
1. Type `ssh-keygen` and press enter.
1. Press enter again to accept the default path
1. If prompted to `Overwrite` an existing key, enter `n` and press enter. If you were not prompted to `Overwrite`, you will be prompted for a passphrase.  Simply pressing enter and using empty passphrase is acceptable if you are comfortable accepting the risk that anyone gaining unauthorized access to the generated key file will also have partial access to your GitHub account.
1. Type `cat ~/.ssh/id_ed25519.pub` and press enter to display the public half of the newly created key pair.
1. Copy the `ssh-ed25519...` line that was displayed.  In most consoles this is accomplished my highlighting the line then right clicking.
1. Log into GitHub.
1. In the upper-right corner of any page on GitHub, click your profile picture, then click `Settings`.
1. In the "Access" section of the sidebar, click `SSH and GPG keys`.
1. Click `New SSH key`.
1. In the "Title" field, add a descriptive label for the new key. For example, if you're using a personal laptop, you might call this key "Personal laptop".
1. In the "Key" field, paste the `ssh-ed25519...` line you copied from the console.
1. Click `Add SSH key`.
1. If prompted, confirm access to your account on GitHub. 

### Developer Toolkit Installation Instructions:

1. Open a console (Git Bash on Windows, Terminal on Mac).
1. Navigate to the directory where you want this project to live (e.g. your home directory).  If you don't have experience navigating between different directories in a terminal, ask the AI of your choice to teach you. 
1. Run the following command to download a copy of this project to the current directory in your terminal:
    - `git clone git@github.com:vanderbilt-redcap/redcap_cypress_docker.git`
    - If you see a failure message that says you do not have permissions or mentions a public key, you likely skipped the `Add SSH Key To GitHub Account` section above.
    - Run `cd redcap_cypress_docker` to navigate into the directory containing the newly cloned copy of this repo.
1. Start the test environment by running the the following command:
    - `./run.sh`
    - If you see an error message about Docker not running or an "error during connect", you will need to start your chosen docker app (likely Rancher or Docker Desktop).  If it is started already, you may need to restart it and/or your computer.
1. You will be prompted for your username and password to the REDCap Community website in order to download REDCap the first time you set up your test environment and after certain updates. If the download fails after entering your credentials, email `redcap@vumc.org` and ask them to give your community account permission to download REDCap.
1. The Cypress window should open after a few minutes, allowing you to select & run any RSVC feature test.  Cypress will open much faster on subsequent runs.

### Strategies For Developing & Debugging Features

1. If you run into any issues with your environment not working as expected, we recommend running `./update.sh` as mentioned below.  In addition to updating all tooling, this command also recreates the docker containers, which will resolve many different types of issue.

1. The single most useful tool is `Continue Last Run.feature`, found under `redcap_cypress/cypress/features`.  The REDCap database is normally cleared between feature runs.  However, executing this special feature file immediately runs whatever steps you place in it against the current state of the database.  Rather than repeatedly running any features files you're working on from the beginning, you should use this file to test a small number of steps at a time to greatly reduce iteration time and significantly speed up your workflow.

1. Execution can be paused in the middle of a feature to check details or perform manual actions by adding the following step: `And I want to pause`.  To continue execution, press the play button in the Cypress UI.

### Updating The Test Environment:

You should perform the following steps periodically to ensure your local environment includes the latest changes:

1. Read the portion of [the changelog](CHANGELOG.md) for all REDCap versions since the one you last tested using cypress.  This is important to stay informed and consider breaking changes that may be required when you choose to update to the latest version. 
1. Close cypress (if it's open)
1. Run `./update.sh`
1. Run `./run.sh` to open cypress again

### Changing REDCap Versions

The `master` branch of `redcap_cypress` will be checked out by default.  This will use the latest REDCap release version that has been tested.  If you would like to test a different REDCap version, perform the following steps:
1. Determine which [redcap_cypress branch](https://github.com/vanderbilt-redcap/redcap_cypress/branches/all?query=v) is closest to the REDCap version you'd like to test.
    - If you have github access to REDCap's source code you may also test REDCap changes that have not yet made it into a release yet using the `dev` branch.
    - While using the `dev` branch, you may also user your own modified version of REDCap's source code using the following command at any time (including while Cypress is running):
        - ```
          ./copy-redcap-source-to-container.sh path/to/redcap_v#.#.#
          ```
        - Keep in mind that this command must be run every time you change a REDCap source file.  It is possible to avoid this by uncommenting the `redcap_source` volume in `docker-compose.yml`, but that is not recommended as it will come with a significant performance hit (especially on Windows).
1. Navigate to the `redcap_cypress` directory and run `git checkout <your-desired-branch>` to checkout that branch
1. If a branch does not exist for the exact REDCap version you'd like to test, you can modify this project to run on that version by editing the **redcap_cypress/cypress.env.json.example** file and updating the **redcap_version** variable to your desired REDCap version.  This variable is copied from **cypress.env.json.example** into **cypress.env.json** every time `./run.sh` is called so that the expected version of REDCap is used after `./update.sh`, `git pull`, `git checkout`, etc.
1. If you have cypress open, close it.
1. Run `./run.sh`

### Contributing To RSVC Feature Tests:

1. Create your own fork of redcap_rsvc that is based upon https://github.com/vanderbilt-redcap/redcap_rsvc

2. Configure the cloned redcap_rsvc repository as needed to match your own Fork.

```
cd redcap_cypress/redcap_rsvc
git remote rename origin upstream
git remote add origin <your_fork_url_here>
```

Having your own fork enables you to issue pull requests to vanderbilt-redcap/redcap_rsvc after you complete a feature.

See the [Supported Step Syntax](#supported-step-syntax) section below to learn about all the various steps you can use within your feature tests.

### Writing Tests For External Modules

Completing the above steps will also allow you to create Cypress tests for External Modules. Any External Modules you wish to test should be placed in `redcap_source/modules`.  Any `.feature` files places inside an `automated-tests` directory in the root of each module will automatically become available in Cypress.  The following special behaviors will occur when they run:
- The relevant module (and only that module) will be automatically enabled when the test starts.
- File paths used in test steps will be considered relative to the `.feature` file that is being run.
- More coming soon!  We currently have bandwidth to actively support module authors in writing cypress tests.  As you notice issues or have ideas for additional features and/or how to make module testing easier, please reach out by [creating an issue](https://github.com/vanderbilt-redcap/redcap_cypress_docker/issues/new).

A working example test can be found in the [Module Development Examples module](https://github.com/vanderbilt-redcap/external-module-framework-docs/tree/main/example_modules/module-development-examples_v1.0/automated-tests/file-settings.feature).

See the [Supported Step Syntax](#supported-step-syntax) section below to learn about all the various steps you can use within your feature tests.

### Supported Step Syntax

When trying to determine what step syntax is supported for a given action you'd like to take, step one should generally be to reference the following list of the most commonly used step definitions.  Nine out of ten times the action you want to perform will be supported by one of the following:

- `I login to REDCap with the user "Some_User_Name"`
  - By default, the following usernames are configured: `Test_Admin` and `Test_User1` through `Test_User4`
  - If you'd like to log in manually, the default password is `Testing123` for all of them.
- `I create a new project named "Test Project" by clicking on "New Project" in the menu bar, selecting "Practice / Just for fun" from the dropdown, choosing file "Project_1.xml", and clicking the "Create Project" button`
- `I (action) the (target) labeled "Some text near the target"`
  - `action` can be `click on`, `should see`, `should NOT see`, `check`, or `uncheck`
  - `target` can be `button`, `link`, `checkbox`, `icon`, or `radio`
  - The suffix ` in the row labeled "Some text in that row"` can be added to only look within a particular table row.
  - The suffix ` in the column labeled "Some text in that column" and the row labeled "Some text in that row"` can be added to only look within a certain table cell.
- `I select "Some dropdown option" on the dropdown field labeled "Some text near the desired 'select' element"`
- `I should see "Text expected anywhere on the page"`
- `I should NOT see "Text that shouldn't exist anywhere on the page"`
- `I enter "Some text" into the (target) labeled "Some text near the desired element"`
  - `target` can be `input field` or `textarea`
- `I should see a table header and rows containing the following values in a table:`
  - See [usage examples in redcap_rsvc](https://github.com/search?type=code&q=repo%3Avanderbilt-redcap%2Fredcap_rsvc+path%3A%2F%5EFeature+Tests%5C%2F%2F+%22I%20should%20see%20a%20table%20header%20and%20rows%20containing%20the%20following%20values%20in%20a%20table:%22) for how to specify the desired headers & rows.
- `I upload a "csv" format file located at "path/to/file.csv", by clicking the button near "Choose File" to browse for the file, and clicking the button labeled "Upload File" to upload the file`
  - All the items in quotes can be modified to match the situation.
- `I wait for X seconds`
  - This step should be used sparingly as it unnecessarily slows down tests. It can generally be avoided by using an `I should see...` step to look for something specific on the page and allowing the test to continue immediately when it is found. There are occasionally exceptions where waiting is the only option current available.
- `I logout`

All supported step definitions and their many variations can be found in the [RCTF Documentation](https://vanderbilt-redcap.github.io/rctf/). It includes a `Gherkin Step Builder` to help you generate syntactically valid steps for your feature tests.  Under the hood, all step definitions are defined in the [RCTF](https://github.com/vanderbilt-redcap/rctf) node library.

Test writers also often find it helpful to search within the `Feature Tests` directory in `redcap_rsvc` for common steps using keywords related to what they would like to do.  For example, you can...
- [Search for "click"](https://github.com/search?type=code&q=repo%3Avanderbilt-redcap%2Fredcap_rsvc+path%3A%2F%5EFeature+Tests%5C%2F%2F+%22click%22) to see steps for clicking various elements
- [Search for "in the row"](https://github.com/search?type=code&q=repo%3Avanderbilt-redcap%2Fredcap_rsvc+path%3A%2F%5EFeature+Tests%5C%2F%2F+%22in+the+row%22) to see steps looking only within table rows
- [Search for "table header and rows containing"](https://github.com/search?type=code&q=repo%3Avanderbilt-redcap%2Fredcap_rsvc+path%3A%2F%5EFeature+Tests%5C%2F%2F+%22table+header+and+rows+containing%22) to see steps looking for specific table content
- [Search for "download"](https://github.com/search?type=code&q=repo%3Avanderbilt-redcap%2Fredcap_rsvc+path%3A%2F%5EFeature+Tests%5C%2F%2F+%22download%22) to see steps related to downloads
- [Search for "User Rights"](https://github.com/search?type=code&q=repo%3Avanderbilt-redcap%2Fredcap_rsvc+path%3A%2F%5EFeature+Tests%5C%2F%2F+%22User+Rights%22) to see steps related to User Rights

RSVC has created hundreds of automated feature tests that validate the functional requirements of REDCap. Reviewing these feature tests is useful because they serve as a template for testing many aspects of REDCap.

## Additional Information

For more information about the innerworkings, see the [REDCap Cypress Test Suite Docs](https://github.com/vanderbilt-redcap/redcap_cypress/blob/master/README.md)
