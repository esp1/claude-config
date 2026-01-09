---
name: clojure-testing
description: This skill should be used when creating or modifying Clojure test files in the FSR project. It provides testing patterns, Malli schema integration, property-based testing workflows, and integration test best practices specific to this codebase.
---

# Clojure Testing for FSR

## Overview

This skill codifies the testing patterns used in the FSR (filesystem router) project, including Malli schema-driven testing, property-based tests, and integration test workflows.

## When to Use This Skill

Use this skill when:
- Creating new test files (`.clj` files in `test/` directory)
- Adding tests to existing test namespaces
- Setting up integration tests with temp directories
- Writing property-based tests using Malli generators
- Implementing test fixtures with Malli registry setup

## Important Workflow Reminders

- **After making successful code changes** (including tests), invoke `/doc-sync` to keep documentation synchronized
- **Before committing**, ensure `/doc-sync` has been run to update all affected documentation

## Test Types in FSR

FSR uses three complementary testing approaches:

### 1. Unit Tests (Minimal)
Simple function behavior tests with known inputs/outputs. Used sparingly—only when property-based tests would be overly complex.

```clojure
(deftest test-classify-route
  (testing "Static route classification"
    (let [route {:uri "/api/users"}
          result (classify-route route)]
      (is (= :static (:route-type result))))))
```

### 2. Property-Based Tests (Primary)
Schema-driven generative tests that validate function properties across 100+ generated inputs. This is the **preferred** testing approach in FSR.

```clojure
(deftest clojure-file-ext-test
  (testing "clojure-file-ext function"
    (let [args-schema (-> #'clojure-file-ext meta :malli/schema second)
          args-gen (mg/generator args-schema)]
      (dotimes [_ 100]
        (let [[filename] (gen/generate args-gen)
              result (clojure-file-ext filename)]
          (is (or (nil? result)
                  (re-matches #"\.cljc?$" result))))))))
```

### 3. Integration Tests
End-to-end flows testing compilation, file I/O, and runtime behavior with proper cleanup.

```clojure
(deftest test-full-compilation-flow
  (testing "Compile routes from test directory"
    (let [compiled (compile-dynamic-routes test-routes-dir)]
      (is (map? compiled))
      (is (contains? compiled :static-routes)))))
```

## Malli Registry Setup Pattern

**CRITICAL:** All test namespaces that use Malli schemas MUST include this fixture pattern:

```clojure
(ns esp1.fsr.your-test
  (:require
   [clojure.test :refer [deftest is testing use-fixtures]]
   [esp1.fsr.schema :as fsr-schema]
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
      (fsr-schema/file-schemas)
      (fsr-schema/cache-schemas)
      (fsr-schema/route-schemas)))
    (mdev/start!)
    (f)
    (mdev/stop!)
    (mr/set-default-registry! m/default-registry)))
```

**Important:** Include ONLY the schema registries needed for the test namespace. If testing cache functionality, include `cache-schemas`. If testing file operations, include `file-schemas`. This keeps the registry lean.

## Property-Based Testing Workflow

### Step 1: Extract Schema from Function Metadata

```clojure
(let [args-schema (-> #'function-name meta :malli/schema second)
      args-gen (mg/generator args-schema)]
  ...)
```

### Step 2: Generate 100 Test Cases

```clojure
(dotimes [_ 100]
  (let [[arg1 arg2] (gen/generate args-gen)
        result (function-name arg1 arg2)]
    ...))
```

### Step 3: Test Properties, Not Values

Focus on invariants and properties:
- Type properties: "Result is always a string or nil"
- Structural properties: "Result never contains dots"
- Relationship properties: "Pattern captures match param count"

```clojure
;; Good: Tests properties
(is (or (nil? result) (string? result)))

;; Avoid: Tests specific values (use unit tests for this)
(is (= "expected-string" result))
```

### Custom Generators for Domain Objects

When function schemas aren't sufficient, create custom generators:

```clojure
(let [filename-gen (gen/one-of
                    [gen/string-alphanumeric
                     (gen/fmap #(str "prefix_<param>_" %)
                               gen/string-alphanumeric)
                     (gen/fmap #(str "<<multi-param>>_" %)
                               gen/string-alphanumeric)])]
  (dotimes [_ 100]
    (let [filename (gen/generate filename-gen)]
      ...)))
```

