---
name: ban-review
description: Review local changes, branch diffs, or provider-hosted pull requests and merge requests for bugs, regressions, security risks, missing tests, and unclear behavior. Use when the user asks for a code review, PR review, MR review, diff audit, risk review, or wants feedback before commit, merge, or release across GitHub, GitLab, Bitbucket, Azure DevOps, or generic Git remotes.
---

# Ban Review

Review code from repository truth. Default to read-only analysis. Do not edit files, stage changes, commit, push, approve, request changes, or post provider comments unless the user explicitly asks.

## Workflow

1. Confirm repository context:

```bash
pwd
git rev-parse --show-toplevel
git status --short
git branch --show-current
git remote -v
```

If the current directory is not a Git repository, review only the files or patch the user provided and clearly state that Git context is unavailable.

2. Identify the review target:

- Working tree changes: use `git diff` plus `git diff --staged`.
- Current branch against base: detect the base branch, then use `git diff <base>...HEAD`.
- Provider PR/MR: use the provider URL, issue number, branch name, or available CLI to fetch title, body, changed files, comments, and diff.
- Specific files: review only the requested files and note the narrowed scope.

3. Detect provider without assuming GitHub:

```bash
git remote get-url origin
git branch -r
```

Use the remote host and available authenticated tooling:

- GitHub: `gh pr view`, `gh pr diff`, `gh pr checks`, and `gh api` when available.
- GitLab: `glab mr view`, `glab mr diff`, `glab ci view`, or GitLab API tooling when available.
- Bitbucket: provider URL/API or installed Bitbucket CLI tooling when available.
- Azure DevOps: `az repos pr show`, `az repos pr diff`, `az pipelines` when configured.
- Generic Git or unsupported provider: fall back to local branch diffs and clearly report that provider metadata was unavailable.

If provider tooling is missing or unauthenticated, do not block the review. Use the local diff and state which provider details were not inspected.

4. Gather review evidence:

```bash
git diff --stat
git diff --name-status
git diff --check
git diff
git diff --staged --stat
git diff --staged
```

For branch reviews, also inspect:

```bash
git merge-base HEAD <base>
git diff --stat <base>...HEAD
git diff <base>...HEAD
```

Read surrounding files, tests, schemas, routes, migrations, configs, and docs needed to validate behavior. Do not review from the patch alone when nearby code changes the interpretation.

5. Prioritize findings:

- Correctness bugs and behavioral regressions.
- Security, auth, permission, privacy, or secret-handling risks.
- Data loss, migration, transaction, concurrency, or idempotency risks.
- Missing or weak tests for changed behavior.
- Broken build, lint, type, or CI expectations.
- Provider workflow issues, such as missing linked issue, stale branch, failing checks, unresolved comments, or wrong target branch.

6. Optionally run verification only when safe and relevant.

Prefer project-defined commands from `package.json`, `pubspec.yaml`, `.sln`, `pyproject.toml`, `composer.json`, `Makefile`, or CI config. Do not run destructive, stateful, deployment, migration, or dependency-install commands unless explicitly requested.

## Base Branch Detection

Prefer the provider target branch for PR/MR reviews. For local branch reviews, detect the base in this order:

1. Upstream tracking branch if it clearly represents the review base.
2. Remote default branch from `git remote show origin` or `refs/remotes/origin/HEAD`.
3. Common protected branches: `main`, `master`, `develop`, `dev`.
4. User-specified base branch.

If the base cannot be identified safely, ask for it or review only unstaged/staged changes.

## Report Format

Use code-review style output:

1. Findings first, ordered by severity.
2. Each finding must include file and line references when available.
3. Explain the concrete failure mode, not just style preference.
4. Include open questions or assumptions after findings.
5. Include a short verification note at the end.

Severity labels:

- `P0` - release blocker, data loss, active security issue, or production outage risk.
- `P1` - likely bug, broken workflow, serious regression, or unsafe behavior.
- `P2` - missing test, edge-case bug, provider workflow issue, or maintainability risk with practical impact.
- `P3` - minor improvement, clarity issue, or low-risk cleanup.

If no issues are found, say that clearly and mention remaining test gaps or unverified areas.

## Provider Review Notes

For provider-hosted reviews, inspect metadata when available:

- Title and description match the actual diff.
- Target branch is correct.
- Linked issue or ticket is present when the repo workflow expects it.
- CI/checks status is visible and failures are called out.
- Review comments or unresolved threads are considered when available.
- Labels, assignees, milestones, or reviewers are checked only when relevant to the repo workflow.

Do not post review comments to the provider unless the user explicitly asks. If asked to post comments, keep comments concise, actionable, and tied to exact changed lines.

## Safety

Do not approve, request changes, merge, close, or modify PRs/MRs during review unless explicitly requested.

Do not reveal secret values found during review. Report only the file, key name pattern, and risk.

Do not treat formatting preferences as findings unless they cause real inconsistency, broken tooling, or maintainability cost.

Do not fabricate provider state. If provider metadata cannot be fetched, say so and continue with the local evidence.
