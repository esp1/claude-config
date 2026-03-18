# REPL Workflows and Advanced Techniques

Extended reference for REPL-driven development patterns and techniques.

## Pattern: Use Atoms for Stateful REPL Sessions

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

;; Step 3 - add filtering
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

;; Group and analyze
(def by-country (group-by :country data))
(keys by-country)
(count (by-country "USA"))

;; Save interesting findings as functions
(defn age-statistics [data]
  (let [ages (map :age data)]
    {:mean (/ (reduce + ages) (count ages))
     :max (apply max ages)
     :min (apply min ages)}))
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
