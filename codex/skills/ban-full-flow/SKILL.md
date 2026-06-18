---
name: ban-full-flow
description: Run the full GitHub issue-to-PR flow by creating a GitHub issue and linked branch with ban-create-issue, committing and pushing current work with ban-commit, then opening a linked pull request with ban-pull-request. Use when the user asks to create an issue, commit, and PR in one workflow, run the full Git flow, or take current work from local changes to a ready pull request.
---

# Ban Full Flow

Run the complete tracked GitHub workflow by delegating to the existing Ban skills in order.

## Workflow

1. Confirm the repository context before starting:

```bash
git status --short
git branch --show-current
gh repo view
```

If the current directory is not a Git repository or `gh repo view` cannot resolve a GitHub repository, stop and report the problem.

2. Use `$ban-create-issue` first.

Pass along the user's requested work or infer it from the current repository changes. Require successful GitHub issue creation and linked local branch creation before continuing. Do not commit, stage, push, or open a PR during this step except through `$ban-create-issue`'s own workflow.

3. Use `$ban-commit` after `$ban-create-issue` succeeds.

Let `$ban-commit` inspect the actual diff, choose the commit message, stage the intended changes, create the commit, and push the branch. If there are no changes to commit, stop and report that no commit or PR was created unless the user explicitly requested an empty/no-change flow.

4. Use `$ban-pull-request` after `$ban-commit` succeeds.

Let `$ban-pull-request` validate the issue branch, copy issue labels, avoid duplicate PRs, and create the ready pull request. Do not manually reimplement its PR body, label, assignee, duplicate-check, or linked-issue rules.

5. Report the complete result:

- Issue URL.
- Branch name.
- Commit hash and message.
- PR URL.
- Any remaining unstaged or untracked changes.

## Safety

Do not skip steps or run them out of order.

Do not duplicate the detailed rules from `$ban-create-issue`, `$ban-commit`, or `$ban-pull-request`; those skills are the source of truth for their own behavior.

Do not discard, reset, restore, or revert local changes.

If any delegated skill stops for safety, stop the full flow and report the reason instead of continuing.
