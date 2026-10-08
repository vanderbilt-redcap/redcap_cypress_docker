// Anonymous, read-only checks. Plain HTTP GETs only - never enters the SSO pages.

describe('Public endpoints', () => {
    it('unauthenticated access is redirected to SSO', () => {
        cy.request({ url: '/index.php?action=myprojects', followRedirect: false }).then((res) => {
            expect(res.status).to.eq(302)
            expect(res.redirectedToUrl, 'redirect target').to.match(/SAML2|Shibboleth|idp/i)
            expect(new URL(res.redirectedToUrl).host, 'redirected off the REDCap host').to.not.eq(new URL(Cypress.config('baseUrl')).host)
        })
    })

    it('API endpoint is up (GET returns REDCap\'s 501 "not implemented")', () => {
        cy.request({ url: '/api/', failOnStatusCode: false }).then((res) => {
            expect(res.status).to.eq(501)
            expect(res.body).to.contain('The requested method is not implemented')
        })
    })

    it('survey endpoint is public and reports the REDCap version', () => {
        cy.request('/surveys/?s=smoketest').then((res) => {
            expect(res.status).to.eq(200)
            const versions = [...new Set(res.body.match(/redcap_v\d+\.\d+\.\d+/g))]
            expect(versions, 'one REDCap version in asset paths').to.have.length(1)

            const version = versions[0].replace('redcap_v', '')
            cy.log(`REDCap version: ${version}`)
            cy.env(['EXPECTED_VERSION']).then(({ EXPECTED_VERSION }) => {
                if (EXPECTED_VERSION) expect(version).to.eq(EXPECTED_VERSION)
            })

            const script = res.body.match(/src=["']([^"']*redcap_v[^"']+\.js[^"']*)["']/)
            expect(script, 'a versioned script tag').to.not.be.null
            cy.request(script[1]).its('status').should('eq', 200)
        })
    })
})
