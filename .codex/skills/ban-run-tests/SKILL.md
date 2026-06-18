---
name: ban-run-tests
description: Detect the repository stack, run the appropriate full verification sequence, stop after the first failing command, fix the failure, and rerun from the beginning until all checks pass. Use when the user asks to run all tests, run checks, fix failing tests, rerun until green, or make verification work in Node, Flutter, Laravel, .NET, Python, Go, Rust, Java, Ruby, or mixed repositories.
---

# Ban Run Tests

Run the repository's appropriate full verification sequence, stop after the first failing command completes, fix the failure, then restart the selected sequence from the beginning. Only report success after the full sequence passes in order.

## Workflow

1. Confirm the repository context:

```bash
pwd
git rev-parse --show-toplevel
git status --short
```

If the current directory is not a Git repository, continue only if the filesystem clearly identifies a project. Report that Git metadata is unavailable.

2. Detect the stack and command source from repository files:

```bash
rg --files -g '!*node_modules*' -g '!build/*' -g '!dist/*' -g '!coverage/*'
find . -maxdepth 4 -type f \( -name 'package.json' -o -name 'pnpm-lock.yaml' -o -name 'yarn.lock' -o -name 'bun.lockb' -o -name 'package-lock.json' -o -name 'pubspec.yaml' -o -name '*.sln' -o -name '*.csproj' -o -name 'pyproject.toml' -o -name 'requirements*.txt' -o -name 'composer.json' -o -name 'artisan' -o -name 'phpunit.xml' -o -name 'go.mod' -o -name 'Cargo.toml' -o -name 'pom.xml' -o -name 'build.gradle*' -o -name 'Gemfile' -o -name 'Rakefile' -o -name 'Makefile' \) -print
```

3. Build the verification sequence from project truth.

Prefer explicit project scripts and config over generic defaults. Use package-manager wrappers when present, such as `./gradlew`, `./mvnw`, or `composer` scripts. For monorepos, identify each package boundary and run verification in the correct subdirectories instead of assuming the repo root covers everything.

4. Run commands in order. If a command fails:

- Stop the sequence after that command completes.
- Diagnose the failing code path.
- Make the needed fix.
- Use focused verification while iterating if helpful.
- Restart from the first command in the selected full sequence.

5. Exit only when every command in the selected sequence passes from the beginning without failures.

6. Report the detected stack, the exact command sequence, failures fixed, files changed, and final pass status.

## Command Detection

### Node, React, Next.js, Vite, or TypeScript

Detect package manager by lockfile:

- `pnpm-lock.yaml` -> `pnpm`
- `yarn.lock` -> `yarn`
- `bun.lockb` -> `bun`
- `package-lock.json` -> `npm`

Read `package.json` scripts first. Build the sequence from available scripts in this order:

```text
typecheck
lint
test
test:unit
test:e2e
build
```

Do not run duplicate test scripts if `test` already clearly covers the suite. If no scripts exist, report that no reliable Node verification command is defined instead of inventing one.

### Flutter or Dart

If `pubspec.yaml` exists, use:

```bash
flutter analyze
flutter test
```

If `integration_test/` exists, add targeted integration commands only when the project docs or existing workflow identify the expected entrypoint. Do not assume every Flutter repo has `integration_test/core_parent_flow_test.dart`.

### Laravel or PHP

If `composer.json` exists, inspect scripts. Prefer project-defined scripts such as:

```bash
composer test
composer lint
```

For Laravel projects with `artisan` and `phpunit.xml`, common fallbacks are:

```bash
php artisan test
```

If frontend assets exist, also inspect `package.json` and include relevant lint/test/build scripts after backend checks when the app requires them.

### .NET

If `.sln` or `.csproj` files exist, prefer solution-level commands:

```bash
dotnet restore
dotnet build --no-restore
dotnet test --no-build
```

For repo-specific scripts or CI commands, follow those instead. In multi-solution repos, identify the intended solution before running broad commands.

### Python

Inspect `pyproject.toml`, `requirements*.txt`, `pytest.ini`, `tox.ini`, `noxfile.py`, `ruff.toml`, and `mypy.ini`.

Prefer configured tools in this order when present:

```bash
ruff check .
mypy .
pytest
tox
nox
```

Do not run commands for tools that are not configured or installed unless the repository docs specify them.

### Go

If `go.mod` exists, use:

```bash
go test ./...
```

Add `go vet ./...` only if docs, CI, or Makefile indicate it is part of verification.

### Rust

If `Cargo.toml` exists, use:

```bash
cargo test
```

Add `cargo fmt --check` and `cargo clippy -- -D warnings` only when configured or documented.

### Java or Kotlin

Prefer wrapper scripts:

```bash
./gradlew test
./gradlew build
./mvnw test
./mvnw verify
```

Use non-wrapper `gradle` or `mvn` only when wrappers are absent and the environment supports them.

### Ruby

If `Gemfile` exists, inspect `Rakefile` and scripts. Common commands are:

```bash
bundle exec rake test
bundle exec rspec
```

Use the one supported by repository files.

### Makefile or Custom Scripts

If a `Makefile`, `justfile`, `Taskfile.yml`, or documented script exists, inspect it before falling back to language defaults. Prefer project-owned aggregate targets such as:

```bash
make test
make lint
make ci
```

## Monorepos

For workspaces, detect package boundaries from files such as `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, `lerna.json`, `rush.json`, multiple `package.json` files, multiple `.csproj` files, or nested app directories.

Use the repo's aggregate command when available. If no aggregate command exists, run the smallest complete set of package-level commands that covers the touched areas and report any unverified packages.

## Rerun Rules

After every fix, rerun the full selected sequence from the first command. Targeted reruns are allowed while debugging, but final success requires the full selected sequence to pass in order.

If a command fails because dependencies are missing, install nothing unless the user explicitly approves. Report the missing prerequisite and the exact failing command.

## Safety

Do not skip a failing command and continue to later commands.

Do not declare success from a partial pass or from targeted verification alone.

Prefer targeted test reruns while fixing, but always finish with the full sequence.

Preserve unrelated user changes and avoid destructive git commands.

Do not run destructive, stateful, or deployment commands as part of testing. Avoid database resets, production migrations, seeders against non-local databases, and deploy commands unless the user explicitly requests them.

If the environment prevents a test command from running or a failure cannot be resolved, report the blocker clearly with the exact command and failure surface.
