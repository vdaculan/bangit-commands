---
name: ban-address-comments
description: Inspect unresolved review comments on pull requests or merge requests, classify actionable feedback, apply scoped fixes, rerun verification, and optionally reply or resolve threads across GitHub, GitLab, Bitbucket, Azure DevOps, or generic Git remotes. Use when the user asks to address review comments, fix PR feedback, resolve MR discussions, apply reviewer suggestions, or update a branch after review.
---

# Ban Address Comments

Address review feedback from repository and provider truth. Default to reading comments, applying code fixes for actionable feedback, and reporting results. Do not post replies, resolve threads, approve, merge, push, or change provider state unless the user explicitly asks.

## Workflow

1. Confirm repository context:

```bash
pwd
git rev-parse --show-toplevel
git status --short
git branch --show-current
git remote -v
```

2. Detect the provider and review target:

```bash
git remote get-url origin
git branch -r
```

Use available provider tooling:

- GitHub: `gh pr view`, `gh pr diff`, `gh api` review comments and review threads.
- GitLab: `glab mr view`, `glab mr diff`, GitLab discussions API, or merge request notes.
- Bitbucket: Bitbucket API or installed CLI for pull request comments and tasks.
- Azure DevOps: `az repos pr show`, `az repos pr threads list`, and PR iteration data when configured.
- Generic Git or unsupported provider: use local diff and any comments supplied by the user; report that provider comments were unavailable.

If provider tooling is missing or unauthenticated, do not fabricate comment state. Ask for the review URL or pasted comments only if no actionable feedback can be discovered locally.

3. Collect review context:

- PR/MR title, description, source branch, target branch, and URL.
- Changed files and current diff.
- Unresolved threads, open tasks, requested changes, and bot comments that represent required fixes.
- Existing CI/check status when available.
- Related issue or ticket context when linked.

4. Classify every comment:

- `actionable` - identifies a concrete code, test, doc, config, security, or behavior change.
- `question` - asks for explanation or product clarification before code can change.
- `nit` - style or wording preference with low behavioral impact.
- `stale` - already resolved by current diff or no longer applies to changed lines.
- `blocked` - needs credentials, product decision, unavailable provider state, or reviewer input.

Do not implement comments blindly. Verify whether each comment still applies to the current branch.

5. Apply scoped fixes:

- Read surrounding code before editing.
- Keep changes limited to the reviewed feedback.
- Preserve unrelated user changes.
- Add or update tests when feedback changes behavior or prevents regression.
- Update docs only when the comment affects documented behavior, setup, public API, or user-facing copy.

6. Verify the result.

Run targeted checks for touched areas first when useful. Then run the repository's relevant full verification sequence using `$ban-run-tests` rules when practical. If full verification is blocked, report the blocker and the focused checks that passed.

7. Prepare response text for provider threads.

For each actionable comment, summarize:

- What changed.
- Files touched.
- Verification run.
- Whether the thread appears resolved, still needs reviewer input, or is blocked.

Only post replies or resolve threads if the user explicitly asked for provider updates.

8. Report the final state:

- Provider and PR/MR detected.
- Number of comments found by classification.
- Comments addressed.
- Comments left open and why.
- Files changed.
- Verification commands and results.
- Provider replies/resolutions posted, if explicitly requested.

## Provider Rules

### GitHub

Use `gh` when available. Prefer GraphQL/API for unresolved review threads because plain review comments may not expose resolution state.

Useful commands:

```bash
gh pr view --json number,title,url,headRefName,baseRefName,reviewDecision,comments,reviews
gh pr diff
gh api graphql -f query='<query for pullRequest reviewThreads>'
```

Do not submit reviews, resolve conversations, or reply to threads unless explicitly requested.

### GitLab

Use `glab` when available, then GitLab API for discussions and resolvable notes when needed.

Useful commands:

```bash
glab mr view
glab mr diff
glab api <project-merge-request-discussions-endpoint>
```

Do not resolve discussions or post notes unless explicitly requested.

### Bitbucket

Inspect pull request comments and tasks through available Bitbucket API/CLI access. Treat open tasks as actionable until verified stale or blocked.

### Azure DevOps

Use Azure CLI only when the repository is configured for Azure DevOps:

```bash
az repos pr show --id <id>
az repos pr threads list --pull-request-id <id>
```

Do not close threads or change vote status unless explicitly requested.

## Comment Handling Rules

- Prefer fixing the code over replying with disagreement when the reviewer found a real issue.
- Push back only when the suggested change would introduce a bug, weaken security, conflict with requirements, or duplicate existing behavior.
- Keep a short rationale for declined or blocked comments.
- Do not treat automated formatting comments as authoritative if repository tooling disagrees.
- Do not reveal secret values from comments, logs, or files.

## Safety

Do not commit, push, post comments, resolve threads, approve, request changes, merge, close, or retarget PRs/MRs unless explicitly requested.

Do not make broad refactors while addressing review comments unless the comment requires it.

Do not mark comments resolved based only on intention. Verify the current diff addresses them.

If provider comments cannot be fetched, clearly state what was unavailable and continue with pasted comments or local review evidence.
