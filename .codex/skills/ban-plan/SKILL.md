---
name: ban-plan
description: Turn a feature request, bug report, refactor, migration, release idea, or vague implementation goal into a repository-grounded execution plan with scope, affected files, phases, risks, acceptance criteria, verification steps, and open questions. Use when the user asks to plan, scope, break down, phase, estimate, write an implementation plan, prepare work before coding, or create a plan that can feed issue, PR, or execution workflows.
---

# Ban Plan

Create a practical implementation plan grounded in the live repository. Prefer concrete files, commands, dependencies, risks, and acceptance criteria over generic advice.

## Workflow

1. Clarify the goal from the user request.

Identify:

- Problem or desired outcome.
- User-visible behavior.
- Non-goals and constraints.
- Target platform, module, or repository area.
- Deadline or release boundary if provided.

Ask a question only when a missing answer would materially change the plan. Otherwise state assumptions and proceed.

2. Inspect repository context before planning:

```bash
pwd
git rev-parse --show-toplevel
git status --short
rg --files
find . -maxdepth 3 -type f \( -iname 'README*' -o -iname 'AGENTS.md' -o -iname 'CONTRIBUTING*' -o -iname 'package.json' -o -iname 'pubspec.yaml' -o -iname '*.sln' -o -iname '*.csproj' -o -iname 'pyproject.toml' -o -iname 'composer.json' -o -iname 'Makefile' \) -print
```

Read relevant docs, routes, configs, tests, schemas, and existing implementations before proposing file changes.

3. Map the implementation surface:

- Entry points, routes, screens, commands, jobs, or APIs.
- Data models, migrations, schemas, storage, or external services.
- Tests and fixtures.
- Config, environment variables, CI/CD, release, or docs.
- Ownership boundaries and local patterns.

4. Produce the plan.

Use this format unless the user asks for another:

```text
## Goal
## Current State
## Proposed Scope
## Phases
## Files and Areas
## Acceptance Criteria
## Verification
## Risks and Tradeoffs
## Open Questions
```

Keep phases small enough to implement and verify independently. Each phase should include the expected files or areas, output, and verification.

5. Decide whether to save the plan.

If the user asks for a plan document, save it in the repository using the local docs pattern, usually `docs/` or `PLAN/`. If the repo has no docs pattern, ask before creating a new planning directory.

If the user only asks for guidance, answer in the thread and do not create files.

6. Hand off to execution when requested.

When the user approves implementation, use the plan as working context, but re-check the live repo before editing. Do not assume the plan is still current if files changed.

## Planning Standards

Make plans falsifiable. Include observable outcomes and exact verification commands when possible.

Separate confirmed facts from assumptions.

Prefer incremental migration paths over broad rewrites.

Include rollback or recovery notes for risky data, auth, billing, release, or infrastructure changes.

Include docs and test updates when behavior, setup, API contracts, or workflows change.

## Risk Checklist

Call out these risks when relevant:

- Auth, authorization, tenancy, privacy, or security changes.
- Data migrations, deletes, imports, exports, or schema changes.
- Billing, subscriptions, payments, entitlements, or external provider callbacks.
- Mobile release, signing, store submission, or CI/CD trigger changes.
- Public API, webhook, SDK, or backward-compatibility changes.
- Performance, concurrency, caching, or background job changes.
- Feature flags, rollout strategy, or rollback path.

## Safety

Do not present a speculative plan as repository-confirmed.

Do not skip repo inspection when the user asks for a repo-specific plan.

Do not create issues, branches, commits, or PRs unless the user asks for those workflow steps.

Do not start implementation unless the user explicitly asks to proceed or the original request clearly includes implementation.
