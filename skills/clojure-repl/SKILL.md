---
name: clojure-repl
description: This skill should be used when developing, testing, or debugging Clojure code using REPL-driven development. It provides a workflow for iterative development with immediate feedback, emphasizing small incremental steps, testing in the REPL before committing to files, and maintaining high code quality through continuous validation. Use when actively working on Clojure features or debugging issues.
---

# Clojure REPL

## Overview

Guide REPL-driven development workflow for Clojure projects. This skill emphasizes "tiny steps with high quality rich feedback" as the foundational approach, enabling rapid iteration with immediate validation before committing code to files.

## When to Use This Skill

Invoke this skill when:
- Developing new Clojure features or functions
- Debugging Clojure code
- Testing ideas or exploring APIs
- Refactoring existing code
- Learning about unfamiliar codebases
- Prototyping solutions before implementation

## Connecting to a Running nREPL

For projects with a running development server or REPL, connect to the existing nREPL session rather than starting a new one. This allows testing code in the actual runtime environment with live application state.

### Finding a Running nREPL

Check for a `.nrepl-port` file in the project directory:

```bash
# Check if nREPL is running
cat .nrepl-port
# => 54321 (the port number)
```

If the file exists, an nREPL server is running on that port. Use this port to connect and evaluate code.

### Starting an nREPL Server

If no `.nrepl-port` file exists, start an nREPL server using one of these methods (in priority order):

**1. Check for Babashka tasks** (`bb.edn`)

```bash
# List available tasks
bb tasks

# Common REPL task names: repl, nrepl, dev
bb repl
# or
bb nrepl
# or
bb dev  # May include nREPL server
```

**2. Check for Clojure aliases** (`deps.edn`)

```bash
# Look at deps.edn aliases section
# Common REPL aliases: :repl, :nrepl, :dev

clojure -M:repl
# or
clojure -M:dev
```

**3. Start a basic nREPL server**

If no project-specific configuration exists:

```bash
# Babashka nREPL
bb nrepl-server

# Clojure nREPL
clojure -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.1.0"}}}' -M -m nrepl.cmdline
```

After starting, the `.nrepl-port` file will be created containing the port number.

### When to Connect vs. Start Fresh REPL

**Connect to running nREPL when:**
- A development server is already running (`bb dev`, etc.)
- Testing code against live application state
- Debugging runtime issues in the actual environment
- Hot-reloading code changes into running app

**Start fresh REPL when:**
- No development server is running
- Working on standalone functions or utilities
- Prototyping new features in isolation
- The application doesn't need to be running

## Core Philosophy: Incremental Verification

**Small steps beat big leaps.** The REPL excels at providing immediate feedback on small, focused code snippets. Use this to your advantage by:

1. **Test before committing** - Validate code in REPL first
2. **Build incrementally** - Add one piece at a time
3. **Verify continuously** - Check each step works before proceeding
4. **Save only what works** - Move validated code to files

### Why This Works

Current LLMs are excellent at using the Clojure REPL because:
- Immediate feedback catches errors quickly
- Small iterations reduce complexity
- Syntax errors are found instantly
- Logic can be verified step-by-step
- **The form and maintainability of ephemeral code DOES NOT MATTER** - only the final saved code needs to be clean

## REPL-Driven Development Workflow

### Phase 1: Problem Definition

Clearly articulate what you're solving:
- What is the goal?
- What inputs and outputs are expected?
- What constraints or requirements exist?

### Phase 2: REPL Prototyping

Work through solutions incrementally in the REPL:

```clojure
;; Start with data
(def sample-data {:name "Alice" :age 30})

;; Test individual operations
(:name sample-data)
;; => "Alice"

;; Build up logic piece by piece
(defn format-name [person]
  (str "Name: " (:name person)))

(format-name sample-data)
;; => "Name: Alice"

;; Add complexity incrementally
(defn format-person [person]
  (str (format-name person)
       ", Age: " (:age person)))

(format-person sample-data)
;; => "Name: Alice, Age: 30"
```

### Phase 3: Step-by-Step Validation

Test each expression before advancing:

```clojure
;; Test edge cases
(format-person {:name "Bob"})
;; Error! Missing :age

;; Fix and retest
(defn format-person [person]
  (str (format-name person)
       (when-let [age (:age person)]
         (str ", Age: " age))))

(format-person {:name "Bob"})
;; => "Name: Bob"

(format-person sample-data)
;; => "Name: Alice, Age: 30"
```

### Phase 4: File Integration

Save working solutions to source files:

```clojure
;; Once validated in REPL, save to file
;; Use clojure-edit skill to add to appropriate namespace
```

### Phase 5: Verification

