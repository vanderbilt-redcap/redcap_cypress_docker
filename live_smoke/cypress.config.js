const { defineConfig } = require("cypress")
const store = require('./session-store')

// Read-only smoke checks against a live REDCap instance.
// Unlike redcap_cypress, this project does NOT load RCTF, so nothing here can
// reset the database, run SQL/PHP, or clear storage directories.
//
// Set the target with CYPRESS_BASE_URL (or --config baseUrl=...).
// No projectId is set on purpose: results are never uploaded to Cypress Cloud.

const baseUrl = process.env.CYPRESS_BASE_URL

module.exports = defineConfig({
    // Keep env values (and anything secret) out of browser-side Cypress.env().
    allowCypressEnv: false,
    e2e: {
        baseUrl,
        specPattern: 'cypress/e2e/**/*.cy.js',
        supportFile: 'cypress/support/e2e.js',
        setupNodeEvents(on, config) {
            if (!config.baseUrl) {
                throw new Error('Set CYPRESS_BASE_URL to the REDCap URL to check, e.g. CYPRESS_BASE_URL=https://redcap.example.org/')
            }
            on('task', {
                // Session cookies captured by `npm run login`, read from the macOS Keychain.
                loadSession() {
                    return store.load(config.baseUrl)
                },
            })
            return config
        },
        retries: { runMode: 0, openMode: 0 },
        video: false,
        trashAssetsBeforeRuns: false,
        defaultCommandTimeout: 20000,
        pageLoadTimeout: 60000,
        viewportWidth: 1600,
        viewportHeight: 1200,
    },
})
