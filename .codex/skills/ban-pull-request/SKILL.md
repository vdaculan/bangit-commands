---
name: ban-pull-request
description: Create a ready pull request or merge request for the current tracked-work branch across GitHub, GitLab, Bitbucket, Azure DevOps, or generic Git providers. Link it to the existing issue, ticket, or work item inferred from the branch name when the provider supports linking. Use when the user asks to open, create, publish, or prepare a PR or MR for current work.
---

# Ban Pull Request

Create one ready pull request or merge request for the current tracked-work branch. Do not assume GitHub. Detect the Git provider, verify the linked issue, ticket, or work item when possible, push the branch, avoid duplicates, and create the PR/MR using provider-native tooling.

## Workflow

1. Inspect the current repository state and remotes:

```bash
git status --short
git branch --show-current
git remote -v
git remote get-url origin
git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true
```

If the current directory is not a Git repository, stop and report that a PR/MR cannot be opened.

2. Detect the repository provider from the remote URL and available authenticated tooling:

- GitHub: `github.com`, GitHub Enterprise hosts, or available `gh`.
- GitLab: `gitlab.com`, self-hosted GitLab hosts, or available `glab`.
- Bitbucket: `bitbucket.org`, Bitbucket Server/Data Center hosts, or provider API/CLI.
- Azure DevOps: `dev.azure.com`, `*.visualstudio.com`, or configured `az repos`.
- Generic Git: unknown provider, unsupported forge, or missing authenticated tooling.

Use the provider tool that matches the repository. If the provider cannot be identified or authenticated, do not fabricate provider state. Continue with local Git checks and stop before remote PR/MR creation with the exact missing provider or credential.

3. Determine the default target branch.

Prefer provider metadata when available. Otherwise use `origin/HEAD`, then fall back to `main` only if the remote default branch cannot be detected.

Examples:

```bash
gh repo view --json defaultBranchRef,url
glab repo view
git symbolic-ref --quiet --short refs/remotes/origin/HEAD
```

4. Confirm the current branch is not the repository default branch or `main`.

If the branch is `main` or the default branch, stop and report that PRs or MRs must be opened from a tracked-work branch.

5. Infer the linked artifact identity from the current branch name.

Use branch names created by `ban-create-issue`, such as:

- `feature/12-google-sso-login`
- `fix/34-crash-on-launch`
- `docs/45-onboarding-guide`
- `chore/56-update-firebase-config`
- `feature/ab-123-login-flow`

Read the first numeric ID or provider key after the branch prefix as the linked artifact ID. Preserve provider keys such as `AB-123` for Azure Boards or Jira-backed workflows. If no ID or key is found, stop and tell the user to run `ban-create-issue` first or provide the target issue, ticket, or work item.

6. Validate the linked artifact exists and is open when provider tooling supports it.

### GitHub

```bash
gh issue view <issue-number> --json number,title,url,state,labels,body
```

### GitLab

```bash
glab issue view <issue-number>
```

### Bitbucket

Use an installed Bitbucket CLI or authenticated Bitbucket API to fetch the issue or Jira ticket when configured.

### Azure DevOps

```bash
az boards work-item show --id <work-item-id>
```

If the artifact is closed, resolved, done, or cannot be found, stop and report the problem. If the provider does not expose issues or work items through available tooling, continue only when the branch ID is clear and report that artifact validation was unavailable.

Use returned labels, tags, or classification fields as the source of truth for PR/MR metadata when the provider supports copying them. Preserve label and tag names exactly as the provider returns them.

7. If the worktree has uncommitted changes, explicitly use the existing `$ban-commit` workflow to commit and push the current work.

Do not duplicate the commit-message, staging, commit, or push rules in this skill. Let `ban-commit` handle dirty-worktree commit behavior.

8. If the worktree is clean, ensure the current branch is pushed to `origin`:

```bash
git push -u origin <branch>
```

9. Check for an existing open PR/MR for the branch.

### GitHub

```bash
gh pr list --head <branch> --state open --json number,title,url
```

### GitLab

```bash
glab mr list --source-branch <branch> --state opened
```

### Bitbucket

Use provider CLI/API to list open pull requests whose source branch is `<branch>`.

### Azure DevOps

```bash
az repos pr list --source-branch <branch> --status active
```

If an open PR/MR already exists, report its URL and do not create a duplicate.

10. Generate PR/MR content from the linked artifact plus the actual branch changes or commits.

Use a readable title-case PR/MR title without the branch prefix. Keep it descriptive and specific.

The body must include these sections:

```markdown
## Summary
<short factual summary>

## Changes
- <change 1>
- <change 2>

## Validation
- <command or check performed>

<provider-native closing or linking reference>
```

Use the provider-native closing or linking syntax:

- GitHub: `Closes #<issue-number>` for same-repository issues.
- GitLab: `Closes #<issue-number>` for same-project issues, or the full cross-project issue reference when needed.
- Bitbucket: use the repository issue or Jira smart-commit/link syntax configured for the workspace; if unknown, include the artifact URL without claiming it will auto-close.
- Azure DevOps: include `AB#<work-item-id>` or `Fixes AB#<work-item-id>` when supported by the project process.
- Generic Git: include the artifact URL or ID only if the user provided it.

Do not claim the issue, ticket, or work item will auto-close unless the provider syntax is known and supported for that repository.

11. Create a ready PR/MR against the repository default branch.

### GitHub

```bash
gh pr create \
  --base <default-branch> \
  --head <branch> \
  --title "<pr-title>" \
  --body "<pr-body>" \
  --assignee vdaculan \
  --label "<issue-label-1>" \
  --label "<issue-label-2>"
```

Include one `--label "<label-name>"` flag per linked issue label. If the linked issue has no labels, omit the `--label` flags.

### GitLab

```bash
glab mr create \
  --target-branch <default-branch> \
  --source-branch <branch> \
  --title "<mr-title>" \
  --description "<mr-body>" \
  --assignee "vdaculan" \
  --label "<issue-label-1>" \
  --label "<issue-label-2>"
```

If GitLab labels or assignee lookup fail because the project does not support them or the identity differs, retry without the unsupported flags and report what was skipped.

### Bitbucket

Use an authenticated Bitbucket CLI or API to create a ready pull request with source branch `<branch>`, destination branch `<default-branch>`, title, body, reviewer or assignee when supported, and the linked artifact reference.

### Azure DevOps

```bash
az repos pr create \
  --source-branch <branch> \
  --target-branch <default-branch> \
  --title "<pr-title>" \
  --description "<pr-body>" \
  --work-items <work-item-id>
```

Add reviewers only when the user requested reviewers or the repository has an established convention. Do not assume `vdaculan` is a valid Azure DevOps identity.

### Generic Git

Do not create a fake PR/MR. Report the pushed branch, target branch, generated title/body, and the provider details needed to open the request.

12. Report the PR/MR URL, provider, linked artifact URL or ID, base branch, head branch, assignee or reviewer fields applied, labels/tags copied or skipped, and whether `ban-commit` was used.

## Safety

Do not create draft PRs or draft MRs by default.

Do not create a PR/MR from `main` or the repository default branch.

Do not create a new issue, ticket, or work item. This skill expects existing tracked work from `ban-create-issue`.

Do not create duplicate PRs or MRs for the same branch.

Do not infer PR/MR labels from branch type or commit content. Labels and tags must mirror the linked provider artifact exactly when copied.

Do not amend commits, reset, restore, discard, or revert changes.

Do not manually reimplement `ban-commit` behavior. If changes need committing, invoke or follow `$ban-commit`.

Do not assume GitHub labels, assignees, closing keywords, or issue numbers work on other providers.
