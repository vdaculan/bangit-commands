# Repository Guidelines

## Project Structure & Module Organization

This repository packages reusable Codex workflow skills. The root contains project-level documentation and licensing files:

- `README.md` summarizes the purpose of the repository.
- `LICENSE` contains the project license.
- `codex/skills/<skill-name>/SKILL.md` contains each skill definition.

Each skill should live in its own directory under `codex/skills/` and include a `SKILL.md` file with YAML front matter followed by Markdown instructions. Current skill names follow the `ban-*` prefix, for example `codex/skills/ban-commit/SKILL.md`.

## Build, Test, and Development Commands

There is no compiled build step for this repository. Use shell checks to validate structure and review changes:

```bash
find codex/skills -maxdepth 2 -name SKILL.md | sort
```

Lists all skill entrypoints and confirms each skill has a `SKILL.md`.

```bash
git diff --check
```

Detects whitespace errors before committing.

```bash
git status --short
```

Shows tracked and untracked changes that should be reviewed before staging.

## Coding Style & Naming Conventions

Write skill content in Markdown with clear headings, short paragraphs, and actionable steps. Use fenced code blocks for commands and examples. Keep YAML front matter at the top of every `SKILL.md` with at least `name` and `description`.

Skill directories should use lowercase kebab case and match the skill name, such as `ban-pull-request`. Avoid committing generated system files such as `.DS_Store`.

## Testing Guidelines

No automated test framework is configured. Validate changes by checking Markdown readability, confirming the expected skill paths exist, and running `git diff --check`. When changing a skill workflow, manually review command order and safety notes so instructions remain executable in a real repository.

## Commit & Pull Request Guidelines

The current Git history only contains an initial commit, so use conventional commit subjects for consistency:

```text
docs: add contributor guide
chore: add ban skill bundle
```

Pull requests should include a concise summary, list of changed skills, and any manual validation performed. Link related issues when available. Include screenshots only when documentation changes affect rendered output.

## Agent-Specific Instructions

Before editing a skill, read the relevant `SKILL.md` completely. Keep changes scoped to the requested workflow, preserve existing command examples where possible, and do not modify unrelated skill directories in the same change.
