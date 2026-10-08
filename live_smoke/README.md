# Live REDCap smoke checks (read-only)

Safe, non-destructive Cypress checks for a **live** REDCap instance behind SSO
(default target: `https://stagerc2.rarediseasesnetwork.org`, override with `CYPRESS_BASE_URL`).

Do **not** point `redcap_cypress` / RSVC features at a live server: RCTF drops and
recreates the REDCap database and empties storage folders before every feature.
This project is separate from that setup:

- It does not load RCTF and has no DB, SQL, PHP or filesystem tasks.
- A write guard (`cypress/support/e2e.js`) blocks every non-GET request to the REDCap
  host with a 403 and fails the test, unless a spec explicitly allows it with `cy.allowWrite`.
- There is no `projectId`, so nothing is uploaded to Cypress Cloud. There are no retries.

## Usage

```
cd live_smoke
npm install
npm run login     # once per session: complete SSO + MFA in the Chrome window that opens
npm test          # public checks + authenticated checks
npm run logout    # delete the saved session from the Keychain
```

Without a saved session, the authenticated spec is skipped. When the session expires
(REDCap auto-logout or Shibboleth session lifetime), the run fails with
"Saved session was rejected"; run `npm run login` again.

Optional: `npm test -- --env EXPECTED_VERSION=17.3.17` fails if the server reports a different version.

## How the login works

The site requires federated SSO with MFA, so username/password automation isn't possible
(and isn't stored). Instead:

1. `npm run login` (`login.js`) opens Google Chrome with a fresh, temporary profile, so it can't reach your normal
   Chrome cookies or passwords. You log in and approve MFA yourself.
2. When REDCap's My Projects page loads, the script keeps only the session cookies for the REDCap host (`_shibsession_*`,
   `redcap_session_*`, `AWSALB`, `AWSALBCORS`; analytics cookies are dropped) and saves them to the **macOS login Keychain** (service `redcap-live-smoke`, account = host),
   then closes the browser.
3. `npm test` reads them back from the Keychain in Cypress's Node process (`cy.task('loadSession')`)
   and sets them in the test browser with logging disabled.

## How the credentials are protected

- Your password and MFA never pass through this code; you type them into the IdP page directly.
- The session cookies live only in the Keychain. They're never written to a file, the repo,
  the console or the Cypress command log (`log: false`). The login script prints cookie names only.
- They're handed to `security` over stdin, not as arguments, so they don't appear in `ps`.
- `allowCypressEnv: false` keeps env values out of browser-side `Cypress.env()`.
- Video is off. Failure screenshots (`cypress/screenshots/`, gitignored) can show page content
  such as your username and project names, but never cookies.
- The saved session is a bearer token until it expires: anyone who can read your login Keychain
  could use it until then. Run `npm run logout` to delete it, or log out of REDCap to end it on
  the server side.
