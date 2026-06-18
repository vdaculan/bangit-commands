---
name: ban-pull-request
description: Create a ready GitHub pull request for the current issue branch, link it to the existing GitHub issue inferred from the branch name, and ensure the linked issue closes when the PR is merged. Use when the user asks to open, create, publish, or prepare a PR for current work.
---

# Ban Pull Request

Create one ready GitHub pull request for the current issue branch. Link the PR to the existing issue by including a GitHub closing keyword in the PR body, assign it to `vdaculan`, and copy the issue labels to the PR.

## Workflow

1. Inspect the current repository state:

```bash
git status --short
git branch --show-current
gh repo view --json nameWithOwner,defaultBranchRef,url
```

2. Confirm the current branch is not the repository default branch or `main`.

If the branch is `main` or the default branch, stop and report that PRs must be opened from an issue branch.

3. Infer the linked issue number from the current branch name.

Use branch names created by `ban-create-issue`, such as:

- `feature/12-google-sso-login`
- `fix/34-crash-on-launch`
- `docs/45-onboarding-guide`
- `chore/56-update-firebase-config`

Read the first number after the branch prefix as the issue number. If no issue number is found, stop and tell the user to run `ban-create-issue` first.

4. Validate the linked issue exists and is open:

```bash
gh issue view <issue-number> --json number,title,url,state,labels,body
```

If the issue is closed or cannot be found, stop and report the problem.

Use the returned `labels` list as the source of truth for PR labels. Preserve each label name exactly as GitHub returns it, including spaces or special characters.

5. If the worktree has uncommitted changes, explicitly use the existing `$ban-commit` workflow to commit and push the current work.

Do not duplicate the commit-message, staging, commit, or push rules in this skill. Let `ban-commit` handle dirty-worktree commit behavior.

6. If the worktree is clean, ensure the current branch is pushed to `origin`:

```bash
git push -u origin <branch>
```

7. Check for an existing open PR for the branch:

```bash
gh pr list --head <branch> --state open --json number,title,url
```

If an open PR already exists, report its URL and do not create a duplicate.

8. Generate PR content from the linked issue plus the actual branch changes or commits.

Use a readable title-case PR title without the branch prefix. Keep it descriptive and specific.

The PR body must include these sections:

```markdown
## Summary
<short factual summary>

## Changes
- <change 1>
- <change 2>

## Validation
- <command or check performed>

Closes #<issue-number>
```

Use `Closes #<issue-number>` exactly so GitHub closes the linked issue when the PR is merged into the default branch.

9. Create a ready PR against the repository default branch, assign it to `vdaculan`, and copy the linked issue labels:

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

Include one `--label "<label-name>"` flag per linked issue label. If the linked issue has no labels, omit the `--label` flags, create the PR with `--assignee vdaculan`, and report that no labels were copied.

10. Report the PR URL, linked issue URL, base branch, head branch, assignee `vdaculan`, labels copied from the issue, and whether `ban-commit` was used.

## Safety

Do not create draft PRs by default.

Do not create a PR from `main` or the repository default branch.

Do not create a new issue. This skill expects an existing issue from `ban-create-issue`.

Do not create duplicate PRs for the same branch.

Do not infer PR labels from branch type or commit content. PR labels must mirror the linked issue labels exactly.

Do not amend commits, reset, restore, discard, or revert changes.

Do not manually reimplement `ban-commit` behavior. If changes need committing, invoke or follow `$ban-commit`.
