# bangit-commands

Custom Codex skills for streamlining development workflows, automating Git operations, enforcing repository standards, and maintaining a consistent process across projects.

## What is included

This repository stores reusable Codex skills under `codex/skills/`. Each skill lives in its own directory and exposes a `SKILL.md` entrypoint.

Current skills:

- `ban-address-comments` - inspect unresolved PR/MR review comments, apply scoped fixes, verify, and optionally prepare or post replies.
- `ban-audit-repo` - audit an unfamiliar repository and identify stack, commands, docs, CI, deployment, environment, security, and workflow gaps.
- `ban-commit` - inspect the current diff, create a conventional commit, and push the branch.
- `ban-create-issue` - create a well-scoped GitHub issue from requested work or current changes.
- `ban-docs-sync` - check whether docs need updates after code, config, API, command, or workflow changes.
- `ban-fix-ci` - inspect provider CI failures, reproduce them locally when safe, fix the root cause, and rerun verification.
- `ban-full-flow` - run the issue-to-branch-to-PR workflow.
- `ban-marketing` - generate concise marketing strategy and campaign copy.
- `ban-mobile-release` - bump mobile app version metadata, tag the release, and trigger CI/CD distribution.
- `ban-plan` - turn feature requests or vague implementation goals into repo-grounded execution plans.
- `ban-pull-request` - create a ready GitHub pull request for an issue branch.
- `ban-release` - run the repository release workflow.
- `ban-review` - review local diffs or provider-hosted PRs/MRs for bugs, regressions, security risks, missing tests, and workflow issues.
- `ban-rollback` - assess and execute safe rollback paths for bad commits, releases, tags, migrations, or deployments.
- `ban-run-tests` - detect the repository stack, run the right verification sequence, and fix failures until green.
- `ban-security-check` - scan diffs for secrets, auth risks, unsafe data access, dependency issues, and risky config.

## Repository layout

```text
.
├── AGENTS.md
├── LICENSE
├── README.md
└── codex/
    └── skills/
        └── ban-*/
            └── SKILL.md
```

## Validation

There is no build step. Use these checks before committing changes:

```bash
find codex/skills -maxdepth 2 -name SKILL.md | sort
git diff --check
git status --short
```

## Contributing

Add new skills as `codex/skills/<skill-name>/SKILL.md` using lowercase kebab-case names. Keep each skill focused on one workflow, include clear trigger language in the front matter, and document commands in executable order.

See `AGENTS.md` for contributor and agent-specific guidelines.
