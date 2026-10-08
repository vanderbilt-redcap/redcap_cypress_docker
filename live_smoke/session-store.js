// Stores the captured SSO session cookies in the macOS login Keychain.
// Secrets are passed to `security` over stdin (interactive mode), never as
// command-line arguments, so they don't show up in `ps` output. Nothing is
// written to disk by this project.

const { execFileSync } = require('child_process')

const SERVICE = 'redcap-live-smoke'

function account(baseUrl) {
    return new URL(baseUrl).host
}

function save(baseUrl, cookies) {
    // base64 avoids any quoting issues inside the `security -i` command line.
    const blob = Buffer.from(JSON.stringify({ savedAt: new Date().toISOString(), cookies })).toString('base64')
    execFileSync('security', ['-i'], {
        input: `add-generic-password -U -s ${SERVICE} -a ${account(baseUrl)} -w ${blob}\n`,
        stdio: ['pipe', 'ignore', 'inherit'],
    })
}

function load(baseUrl) {
    let blob
    try {
        blob = execFileSync('security', ['find-generic-password', '-s', SERVICE, '-a', account(baseUrl), '-w'], {
            stdio: ['ignore', 'pipe', 'ignore'],
        }).toString().trim()
    } catch {
        return null
    }
    return JSON.parse(Buffer.from(blob, 'base64').toString())
}

function remove(baseUrl) {
    try {
        execFileSync('security', ['delete-generic-password', '-s', SERVICE, '-a', account(baseUrl)], { stdio: 'ignore' })
        return true
    } catch {
        return false
    }
}

module.exports = { save, load, remove }
