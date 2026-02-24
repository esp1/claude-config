---
name: clojure-project-setup
description: This skill should be used when working with Clojure project structure and configuration. It provides conventions for organizing projects, configuration templates for deps.edn and bb.edn, and Malli schema integration patterns. Use when creating new Clojure projects, adapting existing projects to follow best practices, or setting up specific project types (libraries, web applications). Covers dependency management via deps.edn, task automation via Babashka, and schema validation via Malli.
---

# Clojure Project Structure and Setup

## Overview

This skill provides comprehensive guidance for structuring and configuring Clojure projects with modern tooling and best practices. It covers project organization, dependency management with deps.edn, task automation with Babashka (bb.edn), and Malli schema integration for validation and generative testing.

Use this skill to:
- Create new Clojure projects from scratch
- Adapt existing projects to follow these conventions
- Configure specific project types (libraries, web applications)
- Understand and apply project structure best practices

## When to Use This Skill

Invoke this skill when:
- Creating a new Clojure project from scratch
- Adapting an existing project to follow these conventions
- Setting up a library or web application structure
- Configuring or reviewing deps.edn and bb.edn
- Integrating Malli schemas into a project
- Understanding project organization best practices

## Project Setup Workflow

This workflow applies to both new projects and adapting existing projects.

### Step 1: Understand Project Requirements

Before scaffolding, gather the following information:

1. **Project name** - The name of the project (e.g., `my-router`, `data-processor`)
2. **Organization** - The organization/author namespace (e.g., `acme`, `mycompany`)
3. **Project type** - Library (minimal dependencies) or application (may have dependencies)
4. **Core dependencies** - Any production dependencies needed (libraries should have minimal/zero)

**Example questions to ask:**
- "What is the project name?"
- "What organization namespace should be used (e.g., 'acme' for acme.my-project)?"
- "Is this a library (minimal dependencies) or an application?"
- "What production dependencies are needed?"

### Step 2: Initialize Git Repository

Initialize git version control at the start of the project:

```bash
cd <project-name>
git init
```

This ensures:
- All project files are tracked from the beginning
- You can commit incrementally as you set up the project
- The `.gitignore` file (added later) takes effect immediately

**For existing projects:** Verify git is initialized (`git status`). If not, initialize it.

### Step 3: Set Up Devbox

Set up devbox with direnv to manage project tools (Clojure CLI, Babashka). See `references/devbox-setup.md` for details.

### Step 4: Ensure Proper Directory Structure

**For new projects:** Create the basic directory structure:

```bash
mkdir -p <project-name>/src/<org>/<project_name>
mkdir -p <project-name>/test/<org>/<project_name>
```

**Example:**
```bash
mkdir -p my-router/src/acme/my_router
mkdir -p my-router/test/acme/my_router
```

**For existing projects:** Verify the directory structure matches conventions. Reorganize if needed.

**Note:** Use underscores in directory names for hyphens in the project name (e.g., `my-router` → `my_router/`)

See `references/project-structure.md` for detailed directory layout conventions.

### Step 5: Configure deps.edn and bb.edn

**For new projects:** Copy and customize the template files from `assets/`.

**For existing projects:** Review and update configuration to match conventions.

#### deps.edn
Copy `assets/deps.edn.template` to the project root as `deps.edn` and customize:

- **:paths** - Keep as `["src"]` for production code
- **:deps** - Add production dependencies (keep minimal for libraries)
- **:aliases** - Customize development, testing, and documentation aliases

**Key aliases:**
- `:dev` - Development dependencies (Malli, tools.namespace)
- `:test` - Test runner configuration

**For libraries only:** Add `:codox` alias for API documentation generation

#### bb.edn
Copy `assets/bb.edn.template` to the project root as `bb.edn` and customize:

- **:tasks** - Define common development tasks
- Standard task: `test`
- Add custom build, deployment, or utility tasks as needed
- **For libraries:** Add `codox` task for API documentation

**Example custom tasks:**
```clojure
:tasks
{build
 {:doc "Build the project for production"
  :task (clojure "-T:build" "uber")}

 dev-repl
 {:doc "Start a REPL with dev dependencies"
  :task (clojure "-M:dev")}}
```

#### .gitignore
Copy `assets/gitignore.template` to the project root as `.gitignore`.

