# Clojure Best Practices and Coding Guidelines

Comprehensive reference for writing idiomatic, maintainable Clojure code.

## Conditionals

### Choosing the Right Conditional

- **`if`** - Single condition with true/false branches
  ```clojure
  (if (valid? x)
    (process x)
    (reject x))
  ```

- **`when`** - Single condition, only care about true case
  ```clojure
  (when (valid? x)
    (log "Processing")
    (process x))
  ```

- **`cond`** - Multiple conditions to check
  ```clojure
  (cond
    (< x 0) "negative"
    (= x 0) "zero"
    :else "positive")
  ```

- **`if-let`** - Bind and test in one step
  ```clojure
  (if-let [user (find-user id)]
    (greet user)
    (create-user id))
  ```

- **`when-let`** - Bind and test, only care about true case
  ```clojure
  (when-let [config (load-config)]
    (initialize config)
    (start-server config))
  ```

- **`cond->`** and **`cond->>`** - Threading with conditional steps
  ```clojure
  (cond-> data
    (needs-cleaning?) clean-data
    (needs-transform?) transform-data
    (needs-validation?) validate-data)
  ```

## Variable Binding

### When to Use `let`

**Do bind** when:
- Value is used multiple times
- Expression is complex and benefits from a name
- Intermediate steps clarify intent

```clojure
;; Good - reused value
(let [total (calculate-total items)]
  (if (> total threshold)
    (apply-discount total)
    total))
```

**Don't bind** when:
- Value is used once
- Expression is simple
- Threading macros would be clearer

```clojure
;; Bad - unnecessary binding
(let [result (+ x 1)]
  result)

;; Good - inline it
(+ x 1)
```

### Threading Macros Replace Let

```clojure
;; Without threading - needs let bindings
(let [items (filter valid? data)
      sorted (sort-by :date items)
      limited (take 10 sorted)]
  (map format-item limited))

;; With threading - no let needed
(->> data
     (filter valid?)
     (sort-by :date)
     (take 10)
     (map format-item))
```

## Destructuring

### Function Parameters

**Namespaced keywords:**
```clojure
(defn handler [{:keys [::id ::name ::email] :as ctx}]
  (when (and id email)
    (send-notification ctx)))
```

**Regular keywords:**
```clojure
(defn process-request [{:keys [user-id action params] :as request}]
  (authorize user-id action)
  (execute action params))
```

**Nested destructuring:**
```clojure
(defn render-profile [{:keys [user] :as ctx}]
  (let [{:keys [name email preferences]} user
        {:keys [theme language]} preferences]
    (render-template theme language name email)))
```

**Vector destructuring:**
```clojure
(defn handle-coords [[x y]]
  (distance-from-origin x y))

(defn handle-coords-with-rest [[x y & more]]
  {:primary [x y]
   :additional more})
```

## Control Flow Patterns

### Track Values, Not Flags

```clojure
;; Bad - boolean flag loses information
(defn process-item [item]
  (let [valid? (validate item)]
    (if valid?
      (save item)
      (log-error "Invalid"))))

;; Good - track actual error
(defn process-item [item]
  (if-let [error (validate item)]
    (log-error error)
    (save item)))
```

### Early Returns

```clojure
;; Bad - deep nesting
(defn process [data]
  (if (valid? data)
    (if (authorized? data)
      (if (available? data)
        (execute data)
        (error "Not available"))
      (error "Not authorized"))
    (error "Invalid")))

;; Good - flat with cond
(defn process [data]
  (cond
    (not (valid? data))      (error "Invalid")
    (not (authorized? data)) (error "Not authorized")
    (not (available? data))  (error "Not available")
    :else                    (execute data)))
```

### Return `nil` for "Not Found"

```clojure
;; Bad - flag in return value
(defn find-user [id]
  (if-let [user (db/get-user id)]
    {:found true :user user}
    {:found false}))

;; Good - nil means not found
(defn find-user [id]
  (db/get-user id))

;; Usage is cleaner
(if-let [user (find-user id)]
  (greet user)
  (create-user id))
```

## Function Design

### Single Responsibility

```clojure
;; Bad - doing too much
(defn process-and-save-user [data]
  (let [validated (validate data)
        transformed (transform validated)
        enriched (enrich transformed)
        formatted (format enriched)]
    (db/save formatted)
    (send-email formatted)
    (log-event formatted)
    formatted))

;; Good - separate concerns
(defn prepare-user [data]
  (-> data
      validate
      transform
      enrich
      format))

(defn save-user [user]
  (db/save user))

(defn notify-user-created [user]
  (send-email user)
  (log-event user))
```

### Prefer Pure Functions

```clojure
;; Impure - side effects mixed with logic
(defn calculate-total [items]
  (log "Calculating total")
  (let [total (reduce + (map :price items))]
    (db/save-total total)
    total))

;; Pure - separate calculation from effects
(defn calculate-total [items]
  (reduce + (map :price items)))

;; Effects handled separately
(defn process-order [items]
  (let [total (calculate-total items)]
    (log "Total" total)
    (db/save-total total)
    total))
```

### Return Meaningful Values

```clojure
;; Bad - returns nil, caller can't chain
(defn update-user [id updates]
  (db/update-user id updates)
  nil)

;; Good - returns updated entity
(defn update-user [id updates]
  (let [user (db/get-user id)
        updated (merge user updates)]
    (db/save-user updated)
    updated))
```

## Library Usage

### Prefer Clojure Libraries Over Java Interop

