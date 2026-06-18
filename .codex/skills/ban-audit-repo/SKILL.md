---
name: ban-audit-repo
description: Inspect any repository and produce a practical audit of structure, stack, commands, docs, CI, deployment, environment, security, and workflow gaps. Use when the user asks to audit a repo, understand a new codebase, identify missing setup, find project risks, or make another Ban skill work safely in an unfamiliar repository.
---

# Ban Audit Repo

Audit the current repository from live files and Git state. Default to read-only inspection. Do not edit files, install dependencies, run migrations, start deployments, or create GitHub artifacts unless the user explicitly asks after the audit.

## Workflow

1. Confirm repository context:

```bash
pwd
git rev-parse --show-toplevel
git status --short
git branch --show-current
```

If the directory is not a Git repository, continue with filesystem inspection and clearly state that Git metadata is unavailable.

2. Inventory the project without assuming a stack:

```bash
rg --files -g '!*node_modules*' -g '!*.lock' -g '!build/*' -g '!dist/*' -g '!coverage/*'
find . -maxdepth 3 -type f \( -name 'package.json' -o -name 'pubspec.yaml' -o -name '*.csproj' -o -name '*.sln' -o -name 'pyproject.toml' -o -name 'requirements*.txt' -o -name 'composer.json' -o -name 'Gemfile' -o -name 'go.mod' -o -name 'Cargo.toml' -o -name 'pom.xml' -o -name 'build.gradle*' -o -name 'Makefile' -o -name 'Dockerfile' -o -name 'docker-compose*.yml' \) -print
```

3. Read root documentation and agent guidance if present:

```bash
ls -la
find . -maxdepth 3 -iname 'README*' -o -iname 'AGENTS.md' -o -iname 'CONTRIBUTING*' -o -iname 'CHANGELOG*' -o -iname '.env.example'
```

4. Detect validation commands from repository truth:

- Node: read `package.json` scripts and package manager locks. Prefer `npm`, `pnpm`, `yarn`, or `bun` based on the lockfile.
- Flutter/Dart: read `pubspec.yaml`; common checks are `flutter analyze` and `flutter test`.
- .NET: inspect `.sln` or `.csproj`; common checks are `dotnet build` and `dotnet test`.
- Python: inspect `pyproject.toml`, `requirements*.txt`, `pytest.ini`, `tox.ini`, or `noxfile.py`.
- PHP/Laravel: inspect `composer.json`, `artisan`, `phpunit.xml`, and frontend scripts if present.
- Ruby: inspect `Gemfile`, `Rakefile`, and test directories.
- Go: inspect `go.mod`; common checks are `go test ./...`.
- Rust: inspect `Cargo.toml`; common checks are `cargo test` and `cargo clippy` when configured.
- Java/Kotlin: inspect Maven or Gradle files; use wrapper scripts when present.
- Mixed repos or monorepos: identify package boundaries and do not collapse them into one guessed command.

Do not run expensive or stateful commands automatically unless the user asked for verification. For an audit, list the likely commands and mark confidence based on scripts/configs found.

5. Inspect CI, deployment, and runtime surfaces:

```bash
find .github .gitlab .circleci .vercel .netlify .render .cloudflare -maxdepth 3 -type f 2>/dev/null
find . -maxdepth 3 -type f \( -name 'Dockerfile' -o -name 'docker-compose*.yml' -o -name 'vercel.json' -o -name 'netlify.toml' -o -name 'render.yaml' -o -name 'wrangler.toml' -o -name 'firebase.json' -o -name 'app.yaml' \) -print
```

6. Inspect environment and secret-handling signals without printing secret values:

```bash
find . -maxdepth 3 -type f \( -name '.env*' -o -name '*secret*' -o -name '*key*' \) -print
git check-ignore .env .env.local .env.production 2>/dev/null
```

Report whether example env files exist, whether real env files appear tracked or unignored, and whether configuration docs are missing. Never reveal secret contents.

7. Inspect testing and documentation coverage:

```bash
find . -maxdepth 4 -type d \( -iname 'test' -o -iname 'tests' -o -iname '__tests__' -o -iname 'spec' -o -iname 'integration_test' -o -iname 'e2e' \) -print
find . -maxdepth 3 -type f \( -iname '*test*' -o -iname '*spec*' \) -print
```

8. Produce the audit report.

## Report Format

Use concise Markdown with these sections:

```text
## Repository Snapshot
## Detected Stack
## Structure Map
## Build, Test, and Run Commands
## CI and Deployment
## Environment and Security
## Documentation Gaps
## Workflow Risks
## Recommended Next Actions
```

For each finding, include the file or directory that supports it. Separate confirmed facts from inferred recommendations.

## Scoring

Include a simple readiness score when useful:

- `Green` - core commands, docs, env examples, tests, and CI/deploy signals are clear.
- `Yellow` - repository is workable but has missing docs, uncertain commands, or partial automation.
- `Red` - cannot safely build/test/deploy from available repo information.

## Safety

Do not modify files during the audit.

Do not run commands that install dependencies, mutate databases, generate code, deploy services, or write build artifacts unless explicitly requested.

Do not assume GitHub is the remote provider. Detect remotes and CI files before recommending GitHub-specific actions.

Do not treat missing tests, docs, or CI as defects without explaining the practical risk.

If project commands are ambiguous, report the ambiguity and the files that caused it instead of inventing a command.
