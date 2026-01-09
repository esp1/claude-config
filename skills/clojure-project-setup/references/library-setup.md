# Library Project Setup

This document provides additional configuration needed for Clojure library projects that publish API documentation.

## Overview

Library projects differ from applications in that they:
- Should have zero or minimal production dependencies
- Need API documentation generation (via Codox)
- Require versioning and publication configuration

## Additional Configuration for Libraries

### deps.edn with Codox

Add the `:codox` alias to your `deps.edn`:

```clojure
{:paths ["src"]
 :deps {}  ; Empty production dependencies for libraries

 :aliases
 {:dev
  {:extra-paths ["dev" "test"]
   :extra-deps {metosin/malli {:mvn/version "LATEST"}
                org.clojure/tools.namespace {:mvn/version "LATEST"}}}

  :test
  {:extra-paths ["test"]
   :extra-deps {metosin/malli {:mvn/version "LATEST"}}
   :main-opts ["-m" "cognitect.test-runner"]
   :exec-fn cognitect.test-runner.api/test}

  :codox
  {:extra-deps {codox/codox {:mvn/version "0.10.8"}}
   :exec-fn codox.main/generate-docs
   :exec-args {:source-paths ["src"]
               :output-path "docs/api"
               :metadata {:doc/format :markdown}}}}}
```

### bb.edn with Codox Task

Add the `codox` task to your `bb.edn`:

```clojure
{:min-bb-version "1.3.0"

 :paths ["src"]

 :deps {metosin/malli {:mvn/version "LATEST"}}

 :tasks
 {test
  {:doc "Run tests with Clojure"
   :task (clojure "-M:dev" "-m" "cognitect.test-runner")}

  codox
  {:doc "Generate API documentation"
   :task (clojure "-X:codox")}}}
```

### Version Control for API Docs

**Commit `docs/api/` to version control** if you want to publish API docs via GitHub Pages or similar static hosting. This allows the docs to be served directly from the repository.

If you prefer to generate docs only during CI/CD, you can add `docs/api/` to `.gitignore` instead.

## Usage

After setting up codox:

```bash
# Generate API documentation
bb codox

# Documentation will be generated in docs/api/
# Open docs/api/index.html to view
```

## Codox Configuration Options

Customize the `:exec-args` in the `:codox` alias to control documentation output:

```clojure
:codox
{:extra-deps {codox/codox {:mvn/version "0.10.8"}}
 :exec-fn codox.main/generate-docs
 :exec-args {:source-paths ["src"]
             :output-path "docs/api"
             :metadata {:doc/format :markdown}
             :namespaces [my.lib.core my.lib.util]  ; Optional: limit namespaces
             :doc-paths ["docs"]                     ; Optional: include markdown docs
             :source-uri "https://github.com/org/project/blob/{version}/{filepath}#L{line}"}}
```

## Zero-Dependency Principle

Libraries should keep production dependencies minimal:

- **:deps** should be empty or contain only essential dependencies
- All dev tools (Malli, test runners, Codox) go in `:aliases`
- Document any production dependencies clearly in README
- Consider making dependencies optional where possible

## Library Checklist

When creating a library project:

- [ ] Keep `:deps` empty or minimal
- [ ] Add `:codox` alias to `deps.edn`
- [ ] Add `codox` task to `bb.edn`
- [ ] Write comprehensive namespace and function documentation in source code
- [ ] Generate initial API docs with `bb codox`
- [ ] Commit `docs/api/` for GitHub Pages (or add to `.gitignore` if using CI/CD)
- [ ] Link to API docs from markdown documentation (don't duplicate content)
- [ ] Include API documentation link in README
