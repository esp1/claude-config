# Documentation Review Checklist

Use this checklist when reviewing or auditing existing documentation.

## Directory Structure (Required)
- [ ] **Use exact directory names** — `docs/functional/` and `docs/technical/` are requirements, not suggestions
- [ ] **Rename non-conforming directories** — flag and fix during audit

## Hierarchy Violations
- [ ] **README.md vs docs/index.md** — README should be minimal (description + link only), no duplicated quick start or examples
- [ ] **docs/index.md links** — Should only link to top-level sections (functional/index.md, technical/index.md), not their children
- [ ] **Development content** — Must live in docs/technical/development.md, not in docs/index.md or README
- [ ] **API docs link** — Belongs in docs/technical/index.md, not docs/index.md

## Content Placement
- [ ] **Quick start** — Lives in ONE place only (docs/index.md), not also in README
- [ ] **Build commands** — Live in docs/technical/development.md only
- [ ] **Feature details** — Live in docs/functional/*.md, not in index files
- [ ] **Implementation details** — Live in docs/technical/*.md, not in functional specs

## Index File Rules
- [ ] **docs/index.md** — Contains: overview, quick start, links to functional/ and technical/ indexes only
- [ ] **docs/functional/index.md** — Contains: vision, feature list with one-line descriptions + links to specs
- [ ] **docs/technical/index.md** — Contains: stack, module list, links to development.md, API docs, and component docs

## Cross-Document Duplication
- [ ] **No repeated code examples** — Same example should not appear in multiple files
- [ ] **No repeated explanations** — Concepts explained once, linked elsewhere
- [ ] **Version/config values** — Never duplicated from source files into docs

## Content Quality
- [ ] **No duplication** — Each piece of info in exactly one place
- [ ] **Concise and clear** — No filler, short sentences, bullet points over paragraphs
- [ ] **Appropriate location** — Follows placement guidelines
- [ ] **Links valid** — All links point to existing files/sections
- [ ] **Functional specs clean** — No implementation details
- [ ] **Terminology consistent** — Same terms used across all docs
- [ ] **Index docs summarize and link** — Don't duplicate child doc content
