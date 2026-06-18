---
name: ban-docs-sync
description: Compare repository changes against documentation and update README, AGENTS, CONTRIBUTING, changelog, env examples, API docs, migration notes, release notes, and setup guides when behavior, commands, configuration, environment variables, routes, public APIs, or workflows change. Use when the user asks to sync docs, check docs, update docs after code changes, prepare docs for a PR, or verify documentation before commit/release.
---

# Ban Docs Sync

Keep repository documentation aligned with actual code, config, commands, and workflows. Default to inspecting the diff first, then updating only docs that are affected by the changed behavior.

## Workflow

1. Confirm context:

```bash
pwd
git rev-parse --show-toplevel
git status --short
git diff --stat
git diff --name-status
```

2. Inspect documentation surfaces:

```bash
find . -maxdepth 4 -type f \( -iname 'README*' -o -iname 'AGENTS.md' -o -iname 'CONTRIBUTING*' -o -iname 'CHANGELOG*' -o -iname 'RELEASE*' -o -iname '*.md' -o -iname '.env.example' -o -iname 'openapi.*' -o -iname 'swagger.*' \) -print
```

Also inspect docs generated or consumed by the repo, such as `docs/`, `content/`, API schemas, route manifests, migration notes, or package-specific README files.

3. Decide whether docs need changes.

Docs usually need updates when the diff changes:

- Setup, install, build, test, lint, or release commands.
- Environment variables, secrets, config files, feature flags, or provider setup.
- Public APIs, endpoints, schemas, events, request/response shapes, or error behavior.
- User-facing workflows, permissions, roles, navigation, pricing, policies, or copy.
- Database migrations, data import/export, background jobs, queues, cron jobs, or storage.
- CI/CD, deployment, branch, tag, release, or rollback process.
- Contributor or agent workflows in `AGENTS.md`.

Docs usually do not need updates for purely internal refactors, formatting-only changes, or tests that do not alter documented behavior. State that no docs update is needed when that is the correct outcome.

4. Update docs from repository truth.

Read source files, configs, scripts, and tests before writing docs. Do not document aspirational behavior as shipped behavior. If a feature is planned but not implemented, label it as planned or put it in a planning doc, not the runtime README.

Prefer these locations:

- `README.md` for project overview, setup, commands, and common usage.
- `AGENTS.md` for contributor and agent instructions.
- `.env.example` for environment variables with safe placeholders.
- `docs/` for architecture, operations, migrations, release notes, or detailed workflows.
- API schema files for machine-readable contracts.
- `CHANGELOG.md` or release notes only when the repo already uses them or the user asks.

5. Verify documentation claims.

Run cheap checks:

```bash
git diff --check
find . -maxdepth 4 -type f \( -iname 'README*' -o -iname 'AGENTS.md' -o -iname '*.md' \) -print
```

If docs mention commands, verify those commands exist in package scripts, Makefile targets, CI config, or repository guidance. Do not run expensive builds unless the user asks.

6. Report the result:

- Docs changed.
- Behavior or config each doc update reflects.
- Docs intentionally left unchanged and why.
- Verification performed.

## Content Rules

Keep documentation concise and actionable. Use commands, paths, and examples where they prevent ambiguity.

Do not duplicate large blocks of source configuration into docs. Link or summarize instead.

Use safe placeholder values for secrets:

```text
API_KEY=replace-me
DATABASE_URL=postgres://user:password@localhost:5432/app
```

Do not include real tokens, private URLs, certificate contents, or production credentials.

## PR and Release Notes

For PR preparation, ensure docs explain the changed behavior, not just the implementation.

For release preparation, summarize user-visible changes, migrations, breaking changes, deployment notes, and rollback considerations when those surfaces changed.

## Safety

Do not update docs to match broken or unverified assumptions.

Do not edit legal, policy, or public-facing copy without preserving the source-of-truth flow used by the repository.

Do not create a new docs structure when a local pattern already exists.

Do not remove warnings, setup prerequisites, or security notes unless the underlying risk is actually gone.
