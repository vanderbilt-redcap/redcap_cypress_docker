// Checks behind SSO, using the session saved by `npm run login`.
// Skipped when no session is saved. Read-only: the write guard is active.

describe('Authenticated (read-only)', () => {
    before(function () {
        cy.task('loadSession', null, { log: false }).then((session) => {
            if (!session) this.skip()
        })
    })

    beforeEach(() => {
        cy.restoreSession()
    })

    it('My Projects loads for the signed-in user', () => {
        // My Projects fetches record counts via POST; the endpoint only reads.
        cy.allowWrite('POST', (path) => path.includes('/ProjectGeneral/project_stats_ajax.php'))

        cy.visit('/index.php?action=myprojects')
        cy.location('host').should('eq', new URL(Cypress.config('baseUrl')).host)
        cy.get('#redcap-home-navbar-collapse').should('be.visible')
        cy.contains(/My Projects/i).should('be.visible')
        cy.get('a[href*="logout=1"]').should('exist')
    })
})
