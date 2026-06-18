---
name: ban-mobile-release
description: Run a mobile app release workflow where a version bump and exact Git tag push trigger CI/CD distribution. Use when the user asks for ban-mobile-release, a mobile release, Flutter release, React Native release, Android or iOS release tagging, Codemagic or other CI/CD tag-triggered distribution, Firebase App Distribution release, TestFlight release trigger, Play internal testing trigger, or a release that should be started by pushing a version tag.
---

# Ban Mobile Release

Run a tag-triggered mobile release. This skill is Git-first: validate the mobile repository, bump the canonical version file, commit only the release metadata, create the exact release tag, push the release branch, then push the tag that triggers CI/CD.

Do not build binaries, upload artifacts, submit store releases, or edit signing assets locally unless the user explicitly asks. The tag push is the release trigger.

## Workflow

1. Confirm repository and release context:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
```

2. Detect the mobile stack and version source from repository files:

```bash
find . -maxdepth 5 \( -name 'pubspec.yaml' -o -name 'package.json' -o -name 'app.json' -o -name 'app.config.*' -o -name 'eas.json' -o -name 'build.gradle' -o -name 'build.gradle.kts' -o -name '*.xcodeproj' -o -name 'project.pbxproj' -o -name 'codemagic.yaml' -o -name 'bitrise.yml' -o -path './fastlane/*' -o -name 'firebase.json' \) -print
```

Choose one canonical version source:

- Flutter: `pubspec.yaml` is authoritative. Android and iOS version wiring normally reads this value.
- React Native or Expo: prefer the repo-documented source. Common candidates are `package.json`, `app.json`, `app.config.js`, and native Android/iOS version fields.
- Native Android: `android/app/build.gradle` or `android/app/build.gradle.kts`.
- Native iOS: project `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `project.pbxproj`, or repo-documented release tooling.
- Multi-platform repos: stop if version sources disagree and repo docs do not identify the canonical source.

3. Detect the CI/CD tag trigger.

Inspect provider and pipeline config before tagging:

```bash
find .github .gitlab .circleci .codemagic .bitrise .azure-pipelines .buildkite .vercel .netlify -maxdepth 4 -type f 2>/dev/null
find . -maxdepth 3 -type f \( -name 'codemagic.yaml' -o -name 'bitrise.yml' -o -name '.gitlab-ci.yml' -o -name 'azure-pipelines*.yml' -o -name 'bitbucket-pipelines.yml' -o -name 'Jenkinsfile' \) -print
```

Look for tag filters such as `v*`, `refs/tags/*`, `tags:`, `on.push.tags`, Codemagic tag events, Bitrise tag triggers, or provider-specific release workflows. If no tag trigger is visible, stop before tagging unless the user explicitly confirms the tag is still the release trigger.

4. Enforce release preconditions.

Require:

- Current branch is the repository release branch, usually `main` unless repo docs or `origin/HEAD` say otherwise.
- Worktree is clean before the version bump.
- Version source is clear and non-empty.
- CI/CD tag trigger is confirmed or explicitly accepted by the user.
- Target tag does not already exist locally or remotely.

Use:

```bash
git symbolic-ref refs/remotes/origin/HEAD
git tag --list "v<version>"
git ls-remote --tags origin "refs/tags/v<version>"
```

If any precondition fails, stop without editing, committing, tagging, or pushing.

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

6. Edit only the canonical version file, unless repo guidance clearly requires coupled mobile version files.

For Flutter, edit only `pubspec.yaml` unless the repository explicitly documents another coupled file. Re-read the file after editing and confirm the new value matches `<version>`.

7. Stage and verify only the release metadata:

```bash
git add <version-file>
git diff --cached --stat
git diff --cached
```

If unrelated files are staged or the diff includes non-release changes, stop and correct the staging before committing.

8. Create the release commit:

```bash
git commit -m "chore: bump version"
```

Do not amend prior commits and do not use a different message unless the repository explicitly requires it.

9. Create and push the tag that triggers CI/CD:

```bash
git tag "v<version>"
git push origin <release-branch>
git push origin "v<version>"
```

Push only the release branch and exact tag. Do not use `git push --tags`.

10. Verify local Git state and trigger evidence:

```bash
git status --short --branch
git tag --points-at HEAD
git rev-parse --short HEAD
```

If provider tooling is available, check that CI/CD noticed the tag:

- GitHub Actions: `gh run list --branch "v<version>"` or inspect tag-triggered workflow runs.
- GitLab CI: `glab pipeline list --ref "v<version>"`.
- Codemagic: inspect `codemagic.yaml` and provider dashboard/logs when available.
- Bitrise: inspect tag-triggered builds when CLI/API is available.

Do not wait indefinitely for mobile builds to finish unless the user explicitly asks to monitor.

11. Report the release in this shape:

```text
Project: <project-name>
Platform: <Flutter | React Native | Expo | Android | iOS | mixed>
Version: <version>
Tag: v<version>
Commit: <short-hash>
Trigger: pushed tag v<version> to origin for CI/CD
CI/CD: <detected provider or "not verified from CLI">
Reminder: <project-name> <version> mobile release was triggered by tag v<version>.
```

## Mobile CI/CD Notes

For Codemagic, confirm `codemagic.yaml` has the expected workflow and tag trigger. If iOS signing fails with missing profiles, certificates, Apple Developer enrollment, bundle identifier mismatch, or Ad Hoc/TestFlight signing errors, report it as a signing/provider blocker instead of trying unrelated repo changes.

For Firebase App Distribution, TestFlight, or Play testing tracks, distinguish "tag pushed and CI/CD started" from "artifact distributed." The release is only fully distributed after the provider build and upload steps pass.

For repos that use Fastlane, EAS, Bitrise, or provider-specific release scripts, inspect those configs before deciding which version files must be changed.

## Safety

Do not run this workflow from a dirty worktree.

Do not tag a commit whose version file does not exactly match the tag.

Do not create a tag that already exists locally or remotely.

Do not push all tags.

Do not edit signing credentials, provisioning profiles, keystores, App Store Connect keys, Play Console keys, or Firebase service files unless explicitly requested.

Do not submit to app stores or promote release tracks locally unless explicitly requested.

Do not continue after a failed release precondition.
