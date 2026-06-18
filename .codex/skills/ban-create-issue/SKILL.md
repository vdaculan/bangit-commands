---
name: ban-create-issue
description: Analyze current git changes or requested work, detect the repository provider, create a well-described tracked issue or work item, assign and classify it when supported, then create a linked local branch. Use when the user asks to create an issue, ticket, work item, GitHub issue, GitLab issue, Bitbucket issue, Azure Boards work item, prepare a branch from tracked work, or start provider-tracked work from repository context.
---

# Ban Create Issue

Create a provider-backed issue, ticket, or work item first, then create a clean local Git branch that links back to that tracked artifact. Do not assume GitHub.

## Workflow

1. Inspect the repository state:

```bash
git status
git diff --stat
git diff HEAD
git branch --show-current
git remote -v
git remote get-url origin
```

If the current directory is not a Git repository, stop and report that a linked branch cannot be created.

2. Detect the provider from the remote URL and available tooling:

- GitHub: `github.com`, GitHub Enterprise hosts, or available `gh`.
- GitLab: `gitlab.com`, self-hosted GitLab hosts, or available `glab`.
- Bitbucket: `bitbucket.org`, Bitbucket Server/Data Center hosts, or provider API/CLI.
- Azure DevOps: `dev.azure.com`, `*.visualstudio.com`, or configured `az repos`.
- Generic Git: unknown provider, unavailable issue tracker, or missing authenticated tooling.

If the provider cannot be identified or authenticated, do not fabricate an issue URL. Ask for the provider/project target or report that only a local branch plan can be prepared.

3. Infer the tracked-work type and branch category from the diff or requested work:

- Bug or broken behavior: type `bug`, branch prefix `fix/`.
- Documentation-only work: type `documentation`, branch prefix `docs/`.
- New user-facing capability: type `feature`, branch prefix `feature/`.
- Maintenance, cleanup, configuration, workflow, or internal improvement: type `enhancement`, branch prefix `chore/` or `refactor/`.

Map this classification to each provider's native fields:

- GitHub: label `bug`, `documentation`, `enhancement`, or `feature`.
- GitLab: label with the same value when labels exist or can be created by the provider workflow.
- Bitbucket: issue kind/component/priority when supported; otherwise include classification in the issue body.
- Azure DevOps: work item type `Bug`, `User Story`, or `Task`; add tags for `documentation`, `enhancement`, or `feature` when appropriate.

4. Generate tracked-work content:

- Title.
- Markdown description with summary, proposed changes, acceptance criteria, and relevant diff context.
- Classification label/type.
- Assignee. Default to `vdaculan` only when the provider supports that identity and the user did not specify another assignee.

5. Create the tracked artifact before creating a branch.

Use the provider tool that matches the repository:

### GitHub

```bash
gh issue create --repo <owner>/<repo> --title "<title>" --body "<body>" --label "<label>" --assignee "<assignee>"
```

### GitLab

```bash
glab issue create --repo <group/project> --title "<title>" --description "<body>" --label "<label>" --assignee "<assignee>"
```

If `glab` is unavailable, use the GitLab API only when project ID and authentication are available.

### Bitbucket

Use an installed Bitbucket CLI or Bitbucket API when authenticated. Create a repository issue with title, content, classification, and assignee when supported.

If Bitbucket issues are disabled for the repository or the workspace uses Jira instead, stop and ask whether to create a Jira ticket or proceed with a local branch only.

### Azure DevOps

Use Azure CLI only when the repository is configured:

```bash
az boards work-item create --title "<title>" --type "<Bug|User Story|Task>" --description "<body>" --assigned-to "<assignee>" --tags "<tags>"
```

If Azure Boards is unavailable or not linked to the repository, stop and ask for the work item project or process.

### Generic Git

Do not create a fake issue. Prepare the title, body, classification, and branch name, then ask the user for the tracker/provider to use.

6. Extract the artifact identity from the provider response:

- URL.
- Numeric ID or key.
- Provider type.
- Final title, classification, and assignee.

7. Generate linked work outputs:

- Branch name that includes the artifact ID or key.
- Commit title.
- PR/MR title.

8. Check whether the branch already exists:

```bash
git branch --list "<branch-name>"
```

9. Create the branch locally only after the tracked artifact exists:

```bash
git switch -c "<branch-name>"
```

If the branch already exists, generate a more specific branch name and retry. Do not overwrite or delete existing branches.

10. Report the provider, artifact URL, artifact ID/key, assignee, classification, branch name, commit title, PR/MR title, and any remaining unstaged or untracked changes.

## Branch Rules

Use lowercase kebab-case only.

Use this format:

```text
<type>/<artifact-id>-<description>
```

Keep the description to a maximum of five words.

For Azure work items or non-numeric tracker keys, preserve the key shape after lowercasing safe characters, for example `feature/ab-123-login-flow`.

Prefer outcome-focused wording over implementation-only wording.

Avoid vague names such as `update-stuff`, `fixes`, `testing`, `final-final`, or `branch1`.

Good examples:

- `feature/12-google-sso-login`
- `fix/34-crash-on-launch`
- `docs/45-onboarding-guide`
- `chore/56-update-firebase-config`
- `feature/ab-123-login-flow`

## Title Rules

Use conventional commit style for the commit title:

```text
<type>: <short summary>
```

Use a readable title-case PR/MR title without the branch prefix:

```text
Fix Google Sign-In Redirect
```

## Safety

Do not commit changes.

Do not stage changes unless the user explicitly asks.

Do not discard or revert local changes.

Do not create a branch until the provider issue, ticket, or work item has been created successfully.

Do not assume GitHub labels, assignees, issue numbers, or URLs work on other providers.

Do not create duplicate tracked work if an existing issue, ticket, or work item clearly covers the requested scope; report the existing artifact and create the linked branch from it when appropriate.

If there are no local changes, create the tracked artifact and branch from the current context only if the user provided a clear purpose; otherwise ask for the intended work before creating vague tracked work.