## Integration Test Patterns

### Temp Directory Management

Always use fixtures for setup/cleanup:

```clojure
(def temp-output-dir (str "/tmp/fsr-test-" (System/currentTimeMillis)))

(defn cleanup-fixture [f]
  "Clean up temp directory after tests"
  (try
    (f)
    (finally
      (when (.exists (io/file temp-output-dir))
        (doseq [file (reverse (file-seq (io/file temp-output-dir)))]
          (.delete file))))))

(use-fixtures :once cleanup-fixture)
```

### Compile-Write-Load-Test Flow

Standard pattern for testing production compilation:

```clojure
(testing "Write and load compiled routes"
  (let [compiled (compile-dynamic-routes test-routes-dir)
        output-file (str temp-output-dir "/compiled-routes.edn")]

    ;; Write
    (write-compiled-routes compiled output-file)

    ;; Verify file created
    (is (.exists (io/file output-file)))

    ;; Load and verify
    (let [loaded (load-compiled-routes output-file)]
      (is (= compiled loaded)))))
```

### Cache Testing Pattern

For cache tests, always clear cache before each test:

```clojure
(deftest cache-hit-scenario-test
  (testing "first resolution (miss) then second resolution (hit)"
    ;; Clear cache to start fresh
    (cache/clear!)

    ;; Test logic...
    ))
```

## Test Organization and Documentation

### Namespace Docstrings

Include clear namespace-level documentation:

```clojure
(ns esp1.fsr.integration-test
  "End-to-end integration test for production route compilation.

   Tests the complete flow:
   1. Compile routes from filesystem
   2. Write to EDN file
   3. Load compiled routes
   4. Match and invoke handlers via middleware"
  (:require ...))
```

### Test ID Comments for Traceability

Use comment-based test IDs to map tests to requirements:

```clojure
;; T006: Integration test for cache hit scenario
(deftest cache-hit-scenario-test
  ...)

;; T007: Integration test for cache clearing
(deftest cache-clearing-test
  ...)
```

### Testing Blocks

Use nested `testing` blocks for clarity:

```clojure
(deftest lru-eviction-test
  (testing "LRU eviction when cache exceeds max-entries"
    ;; Test logic...
    )

  (testing "LRU eviction updates access time"
    ;; Test logic...
    ))
```

## Running Tests

```bash
# Run all tests
bb test

# Run specific test namespace
clojure -M:dev -m clojure.test.runner esp1.fsr.core-test

# Run with Malli instrumentation (dev mode)
clojure -M:dev
```

## Checklist for New Tests

Before committing test code:

- [ ] Use `testing` blocks with descriptive strings
- [ ] Include test IDs in comments if mapping to requirements (T001, T002...)
- [ ] Set up Malli registry fixture if using schemas
- [ ] Prefer property-based tests over unit tests
- [ ] Generate 100 samples for property-based tests
- [ ] Test properties/invariants, not specific values
- [ ] Clean up temp files/directories in integration tests
- [ ] Include namespace docstring explaining test purpose
- [ ] Clear cache before cache-related tests
- [ ] Run `bb test` to verify all tests pass

## Common Patterns Reference

### Testing Ring Handlers

```clojure
(let [app (wrap-compiled-routes fallback {:compiled-routes compiled})]
  (let [response (app {:uri "api/users" :request-method :post})]
    (is (= 201 (:status response)))
    (is (= "{\"id\":\"123\"}" (:body response)))))
```

### Testing Path Parameter Extraction

```clojure
(is (= [(io/file "test/bar/abc_<param1>_def_<<param2>>_xyz.clj")
        {"param1" "word", "param2" "m/n/o/p"}]
       (uri->file+params "abc-word-def-m/n/o/p-xyz" (io/file "test/bar"))))
```

### Testing Metrics

```clojure
(let [metrics (cache/get-metrics)]
  (is (> (:hits metrics) 0) "Should have at least one cache hit")
  (is (= 0 (:current-size metrics)) "Current size should be 0 after clear"))
```

### Testing Pattern Matching with Regex

```clojure
(let [invalidated-count (cache/invalidate! #"/api/.*")]
  (is (= 3 invalidated-count) "Should invalidate 3 API routes"))
```
