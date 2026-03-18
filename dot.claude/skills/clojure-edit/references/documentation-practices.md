# Documentation Practices for Clojure Code

## Source Code Documentation is the Single Source of Truth

- Prefer self-documenting code — use descriptive names for functions, parameters, and bindings so the code communicates intent without comments
- Reserve docstrings and comments for intent not obvious from the code — explain *why* a design choice was made, not *what* the code does
- Include usage examples and edge cases in docstrings when the function's contract is non-obvious
- Use markdown formatting in documentation strings (supported by Codox with `:metadata {:doc/format :markdown}`)
- Technical markdown docs should link to generated API docs, not duplicate content
- **Malli schemas are authoritative for types** - don't duplicate parameter/return type info in documentation strings; the `:malli/schema` metadata is the source of truth for function signatures

## Linking to Codox API Docs

When referencing functions in markdown documentation, link to the Codox-generated API docs:

```markdown
See [wrap-fs-router](../api/esp1.fsr.ring.html#var-wrap-fs-router) for details.
```

Codox anchor format: `namespace.html#var-function-name`
- Hyphens in function names stay as hyphens
- Special characters are URL-encoded (e.g., `->` becomes `.3E`, `!` becomes `.21`)

## Codox Setup

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

## Cross-Cutting Concerns Belong in External Docs

When a concept influences many disparate parts of the codebase, capture it as an external document (in `docs/`) rather than comments scattered across individual functions. Examples: architectural decisions, naming conventions, error handling strategies, security policies. Individual functions should reference the external doc, not re-explain the concept.

For project-level documentation structure and placement, consult the **doc-sync** skill.
