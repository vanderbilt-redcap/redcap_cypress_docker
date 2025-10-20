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

- [Software Prerequisites](#software-prerequisites)
- [Create SSH Key](#ssh-key-in-github-account)
- [Developer Toolkit Installation Instructions](#developer-toolkit-installation-instructions)
- [Changing REDCap Versions](#changing-redcap-versions)
- [Start REDCap Test Environment](#start-redcap-test-environment)
- [Configure & Start Cypress](#configure--start-cypress)
- [Contribute to Feature Tests](#contribute-to-feature-tests)
- [Update Repositories](#update-repositories)
- [Rebuild Docker Containers](#rebuild-docker-containers)

![Developer Toolkit](developer-toolkit.png)

### Software Prerequisites:

The following steps are intended to help set up a testing environment on a personal computer in order to aid with development and contribute changes back to this project.  If instead you're hoping to re-run all automated tests at your institution, see [Creating An Automated Testing Environment](creating-an-automated-testing-environment.md).

A developer needs the following software on their machine before installing this Developer Toolkit.

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

### SSH Key in GitHub Account

You will need to place your public key on GitHub for this process to work correctly.

To generate a key on your local machine, most of time the command is:

```
ssh-keygen
```

Please consult GitHub's SSH documentation for more information:
[GitHub SSH Key Instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

Specifically, you will need to

- [Generate a new SSH Key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- [Add the SSH Key to your GitHub Account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

### Developer Toolkit Installation Instructions:

1. **Clone this repository to your machine.** [^1]

   ```
   git clone git@github.com:vanderbilt-redcap/redcap_cypress_docker.git
   ```

### Changing REDCap Versions

To test against a different version of REDCap, simply update the **REDCAP_VERSION** variable in the **config.yml** file in the **/redcap_cypress/.circleci/** folder to your target REDCap version.

  ```
  REDCAP_VERSION: "15.5.7"
  ```

### Start REDCap Test Environment:

Run the following from a bash compatible command line to start the test environment.  Git Bash is supported on Windows, and standard terminals are supported on Mac & Linux.  You will be prompted for REDCap Community site credentials in order to download REDCap the first time you run this and after certain updates.

```
./run.sh
```

### Update The REDCap Test Environment:

You should perform the following steps periodically to ensure your local environment includes the latest changes:

1. Close cypress (if it's open)
2. Run `./update.sh`
3. Run `./run.sh` to open cypress again

### Strategies For Developing & Debugging Features

1. The single most useful tool is `Continue Last Run.feature`.  The REDCap database is normally cleared between feature runs.  However, executing this special feature file immediately runs whatever steps you place in it against the current state of the database.  Rather than repeatedly running any features files you're working on from the beginning, you should use this file to test a small number of steps at a time to greatly reduce iteration time and significantly speed up your workflow.

1. Execution can be paused in the middle of a feature to check details or perform manual actions by adding the following step: `And I want to pause`.  To continue execution, press the play button in the Cypress UI.

### Contribute to Feature Tests:

1. Create your own fork of redcap_rsvc that is based upon https://github.com/vanderbilt-redcap/redcap_rsvc

2. Configure the cloned redcap_rsvc repository as needed to match your own Fork.

```
cd redcap_cypress/redcap_rsvc
git remote rename origin upstream
git remote add origin <your_fork_url_here>
```

Having your own fork enables you to issue pull requests to vanderbilt-redcap/redcap_rsvc after you complete a feature.

## Additional Information

For more information about the innerworkings, see the [REDCap Cypress Test Suite Docs](https://github.com/vanderbilt-redcap/redcap_cypress/blob/master/README.md)

### Issues and Resolutions:

[^1]: Git Clone Fail: If the message says you do not have permissions or mentions a public key, you might need to setup a [SSH key with Github](#ssh-key-in-github-account).
[^2]: Shell Script not Running: If you are on Windows and you see no outputs, you will need to run in a Bash shell. Because you have Git, you might have Git Bash installed. At the top of your VS Code terminal, on the right, Click on the down-arrow next to the plus sign and select Git Bash.
[^3]: Docker Running: If you see an error message about Docker not running or an "error during connect", you will need to start Docker Desktop. On Windows, you can search for Docker Desktop in the Start Menu. On macOS, you can find it in your Applications folder. On Linux, you can start the Docker service with `sudo systemctl start docker`. If you get a message of "no configuration file provided: not found", you might not be in the redcap_docker directory.
