---
name: doc-sync
description: This skill should be used when creating, updating, or synchronizing project documentation. It maintains consistency across the documentation index, functional requirement specs, and technical documentation. Use this skill when changes are made to any documentation file, when creating new requirement or technical docs, or when ensuring documentation hierarchy and cross-references remain accurate. IMPORTANT: Invoke this skill proactively after making successful code changes to keep documentation in sync - not just when explicitly asked.
---

# Doc Sync

## Overview

Maintain synchronized, hierarchical project documentation following a structured system where high-level documents link to detailed specifications, requirement specs remain implementation-agnostic, and technical docs reference features appropriately.

## When to Invoke This Skill

**Invoke this skill proactively in these scenarios:**

1. **After successful code changes** - When you've implemented a feature, fixed a bug, or refactored code that affects how the system works
2. **After figuring something out** - When exploratory work leads to understanding that should be documented
3. **When documentation is explicitly requested** - User asks to update or create docs
4. **When you notice outdated docs** - During code work, if you see docs that no longer match reality
5. **When creating new features** - Document both requirements (what/why) and implementation (how)
6. **When reviewing/conforming existing docs** - Reorganize non-conforming documentation to match these standards

**Do NOT invoke for:**
- Exploratory/debugging work that doesn't lead to changes
- Temporary experiments or proof-of-concepts
- Work in progress that hasn't been finalized
- Simple clarification questions
- **Internal code organization changes** - Refactoring that doesn't change external behavior or user-facing functionality (e.g., moving dependencies between aliases in deps.edn, renaming internal variables, restructuring private functions)

**Key principle:** If code changed successfully and will be kept, docs should be updated to match **user-observable behavior**. Internal implementation details that don't affect how users interact with or understand the system don't require documentation updates.

**IMPORTANT:** Always invoke this skill before committing changes to version control to ensure documentation stays synchronized with code changes.

## Documentation Structure

