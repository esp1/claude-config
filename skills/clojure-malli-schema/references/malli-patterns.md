# Malli Schema Quick Reference

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
