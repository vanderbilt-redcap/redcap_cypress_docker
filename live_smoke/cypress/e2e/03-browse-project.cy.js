// Browses the first project on My Projects the way a user would, pausing on each
// page so the video shows it. Read-only: page views only, write guard active.
// Note: REDCap records each page view in its own log. Skipped when no session is saved.

const PAUSE_MS = 3000

describe('Browse first project (read-only)', () => {
    before(function () {
        cy.task('loadSession', null, { log: false }).then((session) => {
            if (!session) this.skip()
        })
    })

    beforeEach(() => {
        cy.restoreSession()
    })

    it('visits Project Home, Record Status Dashboard, Codebook and Reports', () => {
        // My Projects fetches record counts via POST; the endpoint only reads.
        cy.allowWrite('POST', (path) => path.includes('/ProjectGeneral/project_stats_ajax.php'))

        cy.visit('/index.php?action=myprojects')
        cy.get('#redcap-home-navbar-collapse').should('be.visible')
        cy.wait(PAUSE_MS)

        cy.get('a[href*="/index.php?pid="]').first().then(($link) => {
            const href = $link.attr('href')
            const [, base, pid] = href.match(/^(.*\/redcap_v[\d.]+)\/index\.php\?pid=(\d+)/)
            cy.log(`First project: "${$link.text().trim()}" (pid ${pid})`)

            const pages = [
                ['Project Home', `${base}/index.php?pid=${pid}`],
                ['Record Status Dashboard', `${base}/DataEntry/record_status_dashboard.php?pid=${pid}`],
                ['Codebook', `${base}/Design/data_dictionary_codebook.php?pid=${pid}`],
                ['Data Exports, Reports, and Stats', `${base}/DataExport/index.php?pid=${pid}`],
            ]

            pages.forEach(([name, url]) => {
                cy.log(name)
                cy.visit(url)
                cy.location('host').should('eq', new URL(Cypress.config('baseUrl')).host)
                cy.get('#center').should('be.visible')
                cy.wait(PAUSE_MS)
            })
        })
    })
})
