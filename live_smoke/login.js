// Interactive SSO login. Opens Google Chrome on the REDCap site; you complete
// the Shibboleth/IdP login and MFA by hand. Once REDCap itself loads, the
// session cookies for the REDCap host are saved to the macOS Keychain
// (see session-store.js) and the browser closes. No password is ever seen or stored.
//
//   CYPRESS_BASE_URL=https://redcap.example.org node login.js
//   CYPRESS_BASE_URL=... node login.js --forget   # delete the stored session

const { chromium } = require('playwright-core')
const store = require('./session-store')

const baseUrl = process.env.CYPRESS_BASE_URL
if (!baseUrl) {
    console.error('Set CYPRESS_BASE_URL to the REDCap URL.')
    process.exit(1)
}
const host = new URL(baseUrl).host

if (process.argv.includes('--forget')) {
    console.log(store.remove(baseUrl) ? `Removed stored session for ${host}.` : `No stored session for ${host}.`)
    process.exit(0)
}

const LOGIN_TIMEOUT_MS = 10 * 60 * 1000

// Only the cookies the tests need: the Shibboleth SP and REDCap sessions, plus the
// AWS load balancer stickiness cookies so requests reach the server holding the session.
// Everything else (e.g. Google Analytics) is dropped.
const SESSION_COOKIE = /^(_shibsession_|redcap_session_|AWSALB$|AWSALBCORS$)/

;(async () => {
    // A fresh temporary profile: no access to your normal Chrome profile, cookies or passwords.
    const browser = await chromium.launch({ channel: 'chrome', headless: false })
    const context = await browser.newContext({ viewport: null })
    const page = await context.newPage()

    console.log(`Opening ${baseUrl} - complete the SSO login and MFA in the Chrome window (up to 10 minutes).`)
    await page.goto(new URL('/index.php?action=myprojects', baseUrl).href)

    try {
        // Logged in = back on the REDCap host with a REDCap page rendered.
        await page.waitForURL((url) => url.host === host, { timeout: LOGIN_TIMEOUT_MS })
        await page.waitForSelector('#redcap-home-navbar-collapse, #username-reference, a[href*="logout=1"]', { timeout: LOGIN_TIMEOUT_MS })
    } catch {
        console.error('Timed out waiting for the login to finish. Nothing was saved.')
        await browser.close()
        process.exit(1)
    }

    const cookies = (await context.cookies()).filter((c) => host.endsWith(c.domain.replace(/^\./, '')) && SESSION_COOKIE.test(c.name))
    if (!cookies.some((c) => c.name.startsWith('redcap_session_'))) {
        console.error('Logged in, but no REDCap session cookie was found. Nothing was saved.')
        await browser.close()
        process.exit(1)
    }
    store.save(baseUrl, cookies)
    await browser.close()

    // Print names only - values are session secrets.
    console.log(`Saved ${cookies.length} cookies for ${host} to the macOS Keychain (service "redcap-live-smoke"): ${cookies.map((c) => c.name.replace(/_[0-9a-f]{16,}$/, '_…')).join(', ')}`)
})()
