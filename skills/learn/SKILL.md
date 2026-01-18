---
name: learn
description: Review conversation context, identify user corrections and guidance, and propose memory updates (CLAUDE.md, rules, skills, commands, agents, docs). Can create new files when appropriate. Always requires user approval before changes.
---

# Learn

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

### 3. Determine Best Location

**IMPORTANT**: Actively search for the best placement. Don't default to CLAUDE.md.

#### Search Strategy

1. **Search existing files** for related content:
   - Grep for keywords from the learning
   - Check skills, rules, docs for thematic matches
   - Look at file structure and organization

2. **Evaluate fit** for each potential location:
   - Does the learning extend existing content naturally?
   - Would adding it here make the file too broad?
   - Is this the canonical place someone would look?

3. **Consider creating new locations** when:
   - Learning doesn't fit existing files well
   - Existing file would become unfocused
   - Topic deserves its own space
   - Multiple related learnings form a coherent theme

#### Location Decision Tree

```
Is this file-pattern specific? (e.g., "for .clj files...")
  → Yes → rules/*.md (create if no matching rule exists)

Is this a multi-step workflow or domain expertise?
  → Yes → skills/*/SKILL.md (create new skill if none fits)

Is this a repeated action the user wants quick access to?
  → Yes → commands/*.md (create new command)

Is this about a specialized assistant persona?
  → Yes → agents/*.md (create new agent)

Is this architectural/design knowledge?
  → Yes → docs/**/*.md (find or create appropriate doc)

Does this extend an existing skill's domain?
  → Yes → That skill's SKILL.md or references/

Is this a general preference/convention?
  → Yes → CLAUDE.md (project or global based on scope)
```

#### When to Suggest New Locations

Suggest creating a **new skill** when:
- A coherent workflow with 3+ steps emerged
- Domain-specific knowledge that doesn't fit elsewhere
- Could benefit other projects (global) or will be reused (project)

Suggest creating a **new documentation file/category** when:
- Architectural decisions need permanent record
- Complex topic needs structured explanation
- Related decisions are scattered and should consolidate

Suggest creating a **new rule** when:
- Guidance applies to specific file patterns
- Different file types need different treatment

Suggest creating a **new command** when:
- Action is repeated frequently
- User explicitly wants a shortcut
- Complex operation benefits from encapsulation

Suggest creating a **new agent** when:
- Specialized expertise benefits from persona
- Multi-turn interaction pattern with specific knowledge

### 4. Consider Reorganization

Adding a learning may reveal opportunities to improve existing structure:

**Consolidate** when:
- Related content is scattered across multiple files
- Multiple small rules/skills could merge into one coherent resource
- Duplicate or overlapping guidance exists

**Refactor** when:
- Existing file has grown unfocused (split it)
- Learning reveals a better organizational structure
- Content belongs in a different location than where it currently lives

**Reorganize** when:
- New learning creates a theme that ties existing content together
- Skill references/ could absorb content from CLAUDE.md
- Project docs could absorb content from skills or rules

When proposing reorganization:
- Explain the current state and why it's suboptimal
- Show the proposed new structure
- List all files that would be affected
- Get explicit approval before making changes

### 5. Propose Updates

```markdown
## Proposed: [Title]
**Source**: [Quote from conversation]
**Target**: [File path]
**Change**: Create | Add | Modify | Remove
**Location Rationale**: [Why this is the best location - what was considered]
**Content**:
[Proposed content - clear, concise, actionable]
```

If suggesting a new file, explain:
- Why existing files don't fit
- What this new location would contain
- How it relates to other memory targets

### 6. Get Approval

Use AskUserQuestion. Options: Accept, Modify, Skip, Change location.

If user wants a different location, update the proposal accordingly.

### 7. Apply

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
**Location Rationale**: Searched for existing test config; none found. General project preference fits CLAUDE.md.
**Content**:
- Run tests with `bb test`
```

### New Command

> User: "I keep asking you to check coverage - make that easier"

```markdown
## Proposed: Coverage Command
**Source**: User wants quick coverage check
**Target**: ~/.claude/commands/coverage.md
**Change**: Create
**Location Rationale**: Repeated action pattern. No existing coverage command. Creating new command provides quick access.
**Content**:
---
description: Run tests with coverage report
---
Run test suite with coverage. Summarize percentages, highlight files below 80%.
```

### New Rule

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

### New Skill from Emerged Workflow

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

### Consolidation Opportunity

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
