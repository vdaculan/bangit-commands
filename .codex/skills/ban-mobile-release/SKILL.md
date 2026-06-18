---
name: ban-mobile-release
description: Run the mobile release Git flow from main by verifying a clean worktree, finding and bumping the canonical version file, committing exactly `chore: bump version`, pushing main to origin, tagging the commit as `v<version>`, and pushing the exact tag. Use when the user asks for ban-mobile-release, a mobile release, Flutter release, React Native release, Android or iOS release tagging, or a provider-neutral Git tag release.
---

# Ban Mobile Release

Run the provider-neutral mobile release Git flow. Validate that the checked-out branch is `main`, verify the worktree is clean, find the canonical version file, bump it, commit exactly `chore: bump version`, push `main` to `origin`, tag the pushed commit with the same bumped version, and push that exact tag.

This skill works across GitHub, GitLab, Bitbucket, Azure DevOps, and generic Git remotes because it uses only normal Git operations against `origin`. Do not build binaries, upload artifacts, submit store releases, edit signing assets, open PRs, or call provider-specific APIs unless the user explicitly asks.

## Workflow

1. Confirm repository, branch, and remote context:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
git remote get-url origin
```

If the current directory is not a Git repository or `origin` is not configured, stop and report the blocker.

2. Confirm the checked-out branch is exactly `main`.

```bash
git branch --show-current
```

If the branch is not `main`, stop immediately. Do not switch branches, edit files, stage, commit, tag, or push.

3. Confirm `main` is clean before any release edit.

```bash
git status --short
git diff --stat
git diff HEAD
```

If there are modified, staged, deleted, or untracked files, stop immediately and report the blocking paths. Do not change anything when the worktree is dirty.

4. Find the canonical mobile version file.

```bash
find . -maxdepth 5 \( -name 'pubspec.yaml' -o -name 'package.json' -o -name 'app.json' -o -name 'app.config.*' -o -name 'eas.json' -o -name 'build.gradle' -o -name 'build.gradle.kts' -o -name '*.xcodeproj' -o -name 'project.pbxproj' -o -name 'codemagic.yaml' -o -name 'bitrise.yml' -o -path './fastlane/*' -o -name 'firebase.json' \) -print
```

Choose one canonical version source:

- Flutter: `pubspec.yaml` is authoritative. Android and iOS version wiring normally reads this value.
- React Native or Expo: prefer the repo-documented source. Common candidates are `package.json`, `app.json`, `app.config.js`, and native Android/iOS version fields.
- Native Android: `android/app/build.gradle` or `android/app/build.gradle.kts`.
- Native iOS: project `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `project.pbxproj`, or repo-documented release tooling.
- Multi-platform repos: stop if version sources disagree and repo docs do not identify the canonical source.

Extract:

- project or app name
- platform, such as Flutter, React Native, Expo, Android, iOS, or mixed
- current version
- exact file that owns the version bump

If the canonical version file or current version cannot be identified, stop and report the candidates found.

5. Determine the next version.

Read the current version from the canonical version file. If the user did not specify a target version, increment the patch version using the repository's current semantic version shape.

Examples:

- `1.0.25` -> `1.0.26`
- `1.0.25+42` -> normally `1.0.26+42` unless repo guidance says to increment build metadata
- `2.4.0-beta.1` -> ask before changing prerelease shape unless user specified the target

The release tag must be exactly:

```text
v<version>
```

6. Verify the target tag does not already exist locally or remotely.

```bash
git tag --list "v<version>"
git ls-remote --tags origin "refs/tags/v<version>"
```

If the tag already exists locally or remotely, stop and report that the target version is already tagged. Do not edit, commit, tag, or push.

7. Edit only the canonical version file.

For Flutter, edit only `pubspec.yaml` unless the repository explicitly documents another coupled file. Re-read the file after editing and confirm the new value matches `<version>`.

8. Stage and verify only the version bump:

```bash
git add <version-file>
git diff --cached --stat
git diff --cached
```

If unrelated files are staged or the diff includes non-version changes, stop and correct the staging before committing.

9. Create the release commit with the exact message:

```bash
git commit -m "chore: bump version"
```

Do not amend prior commits and do not use a different message.

10. Push `main` to `origin` before tagging:

```bash
git push origin main
```

If the push fails, stop and report the remote or credential error. Do not create or push a tag after a failed branch push.

11. Tag the committed release version and push only that tag.

Before tagging, re-read the version file and confirm the committed version is exactly `<version>`. Then tag `HEAD`:

```bash
git tag "v<version>"
git push origin "v<version>"
```

Do not use `git push --tags`.

12. Verify final Git state:

```bash
git status --short --branch
git tag --points-at HEAD
git rev-parse --short HEAD
```

Confirm `HEAD` has `v<version>`, the worktree is clean, and `main` is no longer ahead of `origin/main`.

13. Report the release in this shape:

```text
Project: <project-name>
Platform: <Flutter | React Native | Expo | Android | iOS | mixed>
Version: <version>
Tag: v<version>
Commit: <short-hash>
Push: main and tag v<version> pushed to origin
Reminder: <project-name> <version> mobile release was published with tag v<version>.
```

## Mobile CI/CD Notes

This skill only performs the Git release: version bump, commit, branch push, tag, and tag push. Any CI/CD provider that reacts to tags should be handled by that provider after the tag reaches `origin`.

For Codemagic, Bitrise, Fastlane, EAS, Firebase App Distribution, TestFlight, or Play tracks, distinguish "tag pushed" from "artifact distributed." The release is only fully distributed after the provider build and upload steps pass.

If a mobile build later fails because of signing, provisioning, store credentials, Apple Developer enrollment, bundle identifier mismatch, App Store Connect keys, Play Console keys, or Firebase credentials, report it as a provider-side blocker instead of changing unrelated code.

For repos that use Fastlane, EAS, Bitrise, or provider-specific release scripts, inspect those configs only to identify the canonical version file when the normal version source is ambiguous.

## Safety

Do not run this workflow from any branch other than `main`.

Do not change anything when the worktree is dirty.

Do not tag a commit whose version file does not exactly match the tag.

Do not create a tag that already exists locally or remotely.

Do not push all tags.

Do not create a tag if `git push origin main` fails.

Do not edit signing credentials, provisioning profiles, keystores, App Store Connect keys, Play Console keys, or Firebase service files unless explicitly requested.

Do not submit to app stores or promote release tracks locally unless explicitly requested.

Do not continue after a failed release precondition.
