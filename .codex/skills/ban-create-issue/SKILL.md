---
name: ban-create-issue
description: Analyze current git changes or requested work, create a well-described GitHub issue, assign it, label it, then create a linked local branch. Use when the user asks to create an issue, prepare a branch from an issue, generate an issue title or description from current work, or start tracked GitHub work from repository context.
---

# Ban Create Issue

Create a GitHub issue first, then create a clean local Git branch that links back to that issue.

## Workflow

1. Inspect the repository state:

```bash
git status
git diff --stat
git diff HEAD
git branch --show-current
```

2. Infer the issue label and branch category from the diff or requested work:

- `bug` label and `fix/` branch for bugs or broken behavior.
- `documentation` label and `docs/` branch for documentation-only changes.
- `feature` label and `feature/` branch for new user-facing capability.
- `enhancement` label and `chore/`, `refactor/`, or `feature/` branch for maintenance, cleanup, improvements, or requests that are not bugs or docs.

3. Generate the GitHub issue content:

- Issue title.
- Well-described Markdown issue body with summary, proposed changes, and acceptance criteria.
- Label from the allowed labels: `bug`, `documentation`, `enhancement`, or `feature`.
- Assignee. Default to `vdaculan` unless the user specifies another assignee.

4. Create the GitHub issue before creating a branch:

```bash
gh issue create --repo <owner>/<repo> --title "<issue-title>" --body "<issue-body>" --label "<label>" --assignee "<assignee>"
```

5. Generate three branch/work outputs from the created issue:

- Branch name that includes the issue number.
- Commit title.
- PR title.

6. Check whether the branch already exists:

```bash
git branch --list "<branch-name>"
```

7. Create the branch locally:

```bash
git switch -c "<branch-name>"
```

If the branch already exists, generate a more specific branch name and retry. Do not overwrite or delete existing branches.

8. Report the issue URL, assignee, label, branch name, commit title, PR title, and any remaining unstaged/untracked changes.

## Branch Rules

Use lowercase kebab-case only.

Use this format:

```text
<type>/<issue-number>-<description>
```

Keep the description to a maximum of five words.

Prefer outcome-focused wording over implementation-only wording.

Avoid vague names such as `update-stuff`, `fixes`, `testing`, `final-final`, or `branch1`.

Good examples:

- `feature/12-google-sso-login`
- `fix/34-crash-on-launch`
- `docs/45-onboarding-guide`
- `chore/56-update-firebase-config`

## Title Rules

Use conventional commit style for the commit title:

```text
<type>: <short summary>
```

Use a readable title-case PR title without the branch prefix:

```text
Fix Google Sign-In Redirect
```

## Safety

Do not commit changes.

Do not stage changes unless the user explicitly asks.

Do not discard or revert local changes.

Do not create a branch until the GitHub issue has been created successfully.

If there are no local changes, create the issue and branch from the current context only if the user provided a clear purpose; otherwise ask for the intended work before creating vague tracked work.