### Step 6: Create Initial Source Files

#### Core namespace (src/)

Create the main namespace file with Malli schema metadata:

```clojure
(ns acme.my-router.core
  "Core routing functionality."
  (:require [clojure.string :as str]))

(defn greet
  "Returns a greeting message."
  {:malli/schema [:=> [:cat :string] :string]}
  [name]
  (str "Hello, " name "!"))
```

**Key principles:**
- Add docstrings to all public functions
- Include `:malli/schema` metadata for function validation
- Keep production code clean and dependency-free

#### Test namespace (test/)

Create the corresponding test file:

```clojure
(ns acme.my-router.core-test
  (:require [clojure.test :refer [deftest is testing]]
            [acme.my-router.core :as core]))

(deftest greet-test
  (testing "greet returns a greeting message"
    (is (= "Hello, World!" (core/greet "World")))))
```

### Step 7: Set Up Malli Schema Integration

For projects using Malli schemas:

1. **Function schemas** - Add as `:malli/schema` metadata on each function:
   ```clojure
   (defn my-fn
     {:malli/schema [:=> [:cat :string :int] :boolean]}
     [s n]
     ...)
   ```

2. **Data structure schemas** - Define in dedicated schema namespaces:
   ```clojure
   (ns acme.my-router.schema
     (:require [malli.core :as m]))

   (def RouteConfig
     [:map
      [:path :string]
      [:handler fn?]])
   ```

3. **Schema registries** - Create custom registries for project-specific schemas:
   ```clojure
   (defn route-schemas []
     {:RouteConfig RouteConfig
      :PathParams [:map-of :string :string]})
   ```

4. **Test setup** - Register schemas in test fixtures:
   ```clojure
   (use-fixtures :once
     (fn [f]
       (mr/set-default-registry!
        (merge
         (m/base-schemas)
         (schema/route-schemas)))
       (f)
       (mr/set-default-registry! m/default-registry)))
   ```

**Important:** Malli should be a dev/test dependency only, not a production dependency.

### Step 8: Create Documentation

For comprehensive documentation setup, invoke the `doc-sync` skill, which handles:
- README.md structure and content
- CLAUDE.md for Claude Code instructions
- Documentation hierarchy and synchronization

At minimum, create a basic README.md with:
- Project name and description
- Installation instructions
- Basic usage example
- Development commands (`bb test`, etc.)

### Step 9: Verify Setup and Make Initial Commit

Run tests to verify everything is working:

```bash
bb test
```

Then make your initial commit:

```bash
git add .
git commit -m "Initial project setup

- Standard deps.edn and bb.edn configuration
- Basic project structure (src/, test/, docs/)
- Core namespace with example function
- Test setup with Malli integration"
```

## Project Structure Reference

For detailed information on directory layout, file conventions, and Malli schema organization, see `references/project-structure.md`.

## Common Patterns

### Library Projects

Libraries require additional configuration for API documentation generation and should maintain zero or minimal production dependencies.

See `references/library-setup.md` for Codox configuration, zero-dependency principles, and the library-specific checklist.

### Web Application Projects

Web applications using Ring and FSR require additional configuration and directory structure.

See `references/web-app-setup.md` for Ring/FSR dependency configuration, routes directory structure, development server setup, and middleware configuration.

### Multi-Module Projects

For projects with multiple modules, organize as:

```
my-project/
├── core/
│   ├── src/
│   └── deps.edn
├── web/
│   ├── src/
│   └── deps.edn
└── deps.edn (root)
```

## Quick Start Checklist

When creating a new Clojure project:

- [ ] Gather project requirements (name, org, type, dependencies)
- [ ] Initialize git repository (`git init`)
- [ ] Set up devbox with direnv (see `references/devbox-setup.md`)
- [ ] Create directory structure with `mkdir -p` commands
- [ ] Copy and customize `deps.edn` from template
- [ ] Copy and customize `bb.edn` from template
- [ ] Copy `.gitignore` from template
- [ ] Create initial namespace in `src/`
- [ ] Create corresponding test in `test/`
- [ ] Add Malli schemas to functions (`:malli/schema` metadata)
- [ ] Create basic README.md (or invoke `doc-sync` skill for comprehensive docs)
- [ ] Run `bb test` to verify setup
- [ ] Make initial commit
