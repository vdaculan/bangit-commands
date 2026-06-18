---
name: ban-security-check
description: Review repository changes for security risks, leaked secrets, unsafe auth or permission changes, exposed environment variables, risky data access, dependency vulnerabilities, mobile signing mistakes, and deployment configuration hazards. Use when the user asks for a security check, secrets scan, auth review, permission review, dependency risk review, pre-commit security pass, or release security sanity check.
---

# Ban Security Check

Run a practical security review grounded in the live repository. Default to read-only inspection. Do not rotate secrets, change provider settings, install scanners, run destructive commands, or edit files unless the user explicitly asks for fixes.

## Workflow

1. Confirm context:

```bash
pwd
git rev-parse --show-toplevel
git status --short
git branch --show-current
git remote -v
```

2. Identify the review scope:

- Working tree: inspect `git diff` and `git diff --staged`.
- Branch review: inspect `git diff <base>...HEAD`.
- Release review: inspect recent release diff, version bump, config changes, and deployment surfaces.
- Specific files: inspect requested files plus surrounding auth, config, schema, and test code.

3. Gather evidence:

```bash
git diff --stat
git diff --name-status
git diff --check
git diff
git diff --staged --stat
git diff --staged
find . -maxdepth 4 -type f \( -name '.env*' -o -name '*secret*' -o -name '*key*' -o -name '*credential*' -o -name '*service-account*' -o -name 'GoogleService-Info.plist' -o -name 'google-services.json' \) -print
git check-ignore .env .env.local .env.production 2>/dev/null
```

Never print secret values. If a potential secret appears, report the file, key pattern, and risk only.

4. Check high-risk areas:

- Secrets: API keys, tokens, private keys, certificates, service accounts, signing files, `.env` files, mobile keystores, provisioning profiles.
- Auth/session: login, logout, token exchange, refresh, password reset, OAuth redirects, cookies, JWT validation, session persistence.
- Authorization: role checks, ownership checks, admin routes, row-level security, object access, policy bypasses.
- Data access: SQL, ORM filters, multi-tenant scoping, migrations, deletes, bulk updates, file uploads, export endpoints.
- Input/output: validation, escaping, path traversal, SSRF, open redirects, command execution, unsafe deserialization.
- Client exposure: public env variables, frontend config, mobile bundled files, analytics keys, debug flags.
- Dependencies: lockfile drift, new packages, vulnerable or abandoned packages, lifecycle scripts, native build scripts.
- CI/deploy: workflow permissions, secret scopes, deployment branches, tag triggers, production credentials, artifact uploads.

5. Use repository tools when available.

Prefer configured project commands and scanners already present in the repo. Examples:

```bash
npm audit
pnpm audit
composer audit
pip-audit
bundle audit
cargo audit
dotnet list package --vulnerable
```

Run these only when the repo uses the matching ecosystem and the command is safe locally. Do not install scanner tools unless the user approves.

6. Classify findings:

- `P0` - active secret leak, data exposure, auth bypass, destructive production risk.
- `P1` - likely exploitable issue or unsafe permission/data-access change.
- `P2` - meaningful hardening gap, missing test for security-sensitive behavior, risky config.
- `P3` - low-risk hygiene issue or documentation/config clarity.

7. Report findings first.

Each finding must include:

- Severity.
- File and line reference when possible.
- Concrete exploit or failure mode.
- Recommended fix.
- Whether it is confirmed from evidence or inferred from risk.

If no issues are found, say so and list unverified areas, such as provider secrets or remote branch protection.

## Fixing Rules

If the user asks to fix issues:

- Make the smallest scoped change.
- Add tests for auth, authorization, tenancy, or validation changes when practical.
- Preserve unrelated changes.
- Never replace a real leaked secret with another real secret.
- Remove secrets from tracked files, add safe placeholders, and update ignore rules when needed.
- Tell the user when history rewriting or provider-side secret rotation is required; do not do it without explicit approval.

## Safety

Do not reveal secret values.

Do not rotate keys, revoke tokens, change cloud settings, or rewrite Git history unless explicitly requested.

Do not declare a dependency safe solely because local audit tooling is unavailable.

Do not treat every warning as a vulnerability; tie each finding to practical risk.