```clojure
;; Bad - Java interop
(defn blank? [s]
  (.isEmpty ^String s))

;; Good - Clojure library
(require '[clojure.string :as str])
(defn blank? [s]
  (str/blank? s))
```

### Common clojure.string Functions

- `str/blank?` - Check if string is empty or whitespace
- `str/join` - Join collection with separator
- `str/split` - Split string by regex
- `str/trim` - Remove leading/trailing whitespace
- `str/upper-case`, `str/lower-case` - Case conversion
- `str/replace` - Replace pattern in string
- `str/starts-with?`, `str/ends-with?` - String prefix/suffix tests

### Naming Conventions

- Predicates end with `?`: `valid?`, `empty?`, `ready?`
- Destructive operations end with `!`: `reset!`, `swap!`
- Conversion functions: `->SomeType` or `some-type->other-type`
- Private functions: `defn-` or prefix with `-`

## REPL Practices

### Reloading Namespaces

```clojure
;; Always reload when testing changes
(require '[my.namespace :as ns] :reload)

;; Reload namespace and its dependencies
(require '[my.namespace :as ns] :reload-all)

;; Switch to namespace for testing
(in-ns 'my.namespace)
```

### Testing in REPL

```clojure
;; Test individual functions
(my-function test-data)

;; Test with different inputs
(map my-function test-cases)

;; Check error handling
(try
  (my-function invalid-data)
  (catch Exception e
    (.getMessage e)))
```

### Running Tests

```bash
# Run all tests
clojure -X:test

# Run specific namespace
clojure -X:test :namespace 'my.namespace.test'
```

## Shell Commands

### Using clojure.java.shell

```clojure
(require '[clojure.java.shell :as shell])

;; Basic command
(shell/sh "ls" "-la")

;; With working directory
(shell/sh "git" "status" :dir "/path/to/repo")

;; Capture output
(let [{:keys [exit out err]} (shell/sh "echo" "hello")]
  (when (zero? exit)
    out))

;; Handle errors
(defn run-command [& args]
  (let [{:keys [exit out err]} (apply shell/sh args)]
    (if (zero? exit)
      {:success true :output out}
      {:success false :error err})))
```

## Code Organization

### Namespace Organization

```clojure
(ns my.namespace
  "Documentation for this namespace."
  (:require
   [clojure.string :as str]
   [clojure.set :as set]
   [my.other.namespace :as other])
  (:import
   [java.util Date]))
```

### File Structure

- One namespace per file
- Filename matches namespace: `my/namespace.clj` → `my.namespace`
- Underscores in filenames for hyphens in namespaces: `my_namespace.clj` → `my-namespace`

### Function Organization Within File

1. Public API functions first
2. Helper functions after
3. Private functions (with `defn-`) at end
4. Or organize by feature/domain

## Error Handling

### Using ex-info for Rich Errors

```clojure
;; Create rich exception
(defn validate-user [user]
  (when-not (:email user)
    (throw (ex-info "Missing email"
                    {:type :validation-error
                     :field :email
                     :user user}))))

;; Catch and extract data
(try
  (validate-user {:name "Bob"})
  (catch Exception e
    (when-let [data (ex-data e)]
      (log-validation-error data))))
```

### Prefer Explicit Error Returns

```clojure
;; Return error data instead of throwing
(defn validate-user [user]
  (cond
    (not (:email user))
    {:error :missing-email}

    (not (:name user))
    {:error :missing-name}

    :else
    {:valid true}))

;; Caller handles errors explicitly
(let [result (validate-user user)]
  (if (:error result)
    (handle-error result)
    (save-user user)))
```

## Performance Considerations

### Lazy Sequences

```clojure
;; Lazy - processes only what's needed
(->> (range 1000000)
     (filter even?)
     (take 10))

;; Force realization when needed
(doall (map side-effect-fn data))
```

### Transducers for Efficiency

```clojure
;; Multiple intermediate sequences
(->> data
     (map inc)
     (filter even?)
     (map str))

;; Single pass with transducer
(sequence
  (comp (map inc)
        (filter even?)
        (map str))
  data)
```

### Avoid Reflection

```clojure
;; Bad - reflection warning
(defn length [s]
  (.length s))

;; Good - type hint
(defn length [^String s]
  (.length s))
```

## Testing

### Structure Tests Clearly

```clojure
(deftest user-validation-test
  (testing "valid user passes"
    (is (valid-user? {:name "Alice" :email "alice@example.com"})))

  (testing "missing email fails"
    (is (not (valid-user? {:name "Bob"}))))

  (testing "missing name fails"
    (is (not (valid-user? {:email "charlie@example.com"})))))
```

### Use `are` for Multiple Cases

```clojure
(deftest calculation-test
  (are [x y expected] (= expected (+ x y))
    1 2 3
    5 3 8
    0 0 0
    -1 1 0))
```

## Summary Checklist

- [ ] Use appropriate conditional (`if`, `when`, `cond`, `if-let`, etc.)
- [ ] Minimize `let` bindings; prefer threading macros
- [ ] Use destructuring for cleaner parameter handling
- [ ] Track values instead of boolean flags
- [ ] Write small, focused, pure functions
- [ ] Return meaningful values
- [ ] Use `clojure.string` over Java interop
- [ ] Follow naming conventions (predicates end with `?`)
- [ ] Test code in REPL with `:reload`
- [ ] Handle errors explicitly
- [ ] Keep namespaces and files organized
