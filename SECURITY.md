# Security

## Supported code

The `codex-limit-statusline` branch contains a config-only installer. It does
not replace the Codex binary, read Codex authentication files, install
packages, or make network requests after startup.

The `feature/status-line-rate-limit-alerts` branch is an experimental source
patch based on an older OpenAI Codex revision. Do not treat it as a maintained
or security-supported Codex distribution.

## Installation safety

- Download scripts from an immutable commit URL.
- Verify the published SHA-256 digest before execution.
- Review a downloaded script before running it when the machine contains
  sensitive credentials or source code.
- The installers reject a symbolic-link `config.toml`.
- Unix installers write `config.toml` and backups with mode `600`.
- Existing configs are backed up before replacement.

## Reporting a vulnerability

Do not publish credentials or exploit details in a public commit.
Report vulnerabilities through GitHub's private security advisory form:

https://github.com/uri-uri/codex/security/advisories/new
