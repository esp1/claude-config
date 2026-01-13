---
name: clojure-edit
description: This skill should be used when reading or editing Clojure, ClojureScript, or CLJC files. It provides best practices for structural editing that preserves syntactic correctness, handles parentheses properly, and follows Clojure idioms. Use this skill when working with .clj, .cljs, or .cljc files to ensure code quality and prevent syntax errors.
---

# Clojure Edit

## Overview

Provide guidance for reading and editing Clojure code with attention to structural correctness, idiomatic patterns, and proper handling of s-expressions. This skill addresses the common challenge of maintaining balanced parentheses and syntactically correct code when making modifications.

## Clojure LSP Integration

The **clojure-lsp plugin** provides real-time diagnostics for Clojure files. Use `mcp__ide__getDiagnostics` to check for syntax errors, unresolved symbols, and other issues after editing.

**Supported file types:** `.clj`, `.cljs`, `.cljc`, `.edn`, `.bb`, `.cljd`

**Workflow:**
1. Make edits using the patterns in this skill
2. Call `mcp__ide__getDiagnostics` to verify no errors were introduced
3. Fix any issues before proceeding

## When to Use This Skill

Invoke this skill when:
- Reading `.clj`, `.cljs`, or `.cljc` files
- Editing Clojure code (functions, forms, expressions)
- Refactoring Clojure code while preserving correctness
- Adding new code to existing Clojure files
- Need to follow Clojure best practices and idioms

## Important Workflow Reminders

- **After making successful code changes**, invoke `/doc-sync` to keep documentation synchronized
- **Before committing**, ensure `/doc-sync` has been run to update all affected documentation

## Reading Clojure Files

### Pattern-Based Reading Strategy

When reading Clojure files, use focused exploration rather than reading entire files:

1. **Read by namespace pattern**: Target specific namespaces or symbols
2. **Read by content pattern**: Search for specific forms or expressions
3. **Read strategically**: Focus on relevant sections to minimize context usage

### Using the read_clojure_file Script

This skill includes a Babashka script for pattern-based, structure-aware file reading. The script requires `bb` (Babashka) to be installed globally on your system:

```bash
# Find all defn forms, showing only signatures (collapsed view)
scripts/read_clojure_file.clj src/my/namespace.clj --form-type defn --collapsed

# Find functions by name pattern
scripts/read_clojure_file.clj src/my/namespace.clj --name-pattern "^process-"

# Search for content within forms
scripts/read_clojure_file.clj src/my/namespace.clj --content-pattern "http-request"

# Combine filters
scripts/read_clojure_file.clj src/my/namespace.clj --form-type defn --name-pattern "user" --collapsed
```

**Benefits:**
- Shows only function signatures when using `--collapsed`, not full bodies
- Filters by form type (defn, defmethod, def, etc.)
- Pattern matching on names and content
- Reduces context usage by focusing on relevant code

### Before Editing

Always read the file before editing IF:
- You haven't read it yet in this session
- External modifications might have occurred
- You need current context about the code structure

Skip reading ONLY if:
- You just wrote the file in the previous tool call
- You have current context from earlier in the session

## Editing Clojure Code Correctly

### Core Principle: Respect the Structure

Clojure code is built from s-expressions (forms). Always edit at the form level, not the character level.

### Editing Strategy

**1. Read First** (if needed)
```
Use Read tool to understand current structure
```

**2. Identify the Form to Edit**
- Locate the specific `defn`, `def`, `let`, or other form
- Understand its boundaries (opening and closing parens)
- Note indentation and surrounding context

**3. Use Edit Tool with Complete Forms**
- Provide complete, balanced s-expressions
- Match exact indentation from the source
- Include ALL parens in both old_string and new_string

**4. Verify Syntax**
- Ensure all opening parens have closing parens
- Check that brackets `[]` and braces `{}` are balanced
- Verify string quotes are closed

### Using the edit_clojure_form Script

This skill includes a Babashka script for form-aware editing that targets functions by name rather than text matching. The script requires `bb` (Babashka) to be installed globally on your system and resolves file paths relative to your current working directory.

#### Basic Usage

```bash
# Replace an entire function by name
scripts/edit_clojure_form.clj --file src/my/namespace.clj \
  --name my-function \
  --operation replace \
  --new-form "(defn my-function [x y]\n  (+ x y 10))"

# Insert a new function before an existing one
scripts/edit_clojure_form.clj --file src/my/namespace.clj \
  --name existing-function \
  --operation insert-before \
  --new-form "(defn helper [x]\n  (* x 2))"

# Insert after a function
scripts/edit_clojure_form.clj --file src/my/namespace.clj \
  --name my-function \
  --operation insert-after \
  --new-form "(defn related-function [x]\n  (my-function x x))"

# Target specific form types (useful for defmethod, etc.)
scripts/edit_clojure_form.clj --file src/my/namespace.clj \
  --name area \
  --form-type defmethod \
  --operation replace \
  --new-form "(defmethod area :circle [shape]\n  (* Math/PI (:radius shape) (:radius shape)))"
```

