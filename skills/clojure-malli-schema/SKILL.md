---
name: clojure-malli-schema
description: Provides comprehensive guidance for adding Malli schemas to Clojure projects. Use this skill when creating or modifying Clojure functions to ensure proper schema coverage with best practices. Ensures schemas are self-documenting, enable validation and generative testing, while remaining dev-only dependencies.
---

# Malli Schema

## Overview

Comprehensive guidance for adding Malli schemas to Clojure projects. This skill ensures:
- All public functions have schemas
- Schemas are self-documenting using `:catn`
- Data structures are properly validated
- Malli remains a dev-only dependency (schemas as metadata)

## When to Use This Skill

Invoke this skill when:
- Creating new Clojure functions (add schemas immediately)
- Modifying existing functions (update schemas)
- Defining new data structures
- Setting up Malli in a new project
- Reviewing code for missing schemas
- Creating test registries

## Why Schemas Matter

- **Validation**: Catch errors early with runtime validation (in dev/test)
- **Documentation**: Schemas serve as executable, always-up-to-date documentation — they reduce the need for type descriptions in docstrings (see **clojure-edit** skill's documentation practices)
- **Generative Testing**: Enable property-based testing with generated test data
- **Zero Runtime Cost**: Schemas are metadata - no production dependency on Malli
- **Better Error Messages**: Clear validation errors show exactly what's wrong

## Schema Organization

### Function Schemas
- Add as `:malli/schema` metadata on the function itself
- Keeps Malli as dev-only dependency (no runtime impact)
- Metadata travels with the function definition

### Data Structure Schemas
- Define in separate schema namespace (e.g., `my-app.schema`)
- Group related schemas in registry functions
- Register in test fixtures for validation

### Schema Location Pattern
```
src/
  my_app/
    core.clj           # Functions with :malli/schema metadata
    schema.clj         # Data structure schemas + registries
test/
  my_app/
    core_test.clj      # Registers schemas in fixtures
```

## Adding Function Schemas

### Critical Rule: Always Use `:catn`

**ALWAYS use `:catn` (not `:cat`) for function parameters** to provide descriptive names. This makes schemas self-documenting.

### Template

```clojure
(defn my-function
  "Function docstring explaining what it does"
  {:malli/schema [:=> [:catn
                       [:param-name :param-type]
                       [:other-param :other-type]]
                  :return-type]}
  [param-name other-param]
  ;; implementation
  )
```

### Why `:catn` vs `:cat`

❌ **Bad - Using `:cat`:**
```clojure
{:malli/schema [:=> [:cat :string :string] :string]}
```
- Unclear which parameter is which
- No self-documentation
- Harder to debug validation errors

✅ **Good - Using `:catn`:**
```clojure
{:malli/schema [:=> [:catn
                     [:uri :string]
                     [:root-path :string]]
                :string]}
```
- Immediately clear what each parameter represents
- Self-documenting
- Better error messages
- Easier to understand at a glance

### Examples

**Simple function:**
```clojure
(defn add
  "Adds two numbers"
  {:malli/schema [:=> [:catn
                       [:x :int]
                       [:y :int]]
                  :int]}
  [x y]
  (+ x y))
```

**Function with optional parameters:**
```clojure
(defn fetch-user
  "Fetches user with optional timeout"
  {:malli/schema [:=> [:catn
                       [:user-id :string]
                       [:options [:map
                                  [:timeout {:optional true} :int]]]]
                  [:maybe :map]]}
  [user-id options]
  ;; implementation
  )
```

**Function returning maybe/optional:**
```clojure
(defn find-by-id
  "Finds entity by ID, returns nil if not found"
  {:malli/schema [:=> [:catn [:id :int]]
                  [:maybe :map]]}
  [id]
  ;; implementation
  )
```

**Higher-order function (returns function):**
```clojure
(defn make-adder
  "Creates a function that adds n to its input"
  {:malli/schema [:=> [:catn [:n :int]]
                  [:fn #(fn? %)]]}
  [n]
  (fn [x] (+ x n)))
```

**Multi-arity function:**
```clojure
(defn greet
  "Greets a person, optionally with title"
  {:malli/schema [:function
                  [:=> [:catn [:name :string]] :string]
                  [:=> [:catn [:title :string] [:name :string]] :string]]}
  ([name]
   (str "Hello, " name))
  ([title name]
   (str "Hello, " title " " name)))
```

**Single-argument function (still use `:catn` for consistency):**
```clojure
(defn square
  "Squares a number"
  {:malli/schema [:=> [:catn [:n :int]]
                  :int]}
  [n]
  (* n n))
```

## Adding Data Structure Schemas

### 1. Define the Schema

In your schema namespace (e.g., `my_app/schema.clj`):

```clojure
(ns my-app.schema
  (:require [malli.core :as m]))

(def user?
  "Schema for user data structure"
  [:map
   [:id :int]
   [:name :string]
   [:email [:string {:min 5}]]
   [:age {:optional true} :int]
   [:roles [:set :keyword]]])

(def http-request?
  "Schema for HTTP request"
  [:map
   [:method [:enum :get :post :put :delete]]
   [:uri :string]
   [:headers {:optional true} [:map-of :string :string]]
   [:body {:optional true} :any]])
```

### 2. Create Registry Function

Group related schemas:

```clojure
(defn user-schemas []
  {:user user?
   :http-request http-request?})

(defn validation-schemas []
  {:email-regex #"^[^@]+@[^@]+\.[^@]+$"
   :phone-regex #"^\d{3}-\d{3}-\d{4}$"})
```

### 3. Register in Tests

In your test file, register schemas in fixtures:

```clojure
(ns my-app.core-test
  (:require [clojure.test :refer [deftest is testing use-fixtures]]
            [my-app.schema :as app-schema]
            [malli.core :as m]
            [malli.dev :as mdev]
            [malli.registry :as mr]))

(use-fixtures :once
  (fn [f]
    (mr/set-default-registry!
     (merge
      (m/comparator-schemas)
      (m/type-schemas)
      (m/sequence-schemas)
      (m/base-schemas)
      (app-schema/user-schemas)
      (app-schema/validation-schemas)))
    (mdev/start!)  ;; Enable dev-mode instrumentation
    (f)
    (mdev/stop!)
    (mr/set-default-registry! m/default-registry)))
```

## Common Schema Patterns

### Map with Specific Keys

```clojure
[:map
 [:required-key :string]
 [:optional-key {:optional true} :int]
 [:namespaced-key {:optional true} :keyword]
 [:with-constraints [:int {:min 0 :max 100}]]]
```

### Union Types (One of Several)

```clojure
[:or :string :int :keyword]
```

### Maybe/Optional

```clojure
[:maybe :string]  ;; Can be string or nil
```

### Collections

```clojure
[:vector :int]                    ;; Vector of integers
[:set :keyword]                   ;; Set of keywords
[:sequential :string]             ;; Any sequential of strings
[:map-of :string :int]            ;; Map with string keys, int values
```

### Custom Validation

```clojure
[:string {:min 3 :max 50}]        ;; String length constraints
[:int {:min 0 :max 100}]          ;; Number range
[:fn #(< 0 % 100)]                ;; Custom predicate
[:re #"^[A-Z][a-z]+$"]            ;; Regex validation
```

### Nested Structures

```clojure
[:map
 [:user [:map
         [:id :int]
         [:name :string]]]
 [:metadata [:map
             [:created-at :int]
             [:updated-at :int]]]]
```

## Schema Checklist for New Code

When adding or modifying code, ensure:

- [ ] All public functions have `:malli/schema` metadata
- [ ] Function schemas use `:catn` (not `:cat`) with descriptive parameter names
- [ ] All data structures passed between functions are defined in schema namespace
- [ ] New schemas are added to appropriate registry function
- [ ] Test registries are updated to include new schema groups
- [ ] Tests pass (validates schemas work correctly)
- [ ] Schemas use custom types from registry (not just primitives) when applicable

## Verification Workflow

Before committing code:

1. **Run tests** - Ensures all schemas compile and validate
   ```bash
   # Project-specific test command (e.g., lein test, clj -X:test, bb test)
   ```

2. **Check Malli dev-mode output** - Look for:
   - "instrumented N function vars" message
   - No schema-related errors or warnings
   - All expected functions instrumented

3. **Verify schema errors are helpful** - If validation fails:
   - Error message should clearly indicate which parameter failed
   - Should show expected vs actual types
   - `:catn` names should appear in error messages

## Complete Example Workflow

### Step 1: Define Data Structure Schema

In `src/my_app/schema.clj`:

```clojure
(ns my-app.schema)

(def request-context?
  "Schema for request context"
  [:map
   [:uri :string]
   [:method [:enum :get :post :put :delete]]
   [:params {:optional true} [:map-of :string :string]]])

(defn request-schemas []
  {:request-context request-context?})
```

### Step 2: Add Function with Schema

In `src/my_app/core.clj`:

```clojure
(ns my-app.core)

(defn process-request
  "Processes incoming HTTP request context"
  {:malli/schema [:=> [:catn [:ctx :request-context]]
                  :map]}
  [ctx]
  {:status 200
   :body (str "Processed " (:uri ctx))})
```

### Step 3: Register in Tests

In `test/my_app/core_test.clj`:

```clojure
(ns my-app.core-test
  (:require [clojure.test :refer [deftest is use-fixtures]]
            [my-app.schema :as app-schema]
            [malli.core :as m]
            [malli.dev :as mdev]
            [malli.registry :as mr]))

(use-fixtures :once
  (fn [f]
    (mr/set-default-registry!
     (merge
      (m/comparator-schemas)
      (m/type-schemas)
      (m/sequence-schemas)
      (m/base-schemas)
      (app-schema/request-schemas)))
    (mdev/start!)
    (f)
    (mdev/stop!)
    (mr/set-default-registry! m/default-registry)))

(deftest process-request-test
  (is (= 200 (:status (process-request {:uri "/test" :method :get})))))
```

### Step 4: Run Tests

```bash
# Schemas are validated automatically when dev-mode is active
# You'll see: "malli: instrumented N function vars"
```

## Project Setup

### Initial Malli Setup

If starting a new project, add Malli as a dev dependency:

**deps.edn:**
```clojure
{:deps {}
 :aliases
 {:dev {:extra-deps {metosin/malli {:mvn/version "0.16.0"}}}
  :test {:extra-deps {metosin/malli {:mvn/version "0.16.0"}}}}}
```

**project.clj (Leiningen):**
```clojure
(defproject my-app "0.1.0"
  :dependencies []
  :profiles {:dev {:dependencies [[metosin/malli "0.16.0"]]}})
```

### Create Schema Namespace

```bash
# Create schema namespace
mkdir -p src/my_app
touch src/my_app/schema.clj
```

```clojure
(ns my-app.schema
  "Malli schemas for data validation"
  (:require [malli.core :as m]))

;; Define your schemas here

(defn all-schemas []
  "Registry of all application schemas"
  {})
```

## Best Practices

1. **Add schemas as you write code** - Don't retrofit later
2. **Use `:catn` always** - Even for single-arg functions
3. **Keep schemas close to data** - Define in schema namespace, use in code
4. **Descriptive parameter names** - `[:uri :string]` not `[:s :string]`
5. **Custom types over primitives** - Create `:user-id` type instead of using `:int` everywhere
6. **Test schema validation** - Write tests that intentionally violate schemas
7. **Update schemas with code changes** - Keep them in sync
8. **Use dev-mode in tests** - Catches schema violations early

## Common Pitfalls to Avoid

❌ **Using `:cat` instead of `:catn`**
```clojure
{:malli/schema [:=> [:cat :string :int] :string]}  ;; Bad!
```

❌ **Forgetting to register custom schemas**
```clojure
;; Defined :user-id in schema.clj but forgot to add to registry
{:malli/schema [:=> [:catn [:id :user-id]] :map]}  ;; Will fail!
```

❌ **Missing metadata key**
```clojure
(defn foo [x]
  [:=> [:catn [:x :int]] :int]  ;; Wrong! Not in metadata
  (+ x 1))
```

❌ **Not using dev-mode in tests**
```clojure
;; Missing (mdev/start!) in test fixture
;; Schemas defined but never validated!
```

## Troubleshooting

### "Schema not found: :my-type"
- Check that the schema is defined in your schema namespace
- Verify the registry function includes the schema
- Ensure test fixtures register your schemas

### "Unable to resolve symbol: mdev"
- Add Malli to dev/test dependencies
- Require `[malli.dev :as mdev]` in test namespace

### Functions not being instrumented
- Verify `(mdev/start!)` is called in test fixture
- Check that registry is set before dev-mode starts
- Ensure function has `:malli/schema` metadata (not just a schema)

### Validation errors are unclear
- Switch from `:cat` to `:catn` for better error messages
- Add `:title` or `:description` to schemas for clarity
- Use specific custom types instead of generic primitives

## Quick Reference Card

```clojure
;; Function schema template
(defn my-fn
  "Docstring"
  {:malli/schema [:=> [:catn [:param :type]] :return-type]}
  [param]
  body)

;; Data structure
(def my-data? [:map [:key :type]])

;; Registry
(defn my-schemas [] {:my-data my-data?})

;; Test fixture
(use-fixtures :once
  (fn [f]
    (mr/set-default-registry! (merge ...schemas...))
    (mdev/start!)
    (f)
    (mdev/stop!)
    (mr/set-default-registry! m/default-registry)))
```

## Further Reading

- [Malli Documentation](https://github.com/metosin/malli)
- [Function Schemas Guide](https://github.com/metosin/malli#function-schemas)
- [Malli Dev Mode](https://github.com/metosin/malli#development-mode)
