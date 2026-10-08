// Write guard: block every non-GET request the browser makes (page navigations,
// form posts, XHR/fetch), except ones a spec explicitly allows (e.g. My Projects'
// stats request). Blocked requests get a 403 and fail the test in afterEach, so an
// accidental write is both prevented and reported.

const SAFE_METHODS = ['GET', 'HEAD', 'OPTIONS']

let allowedWrites = []
let blockedWrites = []

beforeEach(() => {
    allowedWrites = []
    blockedWrites = []

    // Only the REDCap host: Chrome's own background traffic (Google update/account pings) also passes through Cypress.
    cy.intercept({ hostname: new URL(Cypress.config('baseUrl')).hostname }, (req) => {
        if (SAFE_METHODS.includes(req.method)) return

        const url = new URL(req.url)
        const path = url.pathname + url.search
        if (allowedWrites.some((rule) => rule.method === req.method && rule.match(path, req.body))) return

        blockedWrites.push(`${req.method} ${path}`)
        req.reply({ statusCode: 403, body: 'Blocked by live_smoke write guard' })
    })
})

afterEach(() => {
    cy.then(() => {
        expect(blockedWrites.join(', '), 'non-GET requests blocked by the write guard').to.eq('')
    })
})

// Allow one specific kind of write for the current test only.
Cypress.Commands.add('allowWrite', (method, match) => {
    allowedWrites.push({ method, match })
})

// Restore the SSO session saved by `npm run login`. Cookie values are never logged.
Cypress.Commands.add('restoreSession', () => {
    cy.task('loadSession', null, { log: false }).then((session) => {
        if (!session) {
            throw new Error('No saved session. Run `npm run login` first.')
        }
        cy.log(`Using session saved ${session.savedAt}`)
        session.cookies.forEach((c) => {
            cy.setCookie(c.name, c.value, {
                domain: c.domain,
                path: c.path,
                secure: c.secure,
                httpOnly: c.httpOnly,
                sameSite: { Strict: 'strict', Lax: 'lax', None: 'no_restriction' }[c.sameSite],
                expiry: c.expires > 0 ? c.expires : undefined,
                log: false,
            })
        })
    })

    // Fail fast with a clear message instead of following the SSO redirect.
    cy.request({ url: '/index.php?action=myprojects', followRedirect: false, log: false }).then((res) => {
        if (res.status !== 200) {
            throw new Error(`Saved session was rejected (HTTP ${res.status}); it has probably expired. Run \`npm run login\` again.`)
        }
    })
})