#### Working with Complex Multi-line Forms

For large or complex forms, use a heredoc with command substitution to avoid shell escaping issues:

```bash
# Use heredoc directly - no temp file needed!
scripts/edit_clojure_form.clj --file src/my/file.clj \
  --name old-function \
  --operation replace \
  --new-form "$(cat <<'EOF'
(defn my-complex-function
  "A complex function with lots of lines"
  {:malli/schema [:=> [:catn
                       [:name :string]
                       [:count :int]]
                  :string]}
  [name count]
  (let [result (complex-calculation name)]
    (process-with count result)))
EOF
)"
```

**Key points:**
- Use `$(cat <<'EOF' ... EOF)` - heredoc wrapped in command substitution
- Single quotes around `'EOF'` prevent variable expansion inside the heredoc
- No temp files needed - everything is inline and self-contained
- Cleaner and more atomic than writing to temp files

**Alternative: Temp files** (if heredocs don't work in your shell)
```bash
cat > /tmp/my-form.clj << 'FORM_EOF'
(defn my-complex-function ...)
FORM_EOF

scripts/edit_clojure_form.clj --file src/my/file.clj \
  --name old-function \
  --operation replace \
  --new-form "$(cat /tmp/my-form.clj)"
```

Both approaches avoid issues with newlines, quotes, and special characters in command-line arguments.

#### Handling Function Names with Special Characters

Function names containing arrows (`->`, `->>`) or other shell-special characters must be quoted:

```bash
# CORRECT - quotes protect the arrow from shell interpretation
scripts/edit_clojure_form.clj --file src/my/file.clj \
  --name 'uri->endpoint-fn' \
  --operation replace \
  --new-form "..."

# WRONG - shell will interpret -> as redirection
scripts/edit_clojure_form.clj --file src/my/file.clj \
  --name uri->endpoint-fn \
  --operation replace \
  --new-form "..."
```

#### Preview Changes with Dry Run

Always preview complex edits before applying them. The `--dry-run` flag prints the result without writing to the file:

```bash
scripts/edit_clojure_form.clj --file src/my/file.clj \
  --name my-function \
  --operation replace \
  --new-form "$(cat /tmp/new-form.clj)" \
  --dry-run | head -50
```

Use dry-run especially when:
- Editing critical functions
- Making large changes
- Unsure if the edit will work correctly
- Editing the script itself (self-editing)

#### Understanding Error Messages

The script provides detailed error messages to stderr:

- **"Form not found: `<name>`"** - The target form doesn't exist, or the name is misspelled. Check that the function/form exists and the name matches exactly.

- **"Exception during edit: `<details>`"** - A parsing or manipulation error occurred. The message includes a stack trace showing where the error happened. Common causes:
  - Unbalanced parentheses in `--new-form`
  - Invalid Clojure syntax in the new form
  - File path issues

- **Location information** - Shows the file and line number where the error occurred, helpful for debugging.

When debugging errors, run the command without `2>&1` redirection to see the full error output with proper formatting.

#### Working Directory Considerations

The script resolves file paths relative to your current working directory:

```bash
# From project root
~/.claude/skills/clojure-edit/scripts/edit_clojure_form.clj \
  --file src/my/file.clj --name foo --operation replace --new-form "..."

# From a subdirectory - adjust the path accordingly
cd src && ~/.claude/skills/clojure-edit/scripts/edit_clojure_form.clj \
  --file my/file.clj --name foo --operation replace --new-form "..."
```

Stay in a consistent directory (usually project root) to avoid path confusion.

#### Self-Editing Precautions

When editing the script itself, exercise extra care:

1. Always use `--dry-run` first to verify the edit
2. Keep a backup or rely on git to restore if needed
3. Test the script immediately after editing
4. Syntax errors will break the tool until fixed

**Benefits:**
- Targets forms by name, not text patterns (more reliable)
- Preserves surrounding code structure
- Operations: replace, insert-before, insert-after
- Syntax validation via rewrite-clj
- Dry-run mode for safety

### Common Editing Patterns

#### Adding a New Function

```clojure
;; Use Edit to add after existing function
;; old_string: (end of previous function)
;; new_string: (end of previous function)\n\n(defn new-function [...] ...whole form...)

;; OR use the form-editing script:
;; scripts/edit_clojure_form.clj --file <file> --name <existing-fn> --operation insert-after --new-form "<new-defn>"
```

#### Modifying Function Body

```clojure
;; Replace entire defn form
;; old_string: (defn old-impl [args]\n  old-body)
;; new_string: (defn old-impl [args]\n  new-body)

;; OR use the form-editing script:
;; scripts/edit_clojure_form.clj --file <file> --name old-impl --operation replace --new-form "<new-defn>"
```

#### Adding to Let Bindings

```clojure
;; Replace entire let form
;; old_string: (let [existing bindings]\n  body)
;; new_string: (let [existing bindings\n        new-binding value]\n  body)
```

## Clojure Best Practices

### Conditionals

- Use `if` for single conditions
- Use `cond` for multiple branches
- Use `if-let` and `when-let` to bind and test simultaneously
- Use `when` for single-result conditionals without else
- Consider `cond->` and `cond->>` for threading with conditions

### Variable Binding

- Avoid unnecessary `let` bindings
- Inline single-use values
- Bind variables only when reused or for clarity
- Use threading macros (`->`, `->>`) to eliminate intermediate bindings

### Destructuring

Use destructuring in function parameters for clarity:

```clojure
;; For namespaced keywords
(defn handler [{:keys [::namespaced-key ::other] :as ctx}]
  ...)

;; For regular keywords
(defn handler [{:keys [regular-key other] :as ctx}]
  ...)
```

### Control Flow

- Track actual values instead of boolean flags
- Use early returns with `when` to reduce nesting
- Return `nil` for "not found" rather than flag-bearing objects

### Function Design

- Each function should serve a single purpose
- Prioritize pure functions over side-effect-based implementations
- Return meaningful values for downstream use
- Keep functions small and focused

### Library Usage

- Prefer `clojure.string` over Java interop
  - Use `str/blank?` instead of `.isEmpty`
- Follow naming conventions: predicates end with `?`
- Use idiomatic built-in functions

## Parenthesis Management

### Golden Rules

1. **Never edit partial forms** - Always include complete s-expressions
2. **Count your parens** - Opening parens must equal closing parens
3. **Match indentation** - Preserve the source's indentation style
4. **Edit structurally** - Think in forms, not lines

### Common Paren Errors to Avoid

❌ **Missing closing paren:**
```clojure
(defn foo [x]
  (+ x 1)  ;; Missing closing paren for defn!
```

✅ **Correct:**
```clojure
(defn foo [x]
  (+ x 1))  ;; All parens balanced
```

❌ **Extra closing paren:**
```clojure
(defn foo [x]
  (+ x 1)))  ;; Extra closing paren!
```

❌ **Mismatched brackets:**
```clojure
(defn foo [x}  ;; [ paired with }
  (+ x 1))
```

✅ **Correct:**
```clojure
(defn foo [x]  ;; [ paired with ]
  (+ x 1))
```

### Self-Checking Strategy

Before submitting an edit:
1. Count opening parens in new_string
2. Count closing parens in new_string
3. Verify they match
4. Check bracket [] and brace {} pairs
5. Verify string quotes are paired

## Editing Decision Tree

```
Need to modify Clojure file?
│
├─ Adding new top-level form (defn, def, etc.)?
│  └─ Use Edit: old_string = end of file or previous form
│                new_string = previous context + new complete form
│
├─ Modifying existing function?
│  ├─ Small change (rename, add param)?
│  │  └─ Use Edit: Replace entire defn form
│  │
│  └─ Complete rewrite?
│     └─ Use Edit: Replace entire defn form
│
├─ Adding to existing form (let, cond, etc.)?
│  └─ Use Edit: Replace entire parent form
│
└─ Renaming symbol across file?
   └─ Use Edit with replace_all: true
      (Be careful with common names!)
```

## Integration with REPL Workflow

When working with REPL-driven development:
1. Prototype code in REPL first (see clojure-repl skill)
2. Once code works in REPL, use this skill to save to files
3. Use Read to verify the saved code
4. Reload namespace in REPL to confirm integration

## Documentation Practices

### Source Code Documentation is the Single Source of Truth

- Write comprehensive namespace and function documentation in the source code
- Include usage examples and edge cases in documentation strings
- Use markdown formatting in documentation strings (supported by Codox with `:metadata {:doc/format :markdown}`)
- Technical markdown docs should link to generated API docs, not duplicate content
- **Malli schemas are authoritative for types** - don't duplicate parameter/return type info in documentation strings; the `:malli/schema` metadata is the source of truth for function signatures

### Linking to Codox API Docs

When referencing functions in markdown documentation, link to the Codox-generated API docs:

```markdown
See [wrap-fs-router](../api/esp1.fsr.ring.html#var-wrap-fs-router) for details.
```

Codox anchor format: `namespace.html#var-function-name`
- Hyphens in function names stay as hyphens
- Special characters are URL-encoded (e.g., `->` becomes `.3E`, `!` becomes `.21`)

### Codox Setup

Configure Codox to output API docs to `docs/api/`:

```clojure
;; deps.edn
:codox {:extra-deps {codox/codox {:mvn/version "0.10.8"}}
        :exec-fn codox.main/generate-docs
        :exec-args {:source-paths ["src"]
                    :output-path "docs/api"
                    :metadata {:doc/format :markdown}
                    :source-uri "https://github.com/org/project/blob/{version}/{filepath}#L{line}"}}
```

**Important**: Commit `docs/api/` to version control for GitHub Pages publishing. Do NOT add it to `.gitignore`.

Run `bb codox` (or `clojure -X:codox`) to regenerate after updating source documentation.

## Reference Materials

For detailed Clojure coding standards and additional patterns, see:
- `references/clojure_best_practices.md` - Comprehensive coding guidelines
