---
name: ban-release
description: Release the current project from its primary release branch by validating a clean release state, bumping the canonical repository version, committing it as `chore: bump version`, creating tag `v<version>`, pushing the branch, pushing the exact tag, and reporting the final project, package, version, commit, and tag details. For Flutter repos, `pubspec.yaml` is the source of truth for the current and next release version. Use when the user asks to release to production, publish a version bump, tag and push a release, or run ban-release.
---

# Ban Release

Run the user's direct-to-branch production release Git flow for the current repository.

This skill is Git-only. It does not build binaries, upload artifacts, create store releases, or open pull requests.

## Workflow

1. Read release metadata from the repository before touching Git state.

Detect the repository's canonical release metadata source first. Do not assume Flutter or a specific stack, but if this is a Flutter repository and `pubspec.yaml` exists, treat `pubspec.yaml` as authoritative.

Inspect obvious project metadata and choose one authoritative version file for this repository. Typical candidates include:

- `pubspec.yaml`
- `package.json`
- `pyproject.toml`
- `Cargo.toml`
- `android/app/build.gradle` or `android/app/build.gradle.kts`
- another repo-specific manifest explicitly used for releases

For Flutter repositories:

- `pubspec.yaml` is the source of truth for the current release version
- tags are only a consistency check and must never override the version currently in `pubspec.yaml`
- the new release tag must match the bumped `pubspec.yaml` version exactly

Extract:

- project or app name
- package or artifact identifier when one exists
- current release version from the chosen release file
- release branch name
- the exact file that owns the version bump

2. Inspect the current Git state:

```bash
git status --short --branch
git diff --stat
git diff HEAD
git branch --show-current
git symbolic-ref refs/remotes/origin/HEAD
```

3. Enforce strict release preconditions.

Require all of the following before continuing:

- current branch matches the repository's primary release branch
- the chosen release file contains a non-empty current version value
- the worktree is otherwise clean before the release starts
- the current version can be incremented to a new release version

Resolve the release branch from repository truth in this order:

- an explicit user instruction
- repo guidance or release docs
- `origin/HEAD`
- `main` only if the repository gives no better signal

Use a diff check against the chosen release file:

```bash
git diff -- <release-file>
```

If the worktree is not clean, stop immediately, report the blocking files, and do not stage, commit, tag, or push anything.

If the current branch does not match the resolved release branch, stop and report both values.

4. Bump the version in the chosen release file only after all preconditions pass.

The source of truth for the next release is always the current version value in the chosen release file, not the latest Git tag.

For Flutter repositories, read the current version directly from `pubspec.yaml` and bump from that exact value. For example, if `pubspec.yaml` says `1.0.20`, the next normal release is `1.0.21` unless the user explicitly asks for a different target version, even if existing tags are missing, stale, or misaligned.

Increment the version name using the repo's current semantic version shape. For example, if the current version is `1.0.4`, update it to `1.0.5` unless the user explicitly asks for a different target version.

If the repository uses a coupled build number format such as `1.0.5+12`, increment only the release version unless repo guidance clearly says the build number must also change for a normal release.

After editing, treat the new value as `<version>` for the rest of the workflow. The created tag must be exactly `v<version>` and must match the version now present in the chosen release file.

5. Verify the new release tag does not already exist locally or on `origin`:

```bash
git tag --list "v<version>"
git ls-remote --tags origin "refs/tags/v<version>"
```

If the new tag already exists locally or remotely, stop and report that the target release version has already been published.

6. Stage only the release file:

```bash
git add <release-file>
```

7. Verify the staged release diff:

```bash
git diff --cached --stat
git diff --cached
```

The staged diff must be only the version bump in the chosen release file.

8. Create the release commit with the exact message:

```bash
git commit -m "chore: bump version"
```

Do not generate an alternate message. Do not amend prior commits.

9. Create the release tag from the committed version:

```bash
git tag "v<version>"
```

Before creating the tag, re-read the chosen release file if needed and ensure the committed version in that file is exactly `<version>`. Do not create a tag for any other value.

10. Push the branch first:

```bash
git push origin <release-branch>
```

11. Push the exact release tag second:

```bash
git push origin "v<version>"
```

12. Re-check the repository state after both pushes:

```bash
git status --short --branch
git rev-parse --short HEAD
```

Confirm that the release branch is no longer ahead of `origin/<release-branch>`. If status still shows `ahead`, the release is not fully pushed yet.

13. Report the release reminder in a short, consistent format.

The final response must include each of these exactly once:

- project name
- package name
- released version
- created tag
- commit hash
- push status
- one-line reminder phrasing for later reference

Use this output shape:

```text
Project: <project-name>
Package: <package-name>
Version: <version>
Tag: v<version>
Commit: <short-hash>
Push: <release-branch> and tag pushed to origin
Reminder: <project-name> <version> was released with tag v<version>.
```

If the repository has no meaningful package identifier, use `Package: n/a`.

If the release stops early, report the exact precondition that failed and do not create a partial release.

## Safety

Do not run this workflow from any branch other than the resolved release branch.

Do not include unrelated files in the commit.

Do not change anything if the worktree is dirty when the skill starts.

Do not push all tags. Push only the resolved release branch and the exact release tag.

Do not edit any file other than the chosen release file as part of the release bump unless the repository clearly requires a coupled version file and that requirement is documented in repo guidance.

Do not create pull requests, draft releases, or store submissions.

Do not reset, restore, discard, or revert changes.

Do not continue after a failed precondition check.
