---
name: ban-commit
description: Inspect current git changes, generate a concise multi-part commit message based on the actual diff, stage the intended current changes, create a commit, and push the branch to origin. Use when the user asks to commit current changes, commit all current work, generate a commit message from the diff, or make a conventional commit and push it.
---

# Ban Commit

Create one commit for the current repository changes with a concise, accurate message that includes a subject and a short explanatory body, then push the current branch to `origin`.

## Workflow

1. Inspect the current Git state:

```bash
git status --short
git diff --stat
git diff HEAD
git branch --show-current
```

2. Identify the commit intent from the diff, not from assumptions.

If the user or another skill supplies explicit commit constraints, honor them exactly. Common constraints include an exact commit message, an allowlist of paths to stage, a required branch to push, or a requirement to omit a commit body. Do not replace explicit constraints with generated defaults.

3. Generate a concise conventional commit message unless an exact message was supplied:

```text
<type>: <summary>

<body sentence or phrase 1>. <body sentence or phrase 2>.
```

Use one of these types:

- `feat` for user-facing capability.
- `fix` for bug fixes.
- `refactor` for behavior-preserving code structure changes.
- `chore` for build, CI, config, dependency, or maintenance changes.
- `docs` for documentation-only changes.
- `test` for test-only changes.
- `style` for formatting or visual-only styling changes.

Keep the summary short, specific, and lowercase after the type. Prefer 50 characters or fewer when practical.

Add a body with at least two short sentences or phrases based on the staged diff. Use the body to name the main change and its reason, scope, or user-visible effect. Keep the body factual and avoid filler.

Good examples:

- Subject: `fix: restore google auth callback`
  Body: `Route the OAuth response through the expected handler. Prevent sign-in from stalling after provider redirects.`
- Subject: `chore: align qa build versioning`
  Body: `Update the QA build metadata to match release naming. Keep generated artifacts traceable across Firebase uploads.`
- Subject: `style: soften theme font weights`
  Body: `Adjust headings and labels to reduce visual heaviness. Preserve the existing spacing and color palette.`

If an exact commit message was supplied, use that message exactly and skip the generated-message rules above.

4. Stage only the changes that belong to the requested commit:

```bash
git add <paths>
```

If the user says to commit current/all changes, stage all modified, added, and deleted repo changes with:

```bash
git add -A
```

If the user or another skill supplied a path allowlist, stage only those paths even when other changes exist.

5. Verify the staged diff before committing:

```bash
git diff --cached --stat
git diff --cached
```

6. Create the commit:

```bash
git commit -m "<subject>" -m "<body>"
```

For an exact one-line message supplied by the user or another skill, use:

```bash
git commit -m "<exact-message>"
```

7. Push the current branch to `origin` after the commit succeeds. Use the branch name from the earlier `git branch --show-current` result unless an explicit required branch was supplied:

```bash
git push -u origin <branch>
```

8. Report the commit hash, message, pushed branch name, and any remaining unstaged/untracked changes.

## Safety

Do not amend existing commits unless the user explicitly asks.

Push only as part of this skill workflow after a successful commit; do not push if commit creation fails.

Do not discard, reset, restore, or revert changes.

Do not include unrelated files if the user requested a specific subset.

If the worktree contains unrelated changes and the user did not say to commit all current changes, ask before staging.

If there are no changes to commit, report that clearly and do not create an empty commit unless explicitly requested.

When called by another skill, return control after the commit and branch push. Do not perform extra workflow-specific actions such as tagging, opening PRs/MRs, or creating releases unless that calling skill explicitly owns those steps.