Project documentation follows this hierarchy (create only what's needed):

```
project-root/
├── README.md                           # Project intro, badges, quick links (minimal)
├── docs/
│   ├── index.md                        # Main documentation hub
│   ├── functional/                     # Functional requirement specifications
│   │   ├── index.md                    # Requirements overview (links to specs)
│   │   ├── feature-1.md
│   │   └── ...
│   └── technical/                      # Technical documentation
│       ├── index.md                    # Technical docs overview
│       ├── architecture.md             # System design (optional)
│       ├── development.md              # Dev setup, build, test (optional)
│       ├── operational.md              # Deploy, monitor, manage (optional)
│       └── ...component docs...
```

### Flexible File vs Directory Structure

Only create documentation that exists. Don't create empty files or directories.

For any topic, start with a single file when content is simple:
- `docs/technical/architecture.md`
- `docs/technical/development.md`

Expand to a directory with index.md when content grows complex:
- `docs/technical/architecture/index.md` + subtopic files
- `docs/technical/development/index.md` linking to:
  - `environment.md` - dev environment, tooling, build/run/test
  - `guides.md` - coding patterns and conventions
- `docs/technical/operational/index.md` - deployment, monitoring, management

## Core Principles

1. **No Duplication - Single Source of Truth**
   - Each piece of information should exist in EXACTLY ONE appropriate place
   - Higher-level docs provide summaries and links, NOT duplicate content
   - Detailed information belongs in the most specific applicable document
   - **NEVER copy-paste content between documents** - use links and references instead
   - **NEVER duplicate information from source files** - especially version numbers, configuration values, or data that lives in code (e.g., don't copy dependency versions from deps.edn into docs)
   - If the same information appears in multiple places, consolidate it into one document and link to it
   - When information exists in source code, documentation should reference or describe it, not duplicate it
   - **Source code documentation is the authoritative source** for function/module documentation - technical docs should link to generated API docs rather than duplicate inline code documentation

2. **Appropriate Placement**
   - **Functional specs** (`docs/functional/*`) describe WHAT features do and WHY they exist
   - **Technical docs** (`docs/technical/*`) describe HOW things are implemented
   - **Index docs** (`index.md` files) summarize and link, don't duplicate
   - **README.md** provides minimal project intro, links to `docs/index.md`
   - When adding content, ask: "What is the MOST SPECIFIC appropriate place for this?"

3. **Separation of Concerns**
   - **Functional specs** MUST NOT contain implementation details
   - **Technical docs** MAY reference features from functional specs
   - Implementation details belong ONLY in technical docs
   - Feature descriptions belong ONLY in functional specs
   - Index documents provide structure and navigation, not primary content

4. **Hierarchical Linking**
   - `README.md` links to `docs/index.md`
   - `docs/index.md` links to `docs/functional/index.md` and `docs/technical/index.md`
   - `docs/functional/index.md` links to specific functional specs
   - `docs/technical/index.md` links to architecture, development, operational docs
   - Cross-references between functional and technical docs are encouraged
   - Links replace duplication - always prefer linking over copying

5. **Bidirectional Consistency**
   - When any document changes, update all documents that reference or are referenced by it
   - Ensure links remain valid and descriptions stay accurate
   - Propagate changes up and down the documentation hierarchy
   - Update summaries in parent docs, but don't duplicate detailed content

6. **Source Code is Primary Documentation**
   - Well-named functions, parameters, and data structures are the first layer of documentation
   - Comments explain intent, not what the code does
   - External documentation describes *what* the system does and *why*, not *how* individual functions work
   - For code-level documentation conventions, consult language-specific editing skills where available

7. **Procedural Instructions Hierarchy**
   - When documenting procedures, prefer the most deterministic form available
   - Executable scripts/commands > checklists/decision trees > prose descriptions
   - See the **skill-creator** skill's Documentation Principles for the canonical definition

## Anti-Duplication Workflow

**Before adding ANY documentation content, follow this critical checklist:**

1. **Check if it already exists elsewhere**
   - Search for similar content across all documentation files
   - If found, determine if you should update that location or link to it
   - Don't create new content if equivalent information exists

2. **Determine the single best location**
   - Ask: "Where will users most naturally look for this information?"
   - Ask: "What is the most specific document type that fits this content?"
   - Feature requirements (what/why) → `docs/functional/*.md`
   - Implementation details (how code works) → `docs/technical/*.md`
   - Development instructions (build, run, test) → `docs/technical/development.md`
   - Deployment/operations → `docs/technical/operational.md`
   - High-level summaries → appropriate `index.md` file
   - Project introduction → `README.md` (minimal) or `docs/index.md`

3. **Use links instead of duplication**
   - If multiple documents need to reference the same concept, write it ONCE in the most appropriate place
   - Other documents should link to that single source of truth
   - Brief one-sentence summaries with links are acceptable; multi-paragraph duplicates are not

4. **Consolidate when you find duplication**
   - If you discover the same information in multiple places while editing:
     - Identify which location is most appropriate
     - Keep the content there and make it comprehensive
     - Replace duplicate content in other locations with links
     - Add a brief summary sentence if needed for context

**Example of proper linking vs. duplication:**

❌ **BAD - Duplication:**
```markdown
# docs/functional/index.md
## Image Viewer
The image viewer allows users to view images with zoom and pan controls.
It supports keyboard navigation with arrow keys...
[3 more paragraphs of details]

# docs/functional/image-viewer.md
## Image Viewer
The image viewer allows users to view images with zoom and pan controls.
It supports keyboard navigation with arrow keys...
[Same 3 paragraphs repeated]
```

✅ **GOOD - Single source with linking:**
```markdown
# docs/functional/index.md
## Image Viewer
Interactive image viewing with zoom, pan, and navigation controls.
See [image-viewer.md](image-viewer.md) for detailed requirements.

# docs/functional/image-viewer.md
## Image Viewer
The image viewer allows users to view images with zoom and pan controls.
It supports keyboard navigation with arrow keys...
[All details live here, in one place]
```

## Workflows

### When Updating Existing Documentation

1. **Identify the document type** being modified:
   - Project intro (README.md)
   - Documentation hub (docs/index.md)
   - Functional requirements index (docs/functional/index.md)
   - Technical docs index (docs/technical/index.md)
   - Specific functional spec (docs/functional/*.md)
   - Specific technical doc (docs/technical/*.md)

2. **Determine impact scope**:
   - Search for documents that link TO this document (parent references)
   - Search for documents that this document links FROM (child references)
   - Identify related documents that share concepts or features

3. **Update all affected documents**:
   - Update parent documents if high-level descriptions need changes
   - Update child documents if details need refinement
   - Update cross-references if feature names or sections change
   - Ensure functional specs remain implementation-agnostic
   - Ensure technical docs accurately reference functional specs

4. **Verify consistency**:
   - Check all links are valid and point to correct sections
   - Ensure descriptions match across documentation levels
   - Confirm no implementation details leaked into functional specs
   - Validate that technical docs properly reference features

### When Creating New Documentation

1. **Determine document placement**:
   - Functional spec → `docs/functional/feature-name.md`
   - Technical doc → `docs/technical/component-name.md`

2. **Create the document**:
   - Use clear, descriptive filename (kebab-case)
   - Include appropriate frontmatter or header
   - Follow the separation of concerns principle
   - Add necessary content sections

3. **Update parent documents**:
   - Add link in `docs/functional/index.md` for new functional specs
   - Add link in `docs/technical/index.md` for new technical docs
   - Update `docs/index.md` if this represents a major new area
   - Include brief description alongside the link

4. **Create cross-references**:
   - Technical docs should link to relevant functional specs
   - Update related documents to reference the new doc
   - Ensure bidirectional navigation is possible

### When Reviewing Existing Documentation

Use this workflow to bring existing documentation into conformance with these standards. Review BOTH structure/organization AND content quality.

1. **Audit current state**:
   - List all documentation files (README, docs/, inline comments, wikis)
   - **Structure**: Identify non-conforming structure (wrong locations, missing index files)
   - **Content**: Check each doc for clarity, brevity, and appropriate placement
   - Find duplicated content across files
   - Note content that's in the wrong category (implementation in functional specs, etc.)
   - Identify content that should be consolidated or migrated to other docs
   - Identify files that function as section overviews regardless of name; move to appropriate `index.md` locations

2. **Plan reorganization**:
   - Map existing files to target locations:
     - Feature/requirement docs → `docs/functional/`
     - Architecture/implementation docs → `docs/technical/`
     - Dev setup/build/test → `docs/technical/development.md`
     - Deployment/ops → `docs/technical/operational.md`
   - Identify content to consolidate (remove duplicates)
   - Identify content to split (mixed concerns)

3. **Execute reorganization**:
   - Create target directory structure
   - Move/rename files to correct locations
   - Create index.md files for each directory
   - Update all cross-references

4. **Clean up content**:
   - Remove duplicated content, replace with links
   - Move implementation details out of functional specs
   - Move feature descriptions out of technical docs
   - Condense verbose content (apply concise writing style)
   - Slim down README.md to minimal intro + link to docs/index.md

5. **Verify conformance**:
   - All links valid
   - No orphaned files (everything linked from an index)
   - No duplicate content
   - Proper separation of concerns
   - Consistent terminology

### When Documents Don't Exist

If the project lacks the standard documentation structure:

1. **Assess what exists**:
   - Check for README.md
   - Look for any existing docs/ directory
   - Identify any informal documentation

2. **Create missing structure** (only what's needed):
   - Create `docs/` directory if needed
   - Create `docs/functional/` for functional specs (if needed)
   - Create `docs/technical/` for technical documentation (if needed)

3. **Generate core documents** in this order:
   - `README.md` (if missing - keep minimal)
   - `docs/index.md` (main documentation hub)
   - `docs/functional/index.md` (if functional specs exist)
   - `docs/technical/index.md` (if technical docs exist)

4. **Populate with initial content**:
   - Extract information from existing code, comments, or informal docs
   - Create placeholder sections for future detailed specs
   - Link structure together following hierarchical principles

5. **Incrementally add detailed docs**:
   - Create `docs/functional/*.md` files for major features
   - Create `docs/technical/*.md` files for architecture, development, etc.
   - Update index files with links as detailed docs are added

## Content Guidelines

### Link Formatting

When linking to other docs, make the title/name the link itself:
`**[Feature Name](file.md)** - description`

### Writing Style: Concise But Clear

**Core principle**: Every sentence must earn its place. Remove filler, eliminate redundancy, prioritize clarity over comprehensiveness.

**Good practices**:
- Use bullet points over paragraphs when listing information
- Start with the essential point, add details only if necessary
- Prefer short sentences (10-15 words) over complex ones
- Cut introductory phrases ("It should be noted that", "Basically", etc.)
- Use active voice and direct language
- Avoid marketing language or unnecessary superlatives
- Skip obvious statements that readers already know

**Examples**:

❌ **Verbose**: "The system provides the capability for developers to easily organize and structure their web application routes in a very intuitive way by using the filesystem structure which directly mirrors and corresponds to the URI structure of their website."

✅ **Concise**: "Routes mirror filesystem structure: `/foo` → `foo.clj`"

❌ **Verbose**: "It is important to note that all of the path parameters that are extracted from the URI will be made available to your handler functions through the use of the `:endpoint/path-params` key within the Ring request map."

✅ **Concise**: "Path parameters available in request map at `:endpoint/path-params`"

### README.md
- **1-2 sentences**: What the project does
- **Link**: Point to `docs/index.md` for full documentation

### docs/index.md
- **Overview**: What the project does and why
- **Quick start**: Getting started instructions
- **Links**: Navigate to functional and technical docs

### docs/functional/index.md
- **Vision**: 1-2 sentences on project purpose
- **Features**: List with one-line descriptions + links to specs

### docs/functional/*.md (Functional Specs)
- **Overview**: 1-2 sentences on feature purpose
- **User value**: What problem it solves (brief)
- **Requirements**: List of capabilities with descriptive names (NO numeric IDs like `FR-001` or `R1`)
  - Format: `**Descriptive Name** - explanation`
  - The filename serves as the feature identifier (e.g., `route-caching.md`)
  - Requirement names serve as requirement identifiers (e.g., "Cache Key", "Thread Safety")
- **Acceptance criteria**: Bullets, not full sentences where possible
- **NO implementation details**

### docs/technical/index.md
- **Development Environment** (first) - Tooling, build, test - what developers need to get started
- **Stack**: Bullet list of technologies
- **Design/Architecture**: Principles, request flow, key algorithms
- **Modules**: One-line descriptions + links to detailed docs
- **Deployment** (last) - What you do after development is complete

### docs/technical/*.md (Technical Docs)
- **Purpose**: One sentence on what this module/topic covers
- **Key functions**: List with one-line descriptions (for code docs)
- **Algorithms**: Describe logic clearly but tersely
- **Code references**: Include file:line references for navigation

### docs/technical/development.md (or development/index.md)
- **Prerequisites**: Required tools with version requirements
- **Quick start**: Minimal commands to get started
- **Commands**: Reference to task runner - don't duplicate task definitions
- **Workflows**: Common development patterns (REPL, testing, debugging)
- **Troubleshooting**: Common issues with brief solutions

## Validation Checklist

After making documentation changes, verify:

- [ ] **No duplication** - each piece of info in exactly one place
- [ ] **Concise and clear** - no filler, short sentences, bullet points over paragraphs
- [ ] **Appropriate location** - follows placement guidelines
- [ ] Links valid and point to existing files/sections
- [ ] Parent docs link to child docs (don't duplicate content)
- [ ] Functional specs have no implementation details
- [ ] Terminology consistent across docs
- [ ] **Index docs summarize and link** - don't duplicate child doc content

## Review Checklist

When reviewing or auditing existing documentation, explicitly check each item:

### Directory Structure (Required)
- [ ] **Use exact directory names** - `docs/functional/` and `docs/technical/` are requirements, not suggestions
- [ ] **Rename non-conforming directories** - Flag and fix during audit

### Hierarchy Violations
- [ ] **README.md vs docs/index.md** - Compare content; README should be minimal (description + link only), no duplicated quick start or examples
- [ ] **docs/index.md links** - Should only link to top-level sections (functional/index.md, technical/index.md), not to their children
- [ ] **Development content** - Must live in docs/technical/development.md, not in docs/index.md or README
- [ ] **API docs link** - Belongs in docs/technical/index.md, not docs/index.md

### Content Placement
- [ ] **Quick start** - Lives in ONE place only (docs/index.md), not also in README
- [ ] **Build commands** - Live in docs/technical/development.md only
- [ ] **Feature details** - Live in docs/functional/*.md, not in index files
- [ ] **Implementation details** - Live in docs/technical/*.md, not in functional specs

### Index File Rules
- [ ] **docs/index.md** - Contains: overview, quick start, links to functional/ and technical/ indexes only
- [ ] **docs/functional/index.md** - Contains: vision, feature list with one-line descriptions + links to specs
- [ ] **docs/technical/index.md** - Contains: stack, module list, links to development.md, API docs, and component docs

### Cross-Document Duplication
- [ ] **No repeated code examples** - Same example should not appear in multiple files
- [ ] **No repeated explanations** - Concepts explained once, linked elsewhere
- [ ] **Version/config values** - Never duplicated from source files into docs

## Examples

### Example: Adding a new authentication feature

1. **Create functional spec**: `docs/functional/authentication.md`
   - Describe what authentication is needed and why
   - Define user stories and acceptance criteria
   - NO mention of JWT, OAuth, or specific libraries

2. **Update docs/functional/index.md**:
   - Add: "## Authentication - See [authentication.md](authentication.md) for details"
   - Briefly describe the feature at high level

3. **Create technical doc**: `docs/technical/auth-implementation.md`
   - Describe JWT token implementation
   - Reference: "Implements authentication requirements defined in [authentication.md](../functional/authentication.md)"
   - Detail technical decisions and code structure

4. **Update docs/technical/index.md**:
   - Add: "## Authentication - See [auth-implementation.md](auth-implementation.md)"
   - Describe how auth fits into overall architecture

### Example: Updating an existing feature spec

If updating `docs/functional/user-profiles.md`:

1. **Make changes** to the functional spec
2. **Check docs/functional/index.md** - update description if high-level summary changed
3. **Check docs/technical/** - find technical docs that reference user-profiles.md
4. **Update technical docs** if the requirements change affects implementation
5. **Verify docs/index.md** still accurately describes the project scope

### Example: Refactoring technical documentation

If restructuring `docs/technical/database-schema.md`:

1. **Update the technical doc** with new structure
2. **Check docs/technical/index.md** - ensure link and description are accurate
3. **Check docs/functional/** - verify functional specs are still accurately referenced
4. **Update cross-references** in other technical docs that link to database-schema.md

### Example: Adding development instructions

When documenting how to run tests:

1. **Add to docs/technical/development.md**:
   - Command to run tests (e.g., `bb test`)
   - How to run specific test files
   - Interpreting test output
   - Common test failures and solutions

2. **Update docs/technical/index.md**:
   - Add link to development.md if not already present

3. **Do NOT duplicate**:
   - Don't copy command definitions from `bb.edn` or task files
   - Don't repeat testing philosophy from technical docs
   - Reference source of truth, don't duplicate it
