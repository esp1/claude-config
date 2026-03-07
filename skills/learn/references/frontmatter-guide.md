# Skill & Agent Frontmatter Guide

When creating or updating skills/agents, consider these frontmatter options to make behavior more deterministic and appropriate.

## Model Selection (`model`)

- `haiku` - Fast, simple tasks (formatting, lookups, straightforward edits)
- `sonnet` - Balanced tasks (most workflows, code generation)
- `opus` - Complex reasoning (architecture decisions, debugging, schema design)

## Hooks (`hooks`)

Add deterministic validation:

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "test -f .nrepl-port"  # Verify precondition
```

Use hooks when:
- A binary pass/fail precondition exists (file exists, command available)
- Skill cannot proceed meaningfully without the precondition
- Validation is deterministic, not judgment-based

## Tool Restrictions (`allowed-tools`)

- Restrict to specific tools for safety or focus
- Example: `allowed-tools: Read, Grep, Glob` for read-only skills

## Arguments (`$ARGUMENTS`)

- Use `$ARGUMENTS` in skill content to accept user input
- Document expected arguments in the skill description

## Forked Context (`context: fork`)

- Run skill in isolated sub-agent context
- Combine with `agent` to specify agent type

## Visibility (`user-invocable`)

- Set `false` for skills triggered only programmatically
- Default is `true` (appears in slash command menu)

## Example Skill with Frontmatter

```yaml
---
name: validate-schema
description: Validate Malli schemas in Clojure files
model: haiku
allowed-tools: Read, Grep, Glob, Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "test -f deps.edn"
---
```
