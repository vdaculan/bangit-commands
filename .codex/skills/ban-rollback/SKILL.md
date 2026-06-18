---
name: ban-rollback
description: Assess and execute safe rollback or recovery workflows for bad commits, failed releases, broken deployments, bad tags, mobile CI/CD releases, migrations, and provider deployments. Use when the user asks to rollback, revert, undo a release, recover from a bad deploy, remove or replace a bad tag, create a hotfix rollback, restore a previous version, or decide the safest rollback path across GitHub, GitLab, Bitbucket, Azure DevOps, Vercel, Netlify, Render, Cloudflare, mobile CI/CD, or generic Git repositories.
---

# Ban Rollback

Recover from a bad change without destroying repository history by default. Prefer forward-only fixes such as revert commits, rollback branches, provider rollback actions, or hotfix releases. Do not reset, force-push, delete remote tags, roll back databases, or change provider deployments unless the user explicitly confirms that action.

## Workflow

1. Confirm context and blast radius:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
git log --oneline --decorate -10
git tag --points-at HEAD
```

2. Identify what needs rollback:

- Local uncommitted change.
- One or more commits on a branch.
- A merged PR/MR.
- A pushed release tag.
- A failed or bad provider deployment.
- A mobile tag-triggered release.
- A migration, data change, or feature flag rollout.

Ask for the target only if it cannot be inferred safely. Never guess the rollback target when multiple releases, tags, or deployments are plausible.

3. Gather provider and release evidence:

```bash
git remote get-url origin
git branch -r
git tag --sort=-creatordate | head -20
git log --oneline --decorate --graph --max-count=30
find .github .gitlab .circleci .codemagic .bitrise .vercel .netlify .render .cloudflare -maxdepth 4 -type f 2>/dev/null
find . -maxdepth 3 -type f \( -name 'codemagic.yaml' -o -name 'bitrise.yml' -o -name 'vercel.json' -o -name 'netlify.toml' -o -name 'render.yaml' -o -name 'wrangler.toml' -o -name '.gitlab-ci.yml' -o -name 'bitbucket-pipelines.yml' \) -print
```

Use provider tooling when available:

- GitHub: `gh pr view`, `gh release view`, `gh run list`, `gh api`.
- GitLab: `glab mr view`, `glab release view`, `glab pipeline list`.
- Bitbucket: Bitbucket API or CLI for pull requests, tags, and deployments.
- Azure DevOps: `az repos pr show`, `az pipelines runs list`, release/deployment tooling when configured.
- Vercel, Netlify, Render, Cloudflare: provider CLI/API for deployment history and rollback controls.
- Codemagic, Bitrise, Fastlane, EAS: inspect release/build history when tooling or dashboards are available.

If provider state is unavailable, continue with Git evidence and clearly state what could not be verified.

4. Choose the safest recovery strategy:

- Uncommitted local mistake: use targeted edits or ask before discarding files.
- Bad unmerged branch commit: create a new revert commit or amend only if the user explicitly wants history rewriting.
- Bad merged commit or PR/MR: create a revert commit against the release branch.
- Bad release tag before CI/CD consumed it: stop and ask before deleting or replacing any remote tag.
- Bad release tag after CI/CD consumed it: prefer a new patch release or provider rollback over tag replacement.
- Bad deployment with unchanged code: use provider rollback if available and explicitly approved.
- Bad mobile distribution: prefer a new version/tag or provider-side rollback; do not reuse a consumed mobile version/tag unless the platform workflow supports it.
- Bad migration/data change: stop and create a data recovery plan; do not run rollback migrations against production without explicit confirmation.

5. Prepare and verify the rollback.

For Git revert:

```bash
git revert <commit>
git diff --stat
git diff
```

For merge commits, inspect parent order first and use `git revert -m <parent> <merge-commit>` only when the mainline parent is known.

For a new mobile patch release, follow `$ban-mobile-release` rules after the fix is committed.

For provider rollback, show the exact provider action and target deployment/version before executing it.

6. Run verification.

Use `$ban-run-tests` rules for repository checks. For incident rollback, also verify the specific failing path, deployment target, or CI/CD status when tooling is available.

7. Report the outcome:

- Rollback target.
- Chosen strategy and why.
- Commands executed.
- Files changed.
- New commit, tag, or deployment target.
- Verification results.
- Remaining provider-side or operational actions.

## Decision Rules

Prefer this order:

1. Fix forward if it is faster and lower risk.
2. Revert with a new commit if the bad change is already shared.
3. Create a patch release if a release tag was consumed.
4. Use provider rollback when the provider has a safe deployment rollback model.
5. Rewrite history or delete remote tags only with explicit user confirmation and a clear reason.

## Mobile Release Notes

For tag-triggered mobile CI/CD, tags are often consumed by Codemagic, Bitrise, Fastlane, EAS, TestFlight, Play tracks, or Firebase App Distribution. Do not delete and recreate a consumed tag casually. Prefer bumping to a new patch version and pushing a new tag.

If a mobile build failed because of signing, provisioning, store credentials, or provider setup, report the provider blocker instead of changing unrelated code.

## Database and Data Safety

Treat migrations, backfills, deletes, imports, and billing or entitlement changes as high-risk. Before rollback, identify:

- Whether data was already changed.
- Whether rollback is reversible.
- Whether a backup or point-in-time restore exists.
- Whether users can keep writing during rollback.
- Whether a feature flag can stop the bleeding first.

Do not run destructive data rollback commands without explicit confirmation.

## Safety

Do not use `git reset --hard`, force push, delete remote tags, close releases, cancel production deployments, roll back databases, or change provider settings unless explicitly requested.

Do not hide a rollback by rewriting public history unless the user understands the impact.

Do not declare rollback complete until Git state and relevant provider/deployment state are verified or clearly marked unavailable.

Do not discard unrelated user changes.
