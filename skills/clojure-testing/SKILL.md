---
name: clojure-testing
description: This skill should be used when creating or modifying Clojure test files. It provides testing patterns, Malli schema integration, property-based testing workflows, and integration test best practices.
---

# Clojure Testing

## Overview

This skill codifies testing patterns for Clojure projects, including Malli schema-driven testing, property-based tests, and integration test workflows.

## When to Use This Skill

Use this skill when:
- Creating new test files (`.clj` files in `test/` directory)
- Adding tests to existing test namespaces
- Setting up integration tests with temp directories
- Writing property-based tests using Malli generators
- Implementing test fixtures with Malli registry setup

## Test Types

Clojure projects typically use three complementary testing approaches:

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
Schema-driven generative tests that validate function properties across many generated inputs. This is the **preferred** testing approach.

```clojure
(deftest my-function-test
  (testing "my-function properties"
    (let [args-schema (-> #'my-function meta :malli/schema second)
          args-gen (mg/generator args-schema)]
      (dotimes [_ 100]
        (let [[arg1 arg2] (gen/generate args-gen)
              result (my-function arg1 arg2)]
          ;; Test properties, not specific values
          (is (or (nil? result) (string? result))))))))
```

### 3. Integration Tests
End-to-end flows testing compilation, file I/O, and runtime behavior with proper cleanup.

```clojure
(deftest test-full-flow
  (testing "Complete processing flow"
    (let [result (process-input test-input)]
      (is (map? result))
      (is (contains? result :expected-key)))))
```

## Malli Registry Setup Pattern

**CRITICAL:** All test namespaces that use Malli schemas MUST include this fixture pattern:

```clojure
(ns my-app.core-test
  (:require
   [clojure.test :refer [deftest is testing use-fixtures]]
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
      (app-schema/my-schemas)))  ;; Your project's schemas
    (mdev/start!)
    (f)
    (mdev/stop!)
    (mr/set-default-registry! m/default-registry)))
```

**Important:** Include ONLY the schema registries needed for the test namespace. This keeps the registry lean.

## Property-Based Testing Workflow

### Step 1: Extract Schema from Function Metadata

```clojure
(let [args-schema (-> #'function-name meta :malli/schema second)
      args-gen (mg/generator args-schema)]
  ...)
```

### Step 2: Generate Test Cases

```clojure
(dotimes [_ 100]
  (let [[arg1 arg2] (gen/generate args-gen)
        result (function-name arg1 arg2)]
    ...))
```

### Step 3: Test Properties, Not Values

Focus on invariants and properties:
- Type properties: "Result is always a string or nil"
- Structural properties: "Result never contains X"
- Relationship properties: "Output length <= input length"

```clojure
;; Good: Tests properties
(is (or (nil? result) (string? result)))

;; Avoid: Tests specific values (use unit tests for this)
(is (= "expected-string" result))
```

### Custom Generators for Domain Objects

When function schemas aren't sufficient, create custom generators:

```clojure
(let [custom-gen (gen/one-of
                   [gen/string-alphanumeric
                    (gen/fmap #(str "prefix_" %) gen/string-alphanumeric)])]
  (dotimes [_ 100]
    (let [input (gen/generate custom-gen)]
      ...)))
```

## Integration Test Patterns

### Temp Directory Management

Always use fixtures for setup/cleanup:

```clojure
(def temp-output-dir (str "/tmp/test-" (System/currentTimeMillis)))

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

### Setup-Process-Verify Flow

Standard pattern for testing processing pipelines:

```clojure
(testing "Process and verify output"
  (let [input {:data "test"}
        output-file (str temp-output-dir "/output.edn")]

    ;; Process
    (process-and-write input output-file)

    ;; Verify file created
    (is (.exists (io/file output-file)))

    ;; Load and verify
    (let [loaded (read-output output-file)]
      (is (= (:data input) (:data loaded))))))
```

### State/Cache Testing Pattern

For tests involving mutable state, always clear before each test:

```clojure
(deftest cache-scenario-test
  (testing "cache behavior"
    ;; Clear state to start fresh
    (reset-state!)

    ;; Test logic...
    ))
```

## Test Organization and Documentation

### Namespace Docstrings

Include clear namespace-level documentation:

```clojure
(ns my-app.integration-test
  "End-to-end integration tests.

   Tests the complete flow:
   1. Process input
   2. Write output
   3. Load and verify"
  (:require ...))
```

### Testing Blocks

Use nested `testing` blocks for clarity:

```clojure
(deftest feature-test
  (testing "happy path"
    ;; Test logic...
    )

  (testing "edge cases"
    ;; Test logic...
    ))
```

## Running Tests

```bash
# Run all tests (common patterns)
bb test
clojure -X:test
lein test

# Run specific test namespace
clojure -M:test -n my-app.core-test
```

## Checklist for New Tests

Before committing test code:

- [ ] Use `testing` blocks with descriptive strings
- [ ] Set up Malli registry fixture if using schemas
- [ ] Prefer property-based tests over unit tests
- [ ] Generate 100+ samples for property-based tests
- [ ] Test properties/invariants, not specific values
- [ ] Clean up temp files/directories in integration tests
- [ ] Include namespace docstring explaining test purpose
- [ ] Clear mutable state before state-dependent tests
- [ ] Run full test suite to verify all tests pass

## Common Patterns Reference

### Testing Ring Handlers

```clojure
(let [app (create-handler)]
  (let [response (app {:uri "/api/users" :request-method :get})]
    (is (= 200 (:status response)))))
```

### Testing Path Parameter Extraction

```clojure
(is (= {:id "123" :action "edit"}
       (extract-params "/users/123/edit" "/users/:id/:action")))
```

### Testing with Assertions on Collections

```clojure
(let [results (process-items items)]
  (is (every? valid? results))
  (is (= (count items) (count results))))
```
