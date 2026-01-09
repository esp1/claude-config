# REPL Workflows and Advanced Techniques

Extended reference for REPL-driven development patterns and techniques.

## Multi-Step Task Management

When working on complex tasks that span multiple steps, maintain focus and context by:

1. **Tracking progress** - Keep notes of what's working
2. **Storing intermediate results** - Save data between steps
3. **Building incrementally** - Don't try to solve everything at once

### Example: Multi-Step Data Pipeline

```clojure
;; Step 1: Load and explore data
(def raw-data (slurp "data.csv"))
(take 100 raw-data) ;; Preview

;; Step 2: Parse first line to understand structure
(first (clojure.string/split-lines raw-data))
;; => "name,age,email"

;; Step 3: Build parser for one line
(defn parse-line [line]
  (let [[name age email] (clojure.string/split line #",")]
    {:name name :age (Integer/parseInt age) :email email}))

(parse-line "Alice,30,alice@example.com")
;; => {:name "Alice", :age 30, :email "alice@example.com"}

;; Step 4: Parse all lines
(def parsed-data
  (->> (clojure.string/split-lines raw-data)
       rest ;; Skip header
       (map parse-line)))

;; Step 5: Validate
(count parsed-data)
(take 3 parsed-data)

;; Step 6: Filter or transform
(def adults
  (filter #(>= (:age %) 18) parsed-data))

;; Step 7: Save working code to files
```

## Dealing with State and Side Effects

### Pattern: Separate Pure and Impure

```clojure
;; Pure - easy to test in REPL
(defn calculate-discount [total customer-type]
  (case customer-type
    :premium (* total 0.9)
    :regular (* total 0.95)
    total))

(calculate-discount 100 :premium)
;; => 90.0

;; Impure - test carefully
(defn apply-discount [order-id customer-type]
  (let [order (db/get-order order-id)
        total (:total order)
        discounted (calculate-discount total customer-type)]
    (db/update-order order-id {:total discounted})
    discounted))

;; Test pure function easily
(map #(calculate-discount 100 %) [:premium :regular :guest])
;; => (90.0 95.0 100)

;; Test impure function with test data
;; (requires test database or mocking)
```

### Pattern: Use Atoms for Stateful REPL Sessions

```clojure
;; Track state during development
(def session-state (atom {:attempts 0
                          :results []
                          :errors []}))

;; Test function and track results
(defn test-with-tracking [f input]
  (swap! session-state update :attempts inc)
  (try
    (let [result (f input)]
      (swap! session-state update :results conj result)
      result)
    (catch Exception e
      (swap! session-state update :errors conj {:input input :error (.getMessage e)})
      nil)))

;; Use it
(test-with-tracking my-function test-input-1)
(test-with-tracking my-function test-input-2)

;; Review session
@session-state
;; => {:attempts 2, :results [...], :errors [...]}
```

## Working with External Resources

### Pattern: Safe Resource Testing

```clojure
;; Test file operations safely
(defn safe-write-test [content]
  (let [test-file "/tmp/test-output.txt"]
    (try
      (spit test-file content)
      (let [read-back (slurp test-file)]
        {:success (= content read-back)
         :written content
         :read read-back})
      (finally
        (.delete (clojure.java.io/file test-file))))))

(safe-write-test "Hello, World!")
;; => {:success true, :written "Hello, World!", :read "Hello, World!"}
```

### Pattern: HTTP Request Testing

```clojure
;; Test HTTP client behavior
(require '[clj-http.client :as http])

;; Start with safe endpoint
(def test-response
  (http/get "https://httpbin.org/get"
            {:as :json}))

;; Explore response structure
(keys test-response)
;; => (:status :headers :body ...)

(:status test-response)
;; => 200

;; Build actual client
(defn fetch-user [user-id]
  (-> (http/get (str "https://api.example.com/users/" user-id)
                {:as :json})
      :body))

;; Test error handling
(try
  (fetch-user 99999)
  (catch Exception e
    {:error :not-found
     :message (.getMessage e)}))
```

## Advanced REPL Techniques

### Hot Code Reloading

```clojure
;; Watch for changes and reload
(require '[clojure.tools.namespace.repl :refer [refresh]])

;; After making file changes:
(refresh)
;; Reloads all changed namespaces

;; If refresh fails, reset:
(require '[clojure.tools.namespace.repl :refer [clear]])
(clear)
(refresh)
```

### Dynamic Function Redefinition