Reload and confirm saved code functions correctly:

```clojure
;; Reload namespace
(require '[my.namespace :as ns] :reload)

;; Test from namespace
(ns/format-person sample-data)
;; => "Name: Alice, Age: 30"

;; Run tests
(clojure.test/run-tests 'my.namespace-test)
```

## REPL Commands and Techniques

For namespace management, code exploration, data inspection, and other REPL commands, see `references/repl_workflows.md`.

### Using the inspect_namespace Script

This skill includes a Babashka script for quickly exploring namespace contents without loading them in the REPL. The script requires `bb` (Babashka) to be installed globally on your system:

```bash
# Inspect a namespace file, showing all public functions
scripts/inspect_namespace.clj src/my/namespace.clj

# Include private functions
scripts/inspect_namespace.clj src/my/namespace.clj --with-private

# Show only function names (useful for quick reference)
scripts/inspect_namespace.clj src/my/namespace.clj --names-only

# Show summary statistics
scripts/inspect_namespace.clj src/my/namespace.clj --summary
```

**Output includes:**
- Namespace name and docstring
- Function names, types (defn, defn-, def, defmethod)
- Function signatures (argument vectors)
- Docstrings
- Line numbers
- Public/private visibility

**Use cases:**
- Quickly understand what functions are available before loading in REPL
- Find specific functions by scanning output
- Document namespace API surface
- Plan REPL exploration strategy

## Workflow Decision Tree

```
Starting new feature or debugging?
│
├─ New feature development
│  ├─ 1. Define sample data in REPL
│  ├─ 2. Build functions incrementally
│  ├─ 3. Test each piece as you go
│  ├─ 4. Refine based on edge cases
│  ├─ 5. Save working code to file (clojure-edit skill)
│  └─ 6. Reload namespace and verify
│
├─ Debugging existing code
│  ├─ 1. Reload namespace with problem
│  ├─ 2. Reproduce issue in REPL
│  ├─ 3. Isolate problematic expression
│  ├─ 4. Test fixes incrementally
│  ├─ 5. Apply fix to file (clojure-edit skill)
│  └─ 6. Verify with tests
│
├─ Exploring unfamiliar code
│  ├─ 1. Load namespace in REPL
│  ├─ 2. Use (dir ns) to see functions
│  ├─ 3. Use (doc fn) and (source fn)
│  ├─ 4. Test functions with sample data
│  └─ 5. Build understanding incrementally
│
└─ Refactoring
   ├─ 1. Load current implementation
   ├─ 2. Create test data that covers cases
   ├─ 3. Verify current behavior
   ├─ 4. Build new implementation in REPL
   ├─ 5. Test against same data
   ├─ 6. Save when behavior matches
   └─ 7. Run test suite to verify
```

## Best Practices

### Do:
- **Make tiny steps** - Build complexity gradually
- **Test continuously** - Verify each step works
- **Use real data** - Test with actual inputs you'll encounter
- **Explore freely** - Try different approaches in REPL
- **Fail fast** - Find errors quickly in REPL rather than after saving
- **Reload often** - Keep REPL state fresh with `:reload`

### Don't:
- **Skip testing** - Don't assume code works without trying it
- **Write big blocks** - Don't build complex functions all at once
- **Ignore errors** - Don't move forward when something fails
- **Save untested code** - Don't commit to files before REPL validation
- **Trust stale state** - Don't forget to reload after file changes

## Integration with Testing

### Running Tests from REPL

```clojure
;; Run all tests in namespace
(require '[clojure.test :refer [run-tests]])
(run-tests 'my.namespace-test)

;; Run specific test
(require '[clojure.test :refer [test-var]])
(test-var #'my.namespace-test/my-test-name)
```

### Interactive Test Development

```clojure
;; 1. Write test in REPL
(deftest user-validation-test
  (testing "valid user"
    (is (valid-user? {:name "Alice" :email "alice@example.com"})))
  (testing "invalid user"
    (is (not (valid-user? {:name "Bob"})))))

;; 2. Run test
(test-var #'user-validation-test)

;; 3. Fix failures
(defn valid-user? [user]
  (and (:name user) (:email user)))

;; 4. Rerun test
(test-var #'user-validation-test)

;; 5. Save test to file when passing
```

## Running Tests via CLI

```bash
# Run all tests
clojure -X:test

# Run specific namespace
clojure -X:test :namespace 'my.namespace.test'

# Run with options
clojure -M:dev -m clojure.test.runner
```

## Reference Materials

For REPL commands, development patterns (data-first, bottom-up, exploratory, debugging), session flow examples, and advanced techniques, see `references/repl_workflows.md`.
