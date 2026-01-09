---
name: reflect
description: Review conversation context, identify user corrections and guidance, and propose memory updates (CLAUDE.md, rules, skills, commands, agents, docs). Can create new files when appropriate. Always requires user approval before changes.
---

# Reflect

Review conversation to identify learnings that should persist. Propose targeted updates for user approval.

## Memory Targets

| Location | Scope | When to Use |
|----------|-------|-------------|
| `~/.claude/CLAUDE.md` | Global | Personal preferences across all projects |
| `./.claude/CLAUDE.md` | Project | Project patterns, conventions, architecture |
| `~/.claude/rules/*.md` | Global | File-pattern guidance for all projects |
| `./.claude/rules/*.md` | Project | File-pattern guidance for this project |
| `~/.claude/skills/*/SKILL.md` | Global | Reusable workflows across projects |
| `./.claude/skills/*/SKILL.md` | Project | Project-specific workflows |
| `~/.claude/agents/*.md` | Global | Personal specialized assistants |
| `./.claude/agents/*.md` | Project | Project-specific assistants |
| `~/.claude/commands/*.md` | Global | Personal slash commands |
| `./.claude/commands/*.md` | Project | Project-specific commands |
| `./docs/**/*.md` | Project | Architecture, decisions, patterns |

### When to Create vs Update

**Create new file** when:
- Skill: Multi-step workflow emerged or domain expertise shared
- Command: Repeated action or user wants a shortcut
- Rule: Guidance is file-pattern specific
- Agent: Specialized assistant persona needed
- Doc: Architecture/design decisions to preserve

**Update existing** when learning fits naturally into existing content.

**Before creating docs**: Check existing docs for correct placement. Consolidate rather than duplicate.

## Workflow

**CRITICAL: Never apply changes without explicit user approval.**

### 1. Scan for Learnings

Look for:
- Explicit corrections ("no, do X instead")
- Guidance ("always X", "never Y", "prefer A over B")
- Preferences revealed through repeated feedback
- Workflows developed or refined
- Domain knowledge shared

### 2. Categorize

For each learning:
- **Scope**: Global (all projects) vs Project-specific
- **Type**: Preference, convention, knowledge, or process
- **Confidence**: Explicit (high), inferred (medium), pattern (low - verify)

### 3. Check Existing Memory

- Avoid duplication
- Find update targets vs create new
- Ensure consistency
- Consolidate scattered content

### 4. Propose Updates

```markdown
## Proposed: [Title]
**Source**: [Quote from conversation]
**Target**: [File path]
**Change**: Create | Add | Modify | Remove
**Content**:
[Proposed content - clear, concise, actionable]
**Rationale**: [Why this location]
```

### 5. Get Approval

Use AskUserQuestion. Options: Accept, Modify, Skip, Change location.

### 6. Apply

Only after approval: Read file, apply change, confirm.

## Writing Guidelines

Write memory content that is:
- **Specific**: "Use `bb test`" not "use the test runner"
- **Actionable**: "Run tests before committing" not "testing is important"
- **Concise**: No filler, no redundancy
- **Imperative**: "Run X" not "You should run X"

## Examples

### Simple Preference

> User: "No, use `bb test` not `clojure -M:test`"

```markdown
## Proposed: Test Command
**Source**: User corrected test command
**Target**: ./.claude/CLAUDE.md
**Change**: Add
**Content**:
- Run tests with `bb test`
**Rationale**: Project tooling preference
```

### New Command

> User: "I keep asking you to check coverage - make that easier"

```markdown
## Proposed: Coverage Command
**Source**: User wants quick coverage check
**Target**: ~/.claude/commands/coverage.md
**Change**: Create
**Content**:
---
description: Run tests with coverage report
---
Run test suite with coverage. Summarize percentages, highlight files below 80%.
**Rationale**: Repeated action benefits from command
```

### New Rule

> User repeatedly: "In this project, exported functions need explicit return types"

```markdown
## Proposed: TypeScript Rule
**Source**: Repeated corrections on return types
**Target**: ./.claude/rules/typescript.md
**Change**: Create
**Content**:
---
globs: ["*.ts", "*.tsx"]
---
- Exported functions require explicit return types
**Rationale**: File-pattern specific guidance
```