```clojure
;; Original version
(defn process [x]
  (* x 2))

(process 5)
;; => 10

;; Redefine while testing
(defn process [x]
  (+ x 10))

(process 5)
;; => 15

;; Test different implementations quickly
```

### Spec-Driven Development

```clojure
(require '[clojure.spec.alpha :as s])

;; Define spec in REPL
(s/def ::name string?)
(s/def ::age pos-int?)
(s/def ::email string?)
(s/def ::user (s/keys :req [::name ::age ::email]))

;; Validate data
(s/valid? ::user {::name "Alice" ::age 30 ::email "alice@example.com"})
;; => true

(s/explain ::user {::name "Alice" ::age -5 ::email "alice@example.com"})
;; Explains why age -5 is invalid

;; Generate test data
(require '[clojure.spec.gen.alpha :as gen])
(gen/sample (s/gen ::user) 3)
;; => [{::name "..." ::age 1 ::email "..."} ...]
```

## Debugging Techniques

### Tracing Function Calls

```clojure
;; Add temporary logging
(defn process [x]
  (println "Processing:" x)
  (let [result (* x 2)]
    (println "Result:" result)
    result))

(process 5)
;; Processing: 5
;; Result: 10
;; => 10

;; Or use tap>
(defn process [x]
  (tap> {:fn 'process :input x})
  (let [result (* x 2)]
    (tap> {:fn 'process :output result})
    result))

;; Set up tap listener
(add-tap prn)

(process 5)
;; Prints tap> messages
```

### Stepping Through Transformations

```clojure
;; Complex transformation pipeline
(defn process-users [users]
  (->> users
       (filter :active)
       (map :email)
       (filter some?)
       (map clojure.string/lower-case)))

;; Debug by stepping through each stage
(def test-users
  [{:name "Alice" :active true :email "ALICE@EXAMPLE.COM"}
   {:name "Bob" :active false :email "BOB@EXAMPLE.COM"}
   {:name "Charlie" :active true :email nil}])

;; Step 1
(->> test-users
     (filter :active))
;; => ({:name "Alice" ...} {:name "Charlie" ...})

;; Step 2
(->> test-users
     (filter :active)
     (map :email))
;; => ("ALICE@EXAMPLE.COM" nil)

;; Step 3
(->> test-users
     (filter :active)
     (map :email)
     (filter some?))
;; => ("ALICE@EXAMPLE.COM")

;; Step 4 - full pipeline
(->> test-users
     (filter :active)
     (map :email)
     (filter some?)
     (map clojure.string/lower-case))
;; => ("alice@example.com")
```

### Finding Performance Bottlenecks

```clojure
;; Profile with criterium (dev dependency)
(require '[criterium.core :as crit])

(defn slow-version [data]
  (reduce + (map #(* % %) data)))

(defn fast-version [data]
  (transduce (map #(* % %)) + data))

;; Benchmark
(crit/quick-bench (slow-version (range 1000)))
(crit/quick-bench (fast-version (range 1000)))

;; Compare results
```

## REPL Session Patterns

### The Notebook Pattern

Use the REPL like a notebook for exploratory data analysis:

```clojure
;; Load data
(def data (load-dataset))

;; Explore
(count data)
(first data)
(keys (first data))

;; Summary statistics
(def ages (map :age data))
(/ (reduce + ages) (count ages)) ;; Mean age
(apply max ages) ;; Max age
(apply min ages) ;; Min age

;; Group and analyze
(def by-country (group-by :country data))
(keys by-country)
(count (by-country "USA"))

;; Visualize (if using a visualization library)
;; (chart/bar-chart (frequencies (map :country data)))

;; Save interesting findings as functions
(defn age-statistics [data]
  (let [ages (map :age data)]
    {:mean (/ (reduce + ages) (count ages))
     :max (apply max ages)
     :min (apply min ages)}))
```

### The Laboratory Pattern

Test hypotheses about code behavior:

```clojure
;; Hypothesis: map is lazy, mapv is eager

;; Test 1: Side effects with map
(map println (range 5))
;; => (nil nil nil nil nil)
;; (Nothing printed!)

;; Test 2: Force realization
(doall (map println (range 5)))
;; 0
;; 1
;; 2
;; 3
;; 4
;; => (nil nil nil nil nil)

;; Test 3: mapv is eager
(mapv println (range 5))
;; 0
;; 1
;; 2
;; 3
;; 4
;; => [nil nil nil nil nil]

;; Conclusion: Hypothesis confirmed!
```

### The Workshop Pattern

Build components iteratively:

