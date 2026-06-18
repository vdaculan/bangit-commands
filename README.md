# bangit-commands

## Overview

`bangit-commands` is a package of reusable Codex workflow skills for day-to-day repository work. It bundles the `ban-*` command set used to inspect codebases, create issues, manage commits and pull requests, run tests, handle releases, review changes, and keep project workflows consistent across repositories.

## What is included

This repository stores reusable Codex skills under `codex/skills/`. Each skill lives in its own directory and exposes a `SKILL.md` entrypoint.

Current skills:

| Skill | Description |
| --- | --- |
| `ban-address-comments` | Inspect unresolved PR/MR review comments, apply scoped fixes, verify, and optionally prepare or post replies. |
| `ban-audit-repo` | Audit an unfamiliar repository and identify stack, commands, docs, CI, deployment, environment, security, and workflow gaps. |
| `ban-commit` | Inspect the current diff, create a conventional commit, and push the branch. |
| `ban-create-issue` | Create a well-scoped GitHub issue from requested work or current changes. |
| `ban-docs-sync` | Check whether docs need updates after code, config, API, command, or workflow changes. |
| `ban-fix-ci` | Inspect provider CI failures, reproduce them locally when safe, fix the root cause, and rerun verification. |
| `ban-full-flow` | Run the issue-to-branch-to-PR workflow. |
| `ban-marketing` | Generate concise marketing strategy and campaign copy. |
| `ban-mobile-release` | Bump mobile app version metadata, tag the release, and trigger CI/CD distribution. |
| `ban-plan` | Turn feature requests or vague implementation goals into repo-grounded execution plans. |
| `ban-pull-request` | Create a ready GitHub pull request for an issue branch. |
| `ban-release` | Run the repository release workflow. |
| `ban-review` | Review local diffs or provider-hosted PRs/MRs for bugs, regressions, security risks, missing tests, and workflow issues. |
| `ban-rollback` | Assess and execute safe rollback paths for bad commits, releases, tags, migrations, or deployments. |
| `ban-run-tests` | Detect the repository stack, run the right verification sequence, and fix failures until green. |
| `ban-security-check` | Scan diffs for secrets, auth risks, unsafe data access, dependency issues, and risky config. |

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

## Install in Codex

Install the skills by copying the bundled skill directories into your global Codex skills folder:

```bash
mkdir -p ~/.codex/skills
cp -R codex/skills/ban-* ~/.codex/skills/
```

To update an existing installation from this repository, replace the installed `ban-*` skill directories with the current package contents:

```bash
mkdir -p ~/.codex/skills
rm -rf ~/.codex/skills/ban-*
cp -R codex/skills/ban-* ~/.codex/skills/
```

Confirm the skills were installed:

```bash
find ~/.codex/skills -maxdepth 2 -name SKILL.md | sort
```

Restart Codex or open a new thread after installing so the skill inventory reloads.

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
