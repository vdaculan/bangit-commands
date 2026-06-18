# bangit-commands

## Overview

`bangit-commands` is a package of reusable Codex workflow skills for day-to-day repository work. It bundles the `ban-*` command set used to inspect codebases, create issues, manage commits and pull requests, run tests, handle releases, review changes, and keep project workflows consistent across repositories.

## What is included

This repository stores reusable Codex skills under `.codex/skills/`. Each skill lives in its own directory and exposes a `SKILL.md` entrypoint.

Current skills:

| Skill | Description | When to use |
| --- | --- | --- |
| `ban-address-comments` | Inspect unresolved PR/MR review comments, apply scoped fixes, verify, and optionally prepare or post replies. | Use after review feedback lands and you need to address comments or reviewer suggestions. |
| `ban-audit-repo` | Audit an unfamiliar repository and identify stack, commands, docs, CI, deployment, environment, security, and workflow gaps. | Use when entering a new repo or when another workflow needs repo context first. |
| `ban-commit` | Inspect the current diff, create a conventional commit, and push the branch. | Use when current changes are ready to stage, commit, and push. |
| `ban-create-issue` | Create a provider-tracked issue or work item from requested work or current changes. | Use when work needs to be tracked before implementation or linked to a branch, PR, or MR. |
| `ban-docs-sync` | Check whether docs need updates after code, config, API, command, or workflow changes. | Use after behavior, setup, command, API, or workflow changes that may affect documentation. |
| `ban-fix-ci` | Inspect provider CI failures, reproduce them locally when safe, fix the root cause, and rerun verification. | Use when checks, builds, pipelines, or deployment previews fail. |
| `ban-full-flow` | Run the issue-to-branch-to-PR workflow. | Use when local work should become a tracked issue, commit, branch, and pull request in one flow. |
| `ban-marketing` | Generate concise marketing strategy and campaign copy. | Use for launch copy, social posts, ads, offers, creative briefs, or brand messaging. |
| `ban-mobile-release` | Bump mobile app version metadata, tag the release, and trigger CI/CD distribution. | Use for tag-triggered Flutter, React Native, Android, or iOS release distribution. |
| `ban-plan` | Turn feature requests or vague implementation goals into repo-grounded execution plans. | Use before coding when scope, phases, risks, files, and verification steps need definition. |
| `ban-pull-request` | Create a ready GitHub pull request for an issue branch. | Use when committed branch work is ready for a linked PR. |
| `ban-release` | Run the repository release workflow. | Use when publishing a production release, version bump, and release tag. |
| `ban-review` | Review local diffs or provider-hosted PRs/MRs for bugs, regressions, security risks, missing tests, and workflow issues. | Use before commit, merge, or release when you need risk-focused code review. |
| `ban-rollback` | Assess and execute safe rollback paths for bad commits, releases, tags, migrations, or deployments. | Use when a commit, release, deployment, tag, or migration needs recovery. |
| `ban-run-tests` | Detect the repository stack, run the right verification sequence, and fix failures until green. | Use when tests or checks need to run, fail, and be fixed until passing. |
| `ban-security-check` | Scan diffs for secrets, auth risks, unsafe data access, dependency issues, and risky config. | Use before commit, PR, or release when security-sensitive changes need review. |

## Repository layout

```text
.
├── AGENTS.md
├── LICENSE
├── README.md
├── scripts/
│   ├── install.ps1
│   └── install.sh
└── .codex/
    └── skills/
        └── ban-*/
            └── SKILL.md
```

## Install in Codex

Install or update all skills with one command.

macOS, Linux, or Windows with Git Bash/WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/vdaculan/bangit-commands/main/scripts/install.sh | bash
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/vdaculan/bangit-commands/main/scripts/install.ps1 | iex
```

If you already cloned this repository, run the local installer instead.

macOS, Linux, or Windows with Git Bash/WSL:

```bash
./scripts/install.sh
```

Windows PowerShell:

```powershell
.\scripts\install.ps1
```

The installer writes the bundled `ban-*` skills to `~/.codex/skills`. Open a new Codex thread after installing so the skill inventory reloads.

To update later, rerun the same install command. The installer fetches the latest package and replaces the installed `ban-*` skills.

## Validation

There is no build step. Use these checks before committing changes:

```bash
find .codex/skills -maxdepth 2 -name SKILL.md | sort
bash -n scripts/install.sh
pwsh -NoProfile -Command "[scriptblock]::Create((Get-Content -Raw scripts/install.ps1)) | Out-Null"
git diff --check
git status --short
```

## Contributing

Add new skills as `.codex/skills/<skill-name>/SKILL.md` using lowercase kebab-case names. Keep each skill focused on one workflow, include clear trigger language in the front matter, and document commands in executable order.

See `AGENTS.md` for contributor and agent-specific guidelines.
