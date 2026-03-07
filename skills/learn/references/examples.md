# Learn Skill Examples

## Simple Preference

> User: "No, use `bb test` not `clojure -M:test`"

```markdown
## Proposed: Test Command
**Source**: User corrected test command
**Target**: ./.claude/CLAUDE.md
**Change**: Add
**Location Rationale**: Searched for existing test config; none found. General project preference fits CLAUDE.md.
**Content**:
- Run tests with `bb test`
```

## New Rule

> User repeatedly: "In this project, exported functions need explicit return types"

```markdown
## Proposed: TypeScript Rule
**Source**: Repeated corrections on return types
**Target**: ./.claude/rules/typescript.md
**Change**: Create
**Location Rationale**: File-pattern specific guidance (.ts/.tsx). No existing TypeScript rule. Creating new rule scopes guidance appropriately.
**Content**:
---
globs: ["*.ts", "*.tsx"]
---
- Exported functions require explicit return types
```

## New Skill from Emerged Workflow

> User over multiple turns: Explained detailed process for debugging memory leaks

```markdown
## Proposed: Memory Debugging Skill
**Source**: Multi-step debugging workflow shared across conversation
**Target**: ~/.claude/skills/memory-debugging/SKILL.md
**Change**: Create
**Location Rationale**: Coherent 5-step workflow emerged. Too detailed for CLAUDE.md. No existing debugging skill. Creating new skill preserves workflow and makes it reusable.
**Content**:
---
name: memory-debugging
description: Systematic workflow for diagnosing and fixing memory leaks
---
[workflow content]
```

## Consolidation Opportunity

> User: "Always use semantic commit messages"

```markdown
## Proposed: Consolidate Git Practices
**Source**: User preference for semantic commits
**Current State**:
- CLAUDE.md has "don't commit unless asked"
- rules/git.md has branch naming conventions
- Scattered git guidance across 3 files
**Target**: Consolidate into ~/.claude/skills/git-workflow/SKILL.md
**Change**: Create (and clean up existing)
**Location Rationale**: Git practices are scattered. New learning triggers consolidation into coherent skill. Will remove duplicates from CLAUDE.md and rules/git.md after creating skill.
**Affected Files**:
- CREATE: ~/.claude/skills/git-workflow/SKILL.md
- MODIFY: ~/.claude/CLAUDE.md (remove git section)
- DELETE: ~/.claude/rules/git.md (absorbed into skill)
**Content**:
---
name: git-workflow
description: Git conventions and commit practices
---
[consolidated content + new semantic commit guidance]
```
