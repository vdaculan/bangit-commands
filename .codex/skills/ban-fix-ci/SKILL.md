---
name: ban-fix-ci
description: Inspect failing CI across repository providers, fetch the relevant logs, reproduce the failure locally when possible, fix the root cause, and rerun verification until green. Use when the user asks to fix CI, debug failed checks, repair a failed pipeline, make PR checks pass, or investigate build failures on GitHub, GitLab, Bitbucket, Azure DevOps, CircleCI, Buildkite, Jenkins, Vercel, Netlify, Render, Cloudflare, or generic CI.
---

# Ban Fix CI

Fix failing continuous integration from repository truth and provider evidence. Start with inspection, identify the failing job and command, reproduce locally when safe, fix the root cause, then rerun the relevant verification sequence. Do not guess from the provider status alone.

## Workflow

1. Confirm repository context:

```bash
pwd
git rev-parse --show-toplevel
git status --short
git branch --show-current
git remote -v
```

2. Detect the repository provider and CI provider.

Inspect remotes and CI config files:

```bash
git remote get-url origin
find .github .gitlab .circleci .azure-pipelines .buildkite .jenkins .vercel .netlify .render .cloudflare -maxdepth 4 -type f 2>/dev/null
find . -maxdepth 3 -type f \( -name '.gitlab-ci.yml' -o -name 'azure-pipelines*.yml' -o -name 'bitbucket-pipelines.yml' -o -name 'Jenkinsfile' -o -name 'vercel.json' -o -name 'netlify.toml' -o -name 'render.yaml' -o -name 'wrangler.toml' -o -name 'Dockerfile' -o -name 'docker-compose*.yml' \) -print
```

Do not assume GitHub Actions. A GitHub repository may use external CI, and non-GitHub repositories may still expose local workflow files.

3. Fetch failing run details with available tooling.

Use the provider or CI tool that matches the repo:

- GitHub Actions: `gh pr checks`, `gh run list`, `gh run view --log`, `gh run view --json`.
- GitLab CI: `glab ci status`, `glab pipeline list`, `glab pipeline view`, `glab job trace`.
- Bitbucket Pipelines: Bitbucket API or installed CLI; otherwise inspect `bitbucket-pipelines.yml`.
- Azure Pipelines: `az pipelines runs list`, `az pipelines runs show`, `az pipelines runs artifact`.
- CircleCI: `circleci` CLI or API when authenticated; otherwise inspect `.circleci/config.yml`.
- Buildkite: `bk` CLI or API when authenticated; otherwise inspect `.buildkite/`.
- Jenkins: Jenkins URL/API or `Jenkinsfile` when available.
- Vercel, Netlify, Render, Cloudflare: use available provider CLI/API/log tools and local config.
- Generic or unavailable provider: use local CI config and branch diff, then report that remote logs were unavailable.

If tooling is missing, unauthenticated, or the CI provider cannot be identified, do not stop immediately. Continue with local config and ask only if no failing job, command, or log surface can be found.

4. Identify the smallest concrete failure surface:

- Failing job name.
- Failing step name.
- Exact command that failed.
- First meaningful error message.
- Changed files related to the failure.
- Whether the failure is code, test, environment, dependency, cache, secret, permission, or provider configuration related.

Avoid treating downstream errors as the root cause when an earlier command already failed.

5. Reproduce locally when safe.

Prefer the exact failing command from CI. If CI uses an aggregate command, inspect repo scripts and config before running it. For repo-aware verification, use `$ban-run-tests` rules.

Do not run destructive commands, production deployments, real migrations, secret-dependent jobs, release publishing, or external side-effect jobs unless the user explicitly asks.

6. Fix the root cause.

Make the smallest scoped change that addresses the failing job. Preserve unrelated user changes. If the failure is environmental and cannot be fixed in code, document the blocker precisely and recommend the provider-side change.

7. Rerun verification.

Run the exact failing command first if it is fast and local. Then run the full relevant verification sequence from the beginning. If remote CI can be rerun safely and the user expects it, rerun or instruct the user which provider rerun is needed.

8. Report the result:

- Provider and CI system detected.
- Failing job, step, command, and error.
- Root cause.
- Files changed.
- Local commands rerun and result.
- Remote rerun status or remaining provider-side action.

## Provider Rules

### GitHub Actions

Use `gh` when available. Prefer PR checks when on a PR branch; otherwise inspect recent workflow runs for the current branch.

Useful commands:

```bash
gh pr view --json number,title,headRefName,baseRefName,url
gh pr checks
gh run list --branch "$(git branch --show-current)"
gh run view <run-id> --log
```

### GitLab CI

Use `glab` when available and authenticated. Match pipelines to the current branch or merge request.

Useful commands:

```bash
glab mr view
glab pipeline list
glab pipeline view <pipeline-id>
glab job trace <job-id>
```

### Bitbucket Pipelines

Inspect `bitbucket-pipelines.yml` and use Bitbucket API/CLI if configured. Match failed steps to branch or pull request build numbers when available.

### Azure DevOps

Use `az repos` and `az pipelines` only when the project is configured locally. Prefer branch-specific failed runs.

Useful commands:

```bash
az repos pr show --id <id>
az pipelines runs list --branch "$(git branch --show-current)"
az pipelines runs show --id <run-id>
```

### External Deploy CI

For Vercel, Netlify, Render, Cloudflare Pages, or similar platforms, distinguish deploy/build failures from repository checks. Inspect platform config and logs, but do not deploy or promote builds unless explicitly requested.

## Common Failure Classes

- Missing dependency or lockfile drift.
- Version mismatch between local and CI runtime.
- Failing tests caused by changed behavior.
- Lint, typecheck, formatting, or static-analysis failures.
- Flaky tests or timing assumptions.
- Missing environment variables or secret permissions.
- Path, casing, or OS-specific failures.
- Cache, artifact, or workspace setup errors.
- Database, migration, fixture, or service dependency failures.
- CI config syntax or matrix errors.

## Safety

Do not commit, push, rerun remote workflows, cancel jobs, approve deployments, rotate secrets, or change provider settings unless explicitly requested.

Do not print secret values from logs. Report only the key name pattern and the failing access surface.

Do not install dependencies or upgrade packages unless that is the smallest necessary fix and the repository lockfile strategy is clear.

Do not mask a failing test by skipping it, weakening assertions, or reducing CI coverage unless the user explicitly accepts that tradeoff.

If remote logs are unavailable, say exactly what was unavailable and proceed with the local evidence instead of fabricating provider state.