```clojure
;; Component 1: Validator
(defn valid-email? [s]
  (re-matches #".+@.+\..+" s))

(valid-email? "test@example.com") ;; => true
(valid-email? "invalid") ;; => nil

;; Component 2: Parser
(defn parse-email [s]
  (when (valid-email? s)
    (let [[local domain] (clojure.string/split s #"@")]
      {:local local :domain domain})))

(parse-email "alice@example.com")
;; => {:local "alice", :domain "example.com"}

;; Component 3: Processor
(defn process-emails [emails]
  (->> emails
       (filter valid-email?)
       (map parse-email)
       (group-by :domain)))

;; Test with sample data
(process-emails ["alice@example.com"
                 "bob@example.com"
                 "invalid"
                 "charlie@other.com"])
;; => {"example.com" [{:local "alice" ...} {:local "bob" ...}]
;;     "other.com" [{:local "charlie" ...}]}

;; All components work! Save to files.
```

## Integration with Other Tools

### Using REPL with Git

```clojure
;; Load clojure.java.shell for git commands
(require '[clojure.java.shell :as shell])

;; Check git status before committing
(shell/sh "git" "status")

;; Review changes
(shell/sh "git" "diff")

;; After validating code in REPL, commit
(shell/sh "git" "add" "src/my/namespace.clj")
(shell/sh "git" "commit" "-m" "Add new feature")
```

### Using REPL with Linters

```clojure
;; Run clj-kondo on current namespace
(shell/sh "clj-kondo" "--lint" "src/my/namespace.clj")

;; Check entire project
(shell/sh "clj-kondo" "--lint" "src")
```

## Best Practices Summary

### When Starting a REPL Session

1. Load required namespaces
2. Define test data
3. Set up any necessary atoms or refs
4. Configure logging or tap> if needed

### During Development

1. Test each expression before moving on
2. Save interesting intermediate results
3. Use meaningful names even for temporary defs
4. Comment out or delete failed experiments

### Before Saving to Files

1. Clean up temporary code
2. Organize functions logically
3. Remove debug println statements
4. Verify all tests pass
5. Reload namespace to ensure no REPL-only state

### When Ending a Session

1. Save all working code to files
2. Commit changes to version control
3. Document any discoveries or gotchas
4. Clear REPL state if needed: `(clear)` and `(refresh)`

## Common Pitfalls and Solutions

### Pitfall: Stale REPL State

**Problem:** Function works in REPL but fails when reloaded

**Solution:**
```clojure
;; Reset state
(require '[clojure.tools.namespace.repl :refer [refresh]])
(refresh)

;; Or start fresh REPL
```

### Pitfall: Lazy Sequence Gotchas

**Problem:** Side effects don't execute

**Solution:**
```clojure
;; Force realization
(doall (map side-effect-fn data))

;; Or use eager alternatives
(mapv side-effect-fn data)
(run! side-effect-fn data) ;; For side effects only
```

### Pitfall: Swallowing Exceptions

**Problem:** Errors disappear in complex transformations

**Solution:**
```clojure
;; Add explicit error handling
(defn safe-transform [f x]
  (try
    (f x)
    (catch Exception e
      (println "Error transforming" x ":" (.getMessage e))
      nil)))

(->> data
     (map (partial safe-transform risky-function))
     (remove nil?))
```

### Pitfall: Testing with Bad Data

**Problem:** Code works in REPL but fails in production

**Solution:**
```clojure
;; Test with realistic edge cases
(def test-cases
  [nil
   []
   {}
   {:incomplete "data"}
   {:valid "data" :with :fields}])

(map my-function test-cases)
;; See which cases fail
```

## Quick Reference: Common REPL Commands

```clojure
;; Namespace operations
(in-ns 'my.namespace)           ;; Switch namespace
(require '[my.ns :as alias])    ;; Load namespace
(require '[my.ns] :reload)      ;; Reload namespace
(require '[my.ns] :reload-all)  ;; Reload with dependencies

;; Exploration
(doc function-name)             ;; Show documentation
(source function-name)          ;; Show source code
(dir my.namespace)              ;; List namespace contents
(apropos "search-term")         ;; Find functions by name

;; Data inspection
(pprint data)                   ;; Pretty print
(type value)                    ;; Get type
(class value)                   ;; Get class
(ancestors (class value))       ;; Get class hierarchy

;; Testing
(run-tests)                     ;; Run all tests
(test-var #'test-name)          ;; Run specific test

;; Timing
(time (expression))             ;; Time execution

;; Debugging
(tap> value)                    ;; Send to tap system
(add-tap prn)                   ;; Print tapped values
```
