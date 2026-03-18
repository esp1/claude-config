# Clojure Project Structure Reference

Standard directory structures for Clojure projects using deps.edn.

## Single-Platform Projects (Clojure-only)

For projects targeting only the JVM:

```
project-name/
├── src/                    # Production source code
│   └── org/project_name/
│       └── core.clj
├── test/                   # Test files (mirror src/ structure)
│   └── org/project_name/
│       └── core_test.clj
├── deps.edn
├── bb.edn
└── .gitignore
```

## Multi-Platform Projects (CLJ + CLJS + CLJC)

For projects targeting multiple platforms (JVM, browser, both):

```
project-name/
├── src/
│   ├── clj/                # JVM-only (.clj)
│   │   └── org/project_name/
│   │       └── server.clj
│   ├── cljs/               # Browser-only (.cljs)
│   │   └── org/project_name/
│   │       └── app.cljs
│   └── cljc/               # Shared code (.cljc)
│       └── org/project_name/
│           └── views.cljc
├── test/
│   └── org/project_name/
├── deps.edn
├── bb.edn
├── squint.edn              # CLJS compilation config
└── package.json            # npm dependencies
```

**When to use:** PWAs, SPAs, or any project sharing code between server and client.

**Path configuration:**

| File | Paths |
|------|-------|
| `deps.edn` | `["src/clj" "src/cljc"]` |
| `bb.edn` | `["src/clj" "src/cljc"]` |
| `squint.edn` | `["src/cljs" "src/cljc"]` |

## Key Files

### deps.edn
- **:paths** - Source paths (typically `["src"]` or `["src/clj" "src/cljc"]`)
- **:deps** - Production dependencies (minimal for libraries)
- **:aliases** - Dev/test configurations (`:dev`, `:test`, `:run`)

### bb.edn
- **:paths** - Same as deps.edn for Babashka compatibility
- **:tasks** - Common: `test`, `dev`, `dev-repl`

## Conventions

- **Namespaces**: Use hyphens (`my-namespace`)
- **Files**: Use underscores (`my_namespace.clj`)
- **Tests**: Append `-test` (`my-namespace-test`)
- **Mapping**: `org.project-name.core` → `src/org/project_name/core.clj`

## Zero-Dependency Principle (Libraries)

- Keep production `:deps` empty or minimal
- Malli, test runners, dev tools in `:dev` or `:test` aliases only
