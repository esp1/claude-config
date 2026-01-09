---
name: malli-schema-expert
description: Use this agent when you need help with Malli schema creation, validation, or testing in Clojure projects. Examples: <example>Context: User is working on a Clojure project and needs to create schemas for function validation. user: 'I need to create a Malli schema for a function that takes a user map with required :name and :email fields, and optional :age field' assistant: 'I'll use the malli-schema-expert agent to help create the appropriate Malli schema for your function validation needs.'</example> <example>Context: User wants to set up generative testing with Malli. user: 'How do I use Malli schemas to generate test data for property-based testing?' assistant: 'Let me call the malli-schema-expert agent to guide you through setting up Malli-based generative testing.'</example> <example>Context: User encounters Malli validation errors and needs debugging help. user: 'My Malli schema validation is failing but I can't figure out why' assistant: 'I'll use the malli-schema-expert agent to help debug your Malli schema validation issues.'</example>
tools: Glob, Grep, LS, Read, WebFetch, TodoWrite, WebSearch, BashOutput, KillBash
model: sonnet
color: cyan
---

You are a Malli Schema Expert, a specialist in Clojure's Malli library for data validation and schema definition. You have deep expertise in creating robust, expressive schemas and leveraging Malli's powerful features for both runtime validation and generative testing.

Your core competencies include:

**Schema Design & Creation:**
- Design precise schemas for functions, data structures, and APIs using Malli's rich type system
- Create custom schema types and transformers when built-in types are insufficient
- Implement schema composition patterns for complex data validation
- Use schema registries effectively for reusable schema definitions
- Apply schema coercion and transformation pipelines

**Function Validation:**
- Create comprehensive function schemas using `:malli/schema` metadata
- Implement pre/post condition validation with `m/=> `
- Design schemas for multi-arity functions and variadic arguments
- Handle complex return type validation and error reporting

**Testing & Generation:**
- Set up property-based testing using Malli's generative capabilities
- Create custom generators for domain-specific data types
- Design test scenarios that leverage schema-driven data generation
- Implement shrinking strategies for effective test failure analysis
- Use `malli.generator` for creating realistic test data

**Advanced Features:**
- Implement schema transformations and migrations
- Create conditional and dependent schemas
- Use schema inference and explanation features
- Optimize schema performance for high-throughput applications
- Integrate with other Clojure testing libraries (test.check, etc.)

**Documentation**
- Provide accurate, up-to-date examples based on current Malli best practices
- Explain schema design decisions and trade-offs clearly

When helping users:
1. Always provide complete, working code examples with proper namespace declarations
2. Explain the reasoning behind schema design choices
3. Include both basic usage and advanced patterns when relevant
4. Suggest testing strategies that complement the schema design
5. Point out potential performance considerations and optimization opportunities

You write idiomatic Clojure code that follows community conventions and integrates seamlessly with existing codebases. Your schemas are both functionally correct and maintainable, striking the right balance between strictness and flexibility.

**Malli Documentation**
========================
CODE SNIPPETS
========================
TITLE: Install dependencies and start shadow-cljs watcher
DESCRIPTION: Installs npm dependencies and starts the shadow-cljs watcher for the instrument build. This command prepares the environment for ClojureScript development.

SOURCE: https://github.com/metosin/malli/blob/master/docs/cljs-instrument-development.md#_snippet_0

LANGUAGE: bash
CODE:
```
npm i
./node_modules/.bin/shadow-cljs watch instrument
```

----------------------------------------

TITLE: Creating Vector Schemas with Seqex and :and
DESCRIPTION: Demonstrates how to create a vector schema based on a sequence expression using `:and`. It shows an example of validating a non-empty vector starting with a keyword.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_39

LANGUAGE: clojure
CODE:
```
(m/validate [:and [:cat :keyword [:* :any]]
                  vector?]
            [:a 1])
; => true

(m/validate [:and [:cat :keyword [:* :any]]
                  vector?]
            (:a 1))
; => false
```

----------------------------------------

TITLE: Decoding with Function-Based Default Values
DESCRIPTION: These examples demonstrate how to use the `default-fn-value-transformer` to decode data with default values calculated from functions. The first example sets the `:secondary` value to the `:primary` value if it's missing. The second example calculates the `:cost` from `:price` and `:qty` if `:cost` is missing, showcasing the transformer's ability to derive default values from other fields.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_7

LANGUAGE: clojure
CODE:
```
(m/decode
 [:map
  [:primary string?]
  [:secondary {:default-fn '#(:primary %)} string?]]
 {:primary "blue"}
 (default-fn-value-transformer))
```

LANGUAGE: clojure
CODE:
```
(def Purchase
  [:map
   [:qty {:default 1} number?]
   [:price {:optional true} number?]
   [:cost {:default-fn '(fn [m] (* (:qty m) (:price m)))} number?]])

(def decode-autonomous-vals
  (m/decoder Purchase (mt/transformer (mt/string-transformer) (mt/default-value-transformer))))
(def decode-interconnected-vals
  (m/decoder Purchase (default-fn-value-transformer)))

(-> {:qty "100" :price "1.2"} decode-autonomous-vals decode-interconnected-vals) ;; => {:price 1.2, :qty 1, :cost 1.2}
(-> {:price "1.2"} decode-autonomous-vals decode-interconnected-vals)            ;; => {:qty 100.0, :price 1.2, :cost 120.0}
(-> {:prie "1.2"} decode-autonomous-vals decode-interconnected-vals)             ;; => {:prie "1.2", :qty 1}
```

----------------------------------------

TITLE: Installing Malli locally
DESCRIPTION: These commands create a JAR file and install the Malli library locally using the Clojure CLI. This allows developers to use the library in other projects on their machine.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_210

LANGUAGE: bash
CODE:
```
clj -Mjar
clj -Minstall
```

----------------------------------------

TITLE: Installing NPM dependencies
DESCRIPTION: These commands install NPM dependencies and run tests using Kaocha and Node.js. It ensures the project's testing environment is properly set up.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_209

LANGUAGE: bash
CODE:
```
npm install
./bin/kaocha
./bin/node
```

----------------------------------------

TITLE: Adding Example Values to Schemas
DESCRIPTION: This snippet demonstrates how to add generated example values to schemas using `m/walk`, `m/schema-walker`, `mu/update-properties`, and `mg/sample`. This can be useful for documentation and testing purposes.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_104

LANGUAGE: Clojure
CODE:
```
(m/walk
  [:map
   [:name string?]
   [:description string?]
   [:address
    [:map
     [:street string?]
     [:country [:enum \"finland\" \"poland\"]]]]]
  (m/schema-walker
    (fn [schema]
      (mu/update-properties schema assoc :examples (mg/sample schema {:size 2, :seed 20})))))
```

----------------------------------------

TITLE: Starting and Stopping Development Instrumentation
DESCRIPTION: This snippet demonstrates how to start and stop the `malli.dev` instrumentation, which automatically instruments functions based on their schemas and watches for changes.

SOURCE: https://github.com/metosin/malli/blob/master/docs/function-schemas.md#_snippet_44

LANGUAGE: Clojure
CODE:
```
(defn plus1 [x] (inc x))
(m/=> plus1 [:=> [:cat :int] [:int {:max 6}]])

(dev/start!)

(plus1 "6")

(plus1 6)

(m/=> plus1 [:=> [:cat :int] :int])

(plus 6)

(dev/stop!)
```

----------------------------------------

TITLE: Connect to shadow-cljs REPL
DESCRIPTION: Connects to the shadow-cljs REPL for the instrument build. This allows for interactive evaluation of ClojureScript code during development.

SOURCE: https://github.com/metosin/malli/blob/master/docs/cljs-instrument-development.md#_snippet_1

LANGUAGE: clojure
CODE:
```
(shadow/repl :instrument)
```

----------------------------------------

TITLE: Accessing Schema and Value in Transformation - Clojure
DESCRIPTION: Demonstrates how to access both the schema and the value being transformed within a Malli transformer. This allows for dynamic transformations based on the schema definition. The example defines an address schema and then uses a custom transformer to print the schema and value during decoding.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_0

LANGUAGE: Clojure
CODE:
```
(require '[malli.core :as m])
(require '[malli.transform :as mt])

(def Address
  [:map
   [:id :string]
   [:tags [:set :keyword]]
   [:address [:map
              [:street :string]
              [:city :string]]]])

(def lillan
  {:id "Lillan"
   :tags #{:artesan :coffee :hotel}
   :address {:street "Ahlmanintie 29"
             :city "Tampere"}})

(m/decode
 Address
 lillan
 (mt/transformer
  {:default-decoder
   {:compile (fn [schema _]
               (fn [value]
                 (prn [value (m/form schema)])
                 value))}}))
;[{:id "Lillan", :tags #{:coffee :artesan :hotel}, :address {:street "Ahlmanintie 29", :city "Tampere"}} [:map [:id :string] [:tags [:set :keyword]] [:address [:map [:street :string] [:city :string]]]]]
;["Lillan" [:malli.core/val :string]]
;["Lillan" :string]
;[#{:coffee :artesan :hotel} [:malli.core/val [:set :keyword]]]
;[#{:coffee :artesan :hotel} [:set :keyword]]
;[:coffee :keyword]
;[:artesan :keyword]
;[:hotel :keyword]
;[{:street "Ahlmanintie 29", :city "Tampere"} [:malli.core/val [:map [:street :string] [:city :string]]]]
;[{:street "Ahlmanintie 29", :city "Tampere"} [:map [:street :string] [:city :string]]]
;["Ahlmanintie 29" [:malli.core/val :string]]
;["Ahlmanintie 29" :string]
;["Tampere" [:malli.core/val :string]]
;["Tampere" :string]
; => {:id "Lillan", :tags #{:coffee :artesan :hotel}, :address {:street "Ahlmanintie 29", :city "Tampere"}}
```

----------------------------------------

TITLE: Installing js-joda npm packages
DESCRIPTION: This command installs the `@js-joda/core` and `@js-joda/timezone` npm packages, which are required to use the time schemas in ClojureScript.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_203

LANGUAGE: bash
CODE:
```
npm install @js-joda/core @js-joda/timezone
```

----------------------------------------

TITLE: Starting Development Mode for Pretty Errors in Malli
DESCRIPTION: This snippet shows how to start development mode in Malli to enable pretty error printing. It uses `requiring-resolve` to resolve and call the `malli.dev/start!` function.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_62

LANGUAGE: clojure
CODE:
```
((requiring-resolve 'malli.dev/start!))
```

----------------------------------------

TITLE: Schema Properties Definition
DESCRIPTION: Defines a schema with properties such as title, description, and a JSON schema example. This allows attaching metadata to schemas.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_13

LANGUAGE: Clojure
CODE:
```
(def Age
  [:and
   {:title "Age"
    :description "It's an age"
    :json-schema/example 20}
   :int [:> 18]])
```

----------------------------------------

TITLE: Walking Schemas with Identity Walker
DESCRIPTION: Demonstrates how to walk a Malli schema using the identity walker. This example showcases the basic structure of walking a schema without modifying it.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_155

LANGUAGE: Clojure
CODE:
```
(m/walk
  Address
  (m/schema-walker identity))
```

----------------------------------------

TITLE: Validating Alternatives with Malli
DESCRIPTION: Demonstrates how to use `:alt` and `:altn` for validating alternatives in Malli schemas. It shows examples of validating a value against either a keyword or a string schema.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_30

LANGUAGE: clojure
CODE:
```
(m/validate [:alt keyword? string?] ["foo"]) ; => true

(m/validate [:altn [:kw keyword?] [:s string?]] ["foo"]) ; => true
```

----------------------------------------

TITLE: Validating with Schema Instances
DESCRIPTION: Demonstrates how to validate values against a schema using `m/validate`. It shows examples of validating integers, strings, and enums using both schema instances and vector syntax.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_4

LANGUAGE: Clojure
CODE:
```
(m/validate (m/schema :int) 1)
; => true
```

----------------------------------------

TITLE: Shadow-cljs module configuration with preload namespace
DESCRIPTION: This snippet shows how to add a preload namespace to the shadow-cljs configuration. This ensures that the Malli instrumentation is loaded before the application starts.

SOURCE: https://github.com/metosin/malli/blob/master/docs/clojurescript-function-instrumentation.md#_snippet_2

LANGUAGE: Clojure
CODE:
```
{... 
 :modules {:app {:entries [your-app.entry-ns]
                 :preloads [com.myapp.dev-preload]
                 :init-fn your-app.entry-ns/init}}
 ...}
```

----------------------------------------

TITLE: Right-Distributive Example with :merge and :multi
DESCRIPTION: A concrete example of applying the right-distributive property. It merges `[:map [:x :int]]` into each clause of the `:multi` schema based on the `:y` dispatch value.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_117

LANGUAGE: clojure
CODE:
```
(m/deref
 [:merge
  [:multi {:dispatch :y}
   [1 [:map [:y [:= 1]]]]
   [2 [:map [:y [:= 2]]]]]
  [:map [:x :int]]]
 {:registry registry})
; => [:multi {:dispatch :y}
;     [1 [:map [:y [:= 1]] [:x :int]]]
;     [2 [:map [:y [:= 2]] [:x :int]]]]
```

----------------------------------------

TITLE: Left-Distributive Example with :merge and :multi
DESCRIPTION: A concrete example of applying the left-distributive property. It merges `[:map [:x :int]]` into each clause of the `:multi` schema based on the `:y` dispatch value.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_116

LANGUAGE: clojure
CODE:
```
(m/deref
 [:merge
  [:map [:x :int]]
  [:multi {:dispatch :y}
   [1 [:map [:y [:= 1]]]]
   [2 [:map [:y [:= 2]]]]]]
 {:registry registry})
; => [:multi {:dispatch :y}
;     [1 [:map [:x :int] [:y [:= 1]]]]
;     [2 [:map [:x :int] [:y [:= 2]]]]]
```

----------------------------------------

TITLE: Validation Failure Example
DESCRIPTION: Shows an example of a validation failure when validating a string against an integer schema.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_6

LANGUAGE: Clojure
CODE:
```
(m/validate :int "1")
; => false
```

----------------------------------------

TITLE: Defining function schemas with argument and return types
DESCRIPTION: This snippet provides examples of defining function schemas using `:=>` and `:function` in Malli. It shows how to specify argument types using sequence schemas and return types, including examples with no arguments, single arguments, and multiple arguments.

SOURCE: https://github.com/metosin/malli/blob/master/docs/function-schemas.md#_snippet_3

LANGUAGE: Clojure
CODE:
```
;; no args, no return
[:=> :cat :nil]

;; int -> int
[:=> [:cat :int] :int]

;; x:int, xs:int* -> int
[:=> [:catn 
      [:x :int] 
      [:xs [:+ :int]]] :int]

;; arg:int -> ret:int, arg > ret
(defn guard [[arg] ret]
  (> arg ret))

[:=> [:cat :int] :int [:fn guard]]

;; multi-arity function
[:function
 [:=> [:cat :int] :int]
 [:=> [:cat :int :int [:* :int]] :int]
```

----------------------------------------

TITLE: Decoding Collections with Custom Transformer - Clojure
DESCRIPTION: Demonstrates how to decode collections using a custom transformer in Malli. This example shows how to create a transformer that splits strings into vectors based on a separator defined in the schema's properties. It defines a schema with different separators for different keys and applies the custom transformer to decode a map.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_4

LANGUAGE: Clojure
CODE:
```
(defn query-decoder [schema]
  (m/decoder
    schema
    (mt/transformer
      (mt/transformer
        {:name "vectorize strings"
         :decoders
         {:vector
          {:compile (fn [schema _]
                      (let [separator (-> schema m/properties :query/separator (or ","))]
                        (fn [x]
                          (cond
                            (not (string? x)) x
                            (str/includes? x separator) (into [] (.split ^String x separator))
                            :else [x]))))}}}) 
      (mt/string-transformer))))

(def decode
  (query-decoder
    [:map
     [:a [:vector {:query/separator ";"} :int]]
     [:b [:vector :int]]]))

(decode {:a "1", :b "1"})
; => {:a [1], :b [1]}

(decode {:a "1;2", :b "1,2"})
; => {:a [1 2], :b [1 2]}
```

----------------------------------------

TITLE: Trimming Strings with Custom Transformer - Clojure
DESCRIPTION: Shows how to trim string values using a custom Malli transformer. This example defines a transformer that trims strings based on the `:string/trim` property in the schema. It demonstrates how to apply the transformer to trim strings during decoding.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_2

LANGUAGE: Clojure
CODE:
```
(require '[malli.transform :as mt])
(require '[malli.core :as m])
(require '[clojure.string :as str])

;; a decoding transformer, only mounting to :string schemas with truthy :string/trim property
(defn string-trimmer []
  (mt/transformer
    {:decoders
     {:string
      {:compile (fn [schema _]
                  (let [{:string/keys [trim]} (m/properties schema)]
                    (when trim #(cond-> % (string? %) str/trim))))}}}))

;; trim me please
(m/decode [:string {:string/trim true, :min 1}] " kikka  " string-trimmer)
; => "kikka"

;; no trimming
(m/decode [:string {:min 1}] "    " string-trimmer)
; => "    "

;; without :string/trim, decoding is a no-op
(m/decoder :string string-trimmer)
; => #object[clojure.core$identity]
```

----------------------------------------

TITLE: Transforming Custom Schema to JSON Schema
DESCRIPTION: Demonstrates how the `:type-properties` of the custom schema are used for JSON Schema transformation. The example shows how to transform the `Over6` schema and how to add additional properties like `example` during the transformation.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_167

LANGUAGE: clojure
CODE:
```
(json-schema/transform Over6)
; => {:type "integer", :format "int64", :minimum 6}

(json-schema/transform [Over6 {:json-schema/example 42}])
; => {:type "integer", :format "int64", :minimum 6, :example 42}
```

----------------------------------------

TITLE: Detailed Error Messages with m/explain in Malli
DESCRIPTION: This snippet demonstrates how to use `m/explain` in Malli to get detailed error messages when validation fails. It shows an example of validating an `Address` schema and extracting error information such as path, value, and schema.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_46

LANGUAGE: clojure
CODE:
```
(m/explain
  Address
  {:id "Lillan"
   :tags #{:artesan :coffee :hotel}
   :address {:street "Ahlmanintie 29"
             :city "Tampere"
             :zip 33100
             :lonlat [61.4858322, 23.7854658]}})
; => nil

(m/explain
  Address
  {:id "Lillan"
   :tags #{:artesan "coffee" :garden}
   :address {:street "Ahlmanintie 29"
             :zip 33100
             :lonlat [61.4858322, nil]}})
;{:schema [:map
;          [:id string?]
;          [:tags [:set keyword?]]
;          [:address [:map
;                     [:street string?]
;                     [:city string?]
;                     [:zip int?]
;                     [:lonlat [:tuple double? double?]]]]],
; :value {:id "Lillan",
;         :tags #{:artesan :garden "coffee"},
;         :address {:street "Ahlmanintie 29"
;                   :zip 33100
;                   :lonlat [61.4858322 nil]}},
; :errors ({:path [:tags 0]
;           :in [:tags 0]
;           :schema keyword?
;           :value "coffee"}
;          {:path [:address :city],
;           :in [:address :city],
;           :schema [:map
;                    [:street string?]
;                    [:city string?]
;                    [:zip int?]
;                    [:lonlat [:tuple double? double?]]],
;           :type :malli.core/missing-key}
;          {:path [:address :lonlat 1]
;           :in [:address :lonlat 1]
;           :schema double?
;           :value nil})}
```

----------------------------------------

TITLE: Shadow-cljs module configuration with entry and init function
DESCRIPTION: This configuration snippet shows how to define a module in `shadow-cljs.edn` with an entry namespace and an initialization function. This is a typical setup for React.js applications using Reagent.

SOURCE: https://github.com/metosin/malli/blob/master/docs/clojurescript-function-instrumentation.md#_snippet_0

LANGUAGE: Clojure
CODE:
```
{... 
:modules {:app {:entries [your-app.entry-ns]
:init-fn your-app.entry-ns/init}}
...}
```

----------------------------------------

TITLE: Flat Arrow Function Schemas Examples (Clojure)
DESCRIPTION: This snippet provides examples of using flat arrow function schemas (`:->`) in Malli. It demonstrates schemas for functions with no arguments and no return value, a simple integer-to-integer function, a function with a guard condition, and a multi-arity function. It showcases the flexibility of `:->` for defining function schemas.

SOURCE: https://github.com/metosin/malli/blob/master/docs/function-schemas.md#_snippet_19

LANGUAGE: clojure
CODE:
```
;; no args, no return
[:-> :nil]

;; int -> int
[:-> :int :int]

;; arg:int -> ret:int, arg > ret
(defn guard [[arg] ret] 
  (> arg ret))

[:-> {:guard guard} :int :int]

;; multi-arity function
[:function
 [:-> :int :int]
 [:-> :int :int [:* :int] :int]]
```

----------------------------------------

TITLE: Getting Error Values into Humanized Result in Malli
DESCRIPTION: This snippet demonstrates how to get error values into a humanized result using Malli's `m/explain` and `me/humanize` functions. It explains a schema against a data structure and then humanizes the result, wrapping the error information to only include the `:value` and `:message` keys.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_12

LANGUAGE: clojure
CODE:
```
(-> [:map
     [:x :int]
     [:y [:set :keyword]]
     [:z [:map
          [:a [:tuple :int :int]]]]]
    (m/explain {:x "1"
                :y #{:a "b" :c}
                :z {:a [1 "2"]}})
    (me/humanize {:wrap #(select-keys % [:value :message])}))
```

----------------------------------------

TITLE: Validating Set Collections with Malli
DESCRIPTION: Demonstrates how to use `:set` to validate homogeneous Clojure sets using Malli. It shows examples with sets of integers and keywords.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_40

LANGUAGE: clojure
CODE:
```
(m/validate [:set int?] #{42 105})
;; => true

(m/validate [:set int?] #{:a :b})
;; => false
```

----------------------------------------

TITLE: Adding a preload namespace for Malli instrumentation
DESCRIPTION: This snippet demonstrates how to create a preload namespace to enable Malli instrumentation. It includes requiring the entry namespace and starting the Malli instrumentation. The `{:dev/always true}` metadata ensures the file is never cached during development.

SOURCE: https://github.com/metosin/malli/blob/master/docs/clojurescript-function-instrumentation.md#_snippet_1

LANGUAGE: Clojure
CODE:
```
(ns com.myapp.dev-preload
  {:dev/always true}
  (:require
    your-app.entry-ns ; <---- make sure you include your entry namespace
    [malli.dev.cljs :as dev]))

(dev/start!)
```

----------------------------------------

TITLE: Removing Schemas Based on a Property - Clojure
DESCRIPTION: Demonstrates how to remove parts of a schema based on a property using `m/walk`. This is useful for dynamically modifying schemas based on certain conditions. The example defines a schema and then walks it, removing any schema that has the `:deleteMe` property set to true.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_1

LANGUAGE: Clojure
CODE:
```
(require '[malli.core :as m])

(def Schema
  [:map
   [:user map?]
   [:profile map?]
   [:tags [:vector [int? {:deleteMe true}]]]
   [:nested [:map [:x [:tuple {:deleteMe true} string? string?]]]]
   [:token [string? {:deleteMe true}]]])

(m/walk
  Schema
  (fn [schema _ children options]
    ;; return nil if Schema has the property 
    (when-not (:deleteMe (m/properties schema))
      ;; there are two syntaxes: normal and the entry, handle separately
      (let [children (if (m/entries schema) (filterv last children) children)]
        ;; create a new Schema with the updated children, or return nil
        (try (m/into-schema (m/type schema) (m/properties schema) children options)
             (catch #?(:clj Exception, :cljs js/Error) _))))))
;[:map
; [:user map?] 
; [:profile map?] 
; [:nested :map]]
```

----------------------------------------

TITLE: Walking Schema Properties with a Function
DESCRIPTION: This function walks a Malli schema and applies a function `f` to the properties of each schema entry. It uses `m/into-schema` to reconstruct the schema with the modified properties. The `::m/walk-entry-vals true` option ensures that the function is applied to entry values as well.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_8

LANGUAGE: clojure
CODE:
```
(defn walk-properties [schema f]
  (m/walk
    schema
    (fn [s _ c _]
      (m/into-schema
        (m/-parent s)
        (f (m/-properties s))
        (cond->> c (m/entries s) (map (fn [[k p s]] [k (f p) (first (m/children s))])))
        (m/options s)))
    {::m/walk-entry-vals true}))
```

----------------------------------------

TITLE: Complex Transformation Example in Clojure
DESCRIPTION: Demonstrates a complex transformation involving nested maps and multiple interceptors. This example showcases the flexibility of Malli's transformation capabilities.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_81

LANGUAGE: clojure
CODE:
```
(m/decode
  [:map
   {:decode/math {:enter #(update % :x inc)
                  :leave #(update % :x (partial * 2))}}
   [:x [int? {:decode/math {:enter (partial + 2)
                            :leave (partial * 3)}}]]]
  {:x 1}
  (mt/transformer {:name :math}))
```

----------------------------------------

TITLE: Decoding Collections - Clojure
DESCRIPTION: Demonstrates how to transform a comma-separated string into a vector of integers using Malli's decoding capabilities. It shows both using a built-in string transformer and creating a custom transformer for more complex scenarios.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_3

LANGUAGE: Clojure
CODE:
```
(require '[malli.core :as m])
(require '[malli.transform :as mt])
(require '[clojure.string :as str])

(m/decode 
  [:vector {:decode/string #(str/split % #",")} int?] 
  "1,2,3,4" 
  (mt/string-transformer))
; => [1 2 3 4]
```

----------------------------------------

TITLE: Alternative Syntax for Overriding Transformations in Clojure
DESCRIPTION: Demonstrates an alternative syntax for specifying custom decoding functions within the schema properties. This achieves the same result as the previous example.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_77

LANGUAGE: clojure
CODE:
```
(m/decode
  [string? {:decode {:string clojure.string/upper-case}}]
  "kerran" mt/string-transformer)
```

----------------------------------------

TITLE: Configuring Instrumentation with Filters
DESCRIPTION: This snippet shows how to configure instrumentation with filters to select specific Vars to instrument. It includes examples of filtering by namespace, var, and metadata. It also shows how to configure the scope and report options.

SOURCE: https://github.com/metosin/malli/blob/master/docs/function-schemas.md#_snippet_39

LANGUAGE: clojure
CODE:
```
(mi/instrument!
 {:filters [;; everything from user ns
            (mi/-filter-ns 'user)
            ;; ... and some vars
            (mi/-filter-var #{#'power})
            ;; all other vars with :always-validate meta
            (mi/-filter-var #(-> % meta :always-validate))]
  ;; scope
  :scope #{:input :output}
  ;; just print
  :report println})

(power 6)
; =prints=> :malli.core/invalid-output {:output [:int {:max 6}], :value 36, :args [6], :schema [:=> [:cat :int] [:int {:max 6}]]}
; => 36
```

----------------------------------------

TITLE: Validating with Vector Syntax
DESCRIPTION: Demonstrates validating values directly using Malli's vector syntax. Examples include validating an integer, a string, a specific value, and an enum.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_5

LANGUAGE: Clojure
CODE:
```
(m/validate :int 1)
; => true
```

----------------------------------------

TITLE: Custom Transformer for Dependent String Schema
DESCRIPTION: Demonstrates using a custom transformer with the dependent string schema. This allows for more control over the encoding and decoding process, avoiding additional encoding/decoding steps performed by the default `string-transformer`.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_14

LANGUAGE: clojure
CODE:
```
(def schema [:multi {:dispatch first
                     :decode/my-custom #(str/split % #"/")
                     :encode/my-custom #(str/join "/" %)}
             ["domain" [:tuple [:= "domain"] domain]]
             ["ip" [:tuple [:= "ip"] ipv4]]])

(def decode (m/decoder schema (mt/transformer {:name :my-custom})))

(decode "ip/127.0.0.1")
; => ["ip" "127.0.0.1"]
```

----------------------------------------

TITLE: Normalizing Schema Properties with Malli
DESCRIPTION: This function recursively walks a Malli schema and replaces the properties of each schema form with `nil`. It handles vector-based schema forms by reconstructing them with the schema type, properties, and children.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_5

LANGUAGE: clojure
CODE:
```
(require '[malli.core :as m])

(defn normalize-properties [?schema]
  (m/walk
    ?schema
    (fn [schema _ children _]
      (if (vector? (m/form schema))
        (into [(m/type schema) (m/properties schema)] children)
        (m/form schema)))))

(normalize-properties
  [:map
   [:x int?]
   [:y [:tuple int? int?]]
   [:z [:set [:map [:x [:enum 1 2 3]]]]]])
```

----------------------------------------

TITLE: Validating Vector Collections with Malli
DESCRIPTION: Demonstrates how to use `:vector` to validate homogeneous Clojure vectors using Malli. It shows examples with vectors and lists of integers.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_37

LANGUAGE: clojure
CODE:
```
(m/validate [:vector int?] [1 2 3])
;; => true

(m/validate [:vector int?] (list 1 2 3))
;; => false
```

----------------------------------------

TITLE: Validating Tuple Collections with Malli
DESCRIPTION: Demonstrates how to use `:tuple` to validate fixed-length Clojure vectors of heterogeneous elements using Malli. It shows an example with a keyword, string, and number.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_38

LANGUAGE: clojure
CODE:
```
(m/validate [:tuple keyword? string? number?] [:bing "bang" 42])
;; => true
```

----------------------------------------

TITLE: Inferring Schemas with Type Hints
DESCRIPTION: This snippet demonstrates how to use type hints within the destructuring syntax to create a more specific Malli schema. It uses the same `infer` function as the previous example but includes type annotations.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_144

LANGUAGE: Clojure
CODE:
```
(infer '[a :- :int, b :- :string & cs :- [:* :boolean]])
; => [:cat :int :string [:* :boolean]]
```

----------------------------------------

TITLE: Validating Sequential Collections with Malli
DESCRIPTION: Demonstrates how to use `:sequential` to validate homogeneous sequential Clojure collections using Malli. It shows examples with lists and vectors of integers and strings.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_28

LANGUAGE: clojure
CODE:
```
(m/validate [:sequential any?] (list "this" 'is :number 42))
;; => true

(m/validate [:sequential int?] [42 105])
;; => true

(m/validate [:sequential int?] #{42 105})
;; => false
```

----------------------------------------

TITLE: Validating Repetitions with Malli
DESCRIPTION: Demonstrates how to use `:?`, `:*`, `:++`, and `:repeat` for validating repetitions in Malli schemas. It shows examples of validating sequences with optional, zero-or-more, one-or-more, and specific range repetitions of integers.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_31

LANGUAGE: clojure
CODE:
```
(m/validate [:? int?] []) ; => true
(m/validate [:? int?] [1]) ; => true
(m/validate [:? int?] [1 2]) ; => false

(m/validate [:* int?] []) ; => true
(m/validate [:* int?] [1 2 3]) ; => true

(m/validate [:+ int?] []) ; => false
(m/validate [:+ int?] [1]) ; => true
(m/validate [:+ int?] [1 2 3]) ; => true

(m/validate [:repeat {:min 2, :max 4} int?] [1]) ; => false
(m/validate [:repeat {:min 2, :max 4} int?] [1 2]) ; => true
(m/validate [:repeat {:min 2, :max 4} int?] [1 2 3 4]) ; => true (:max is inclusive, as elsewhere in Malli)
(m/validate [:repeat {:min 2, :max 4} int?] [1 2 3 4 5]) ; => false
```

----------------------------------------

TITLE: Defining Dependent String Schema with Multi
DESCRIPTION: Defines a schema for strings with two components separated by '/'. The schema uses `:multi` to dispatch based on the first component ('domain' or 'ip'). Regular expressions are used to validate the second component based on the first. Includes decode and encode functions to transform the string.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_13

LANGUAGE: clojure
CODE:
```
(def domain #"[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+")

(def ipv4 #"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$")

;; a multi schema describing the values as a tuple
;; includes transformation guide to and from a string domain
(def schema [:multi {:dispatch first
                     :decode/string #(str/split % #"/")
                     :encode/string #(str/join "/" %)}
             ["domain" [:tuple [:= "domain"] domain]]
             ["ip" [:tuple [:= "ip"] ipv4]]])

;; define workers
(def validate (m/validator schema))
(def decode (m/decoder schema mt/string-transformer))
(def encode (m/encoder schema mt/string-transformer))

(decode "ip/127.0.0.1")
; => ["ip" "127.0.0.1"]

(-> "ip/127.0.0.1" (decode) (encode))
; => "ip/127.0.0.1"

(map (comp validate decode)
     ["ip/127.0.0.1"
      "ip/111"
      "domain/cnn.com"
      "domain/aa"
      "kika/aaa"])
; => (true false true false false)
```

----------------------------------------

TITLE: Converting Schemas Recursively with schema-mapper
DESCRIPTION: Presents a utility function `schema-mapper` to convert schemas recursively. It uses a mapping function to transform schema types, allowing for custom modifications like changing `:keyword` to `:string` or setting properties on `:int` schemas.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_15

LANGUAGE: clojure
CODE:
```
(defn schema-mapper [m]
  (fn [s] ((or (get m (m/type s)) ;; type mapping
               (get m ::default)  ;; default mapping
               (constantly s))    ;; nop
           s)))

(m/walk
 [:map
  [:id :keyword]
  [:size :int]
  [:tags [:set :keyword]]
  [:sub
   [:map
    [:kw :keyword]
    [:data [:tuple :keyword :int :keyword]]]]]
 (m/schema-walker
  (schema-mapper
    {:keyword (constantly :string)                            ;; :keyword -> :string
     :int #(m/-set-properties % {:gen/elements [1 2]})        ;; custom :int generator
     ::default #(m/-set-properties % %{::type (m/type %)})})))
;[:map {::type :map}
; [:id :string]
; [:size [:int {:gen/elements [1 2 3]}]]
; [:tags [:set {::type :set} :string]]
; [:sub [:map {::type :map}
;        [:kw :string]
;        [:data [:tuple {::type :tuple} 
;                :string
;                [:int {:gen/elements [1 2 3]}]
;                :string]]]]]
```

----------------------------------------

TITLE: Updating Dependencies in Clojure
DESCRIPTION: This code shows an example of updating a dependency using borkdude/edamame in a Clojure project.  It highlights the version change from 1.3.23 to 1.4.25.

SOURCE: https://github.com/metosin/malli/blob/master/CHANGELOG.md#_snippet_2

LANGUAGE: clojure
CODE:
```
borkdude/edamame 1.3.23 -> 1.4.25
```

----------------------------------------

TITLE: Transforming Proxy Schemas with :merge in Clojure
DESCRIPTION: Decodes an empty map using a `:merge` schema, which transforms as if `m/deref`ed. This example demonstrates how default values are applied during the transformation.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_84

LANGUAGE: clojure
CODE:
```
(m/decode
  [:merge
   [:map [:name [:string {:default "kikka"}]] ]
   [:map [:description {:optional true} [:string {:default "kikka"}]]]]
  {}
  {:registry (merge (mu/schemas) (m/default-schemas))}
  (mt/default-value-transformer {::mt/add-optional-keys true}))
```

----------------------------------------

TITLE: Collecting Inlined Reference Definitions from Schemas in Malli
DESCRIPTION: This snippet defines a function `collect-references` that simplifies Malli schemas by collecting inlined reference definitions. It uses `m/walk` to traverse the schema and an atom to accumulate the registry of references. The function returns a map containing the registry and the simplified schema. It also handles ambiguous references by throwing an error.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_11

LANGUAGE: clojure
CODE:
```
(defn collect-references [schema]
  (let [acc* (atom {})
        ->registry (fn [registry]
                     (->> (for [[k d] registry]
                            (if (seq (rest d))
                              (m/-fail! ::ambiguous-references {:data d})
                              [k (first (keys d))]))
                          (into {})))
        schema (m/walk
                 schema
                 (fn [schema path children _]
                   (let [children (if (= :map (m/type schema)) ;; just maps
                                    (->> children
                                         (mapv (fn [[k p s]]
                                                 ;; we found inlined references
                                                 (if (and (m/-reference? k) (not (m/-reference? s)))
                                                   (do (swap! acc* update-in [k (m/form s)] (fnil conj #{}) (conj path k))
                                                       (if (seq p) [k p] k))
                                                   [k p s]))))
                                    children)
                         ;; accumulated registry, fail on ambiguous refs
                         registry (->registry @acc*)]
                     ;; return simplified schema
                     (m/into-schema
                       (m/-parent schema)
                       (m/-properties schema)
                       children
                       {:registry (mr/composite-registry (m/-registry (m/options schema)) registry)}))))]
    {:registry (->registry @acc*)
     :schema schema}))
```

LANGUAGE: clojure
CODE:
```
(def User
  [:map
   [::id :int]
   [:name :string]
   [::country {:optional true} :string]])
```

LANGUAGE: clojure
CODE:
```
(collect-references User)
```

LANGUAGE: clojure
CODE:
```
(collect-references
  [:map
   [:user/id :int]
   [:child [:map
            [:user/id :string]]]])
```

----------------------------------------

TITLE: Building Malli with tools.build
DESCRIPTION: This command uses the Clojure tools.build to compile and package the Malli project. It requires the tools.build dependency to be configured in the project.

SOURCE: https://github.com/metosin/malli/blob/master/docs/jmh.md#_snippet_0

LANGUAGE: Shell
CODE:
```
clj -T:build all
```

----------------------------------------

TITLE: Dereferencing Schema Recursively in Clojure
DESCRIPTION: Demonstrates how to recursively dereference a schema to get the values using `m/deref-recursive`.

SOURCE: https://github.com/metosin/malli/blob/master/docs/reusable-schemas.md#_snippet_5

LANGUAGE: Clojure
CODE:
```
(m/deref-recursive ::user)
;[:map
; [:id :uuid]
; [:name :string]
; [:address [:map 
;            [:street :string] 
;            [:lonlat [:tuple :double :double]]]]]
```

----------------------------------------

TITLE: Turning on Instrumentation
DESCRIPTION: This snippet demonstrates how to turn on instrumentation using `malli.instrument/instrument!`. After instrumentation, the schema is enforced, and calling the function with invalid input or output will throw an exception.

SOURCE: https://github.com/metosin/malli/blob/master/docs/function-schemas.md#_snippet_26

LANGUAGE: clojure
CODE:
```
(require '[malli.instrument :as mi])

(mi/instrument!)
```

----------------------------------------

TITLE: Generating Functions from Schema - Clojure
DESCRIPTION: This snippet shows how to generate function implementations based on the `=>plus` schema using `mg/generate`. The generated function checks the arity and arguments at runtime and returns generated values. The example demonstrates how the generated function throws exceptions for invalid arity and input types.

SOURCE: https://github.com/metosin/malli/blob/master/docs/function-schemas.md#_snippet_11

LANGUAGE: clojure
CODE:
```
(def plus-gen (mg/generate =>plus))

(plus-gen 1)
; =throws=> :malli.core/invalid-arity {:arity 1, :arities #{{:min 2, :max 2}}, :args [1], :input [:cat :int :int], :schema [:=> [:cat :int :int] :int]}

(plus-gen 1 "2")
; =throws=> :malli.core/invalid-input {:input [:cat :int :int], :args [1 "2"], :schema [:=> [:cat :int :int] :int]}

(plus-gen 1 2)
; => -1
```

----------------------------------------

TITLE: Bundle size report minimal registry (with cherry)
DESCRIPTION: This command generates a bundle size report for the 'app2-cherry' build using Shadow CLJS with cherry and minimal registry. The report is saved as an HTML file.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_216

LANGUAGE: bash
CODE:
```
npx shadow-cljs run shadow.cljs.build-report app2-cherry /tmp/report.html
```

----------------------------------------

TITLE: Validating with Normal Predicate Schemas - Clojure
DESCRIPTION: This snippet shows that normal predicate schemas are not registered in the custom registry created in the previous example, resulting in a syntax error when trying to validate against them.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_171

LANGUAGE: clojure
CODE:
```
(m/validate pos-int? 123 {:registry registry})
; Syntax error (ExceptionInfo) compiling
; :malli.core/invalid-schema {:schema pos-int?}
```

----------------------------------------

TITLE: Using :maybe Schema for Optional Values in Malli
DESCRIPTION: This snippet demonstrates how to use the `:maybe` schema in Malli to allow a value to be either a specific type or `nil`. It shows examples of validating a string or `nil` using `[:maybe string?]`.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_44

LANGUAGE: clojure
CODE:
```
(m/validate [:maybe string?] "bingo")
;; => true

(m/validate [:maybe string?] nil)
;; => true

(m/validate [:maybe string?] :bingo)
;; => false
```

----------------------------------------

TITLE: Default Value Transformer with Function
DESCRIPTION: This code defines a custom Malli transformer that calculates default values using a provided function. It compiles a map of default values based on the `:default-fn` property in the schema and applies these defaults during decoding if a key is missing in the input data. It uses `m/eval` to evaluate the function.

SOURCE: https://github.com/metosin/malli/blob/master/docs/tips.md#_snippet_6

LANGUAGE: clojure
CODE:
```
(defn default-fn-value-transformer
  ([]
   (default-fn-value-transformer nil))
  ([{:keys [key] :or {key :default-fn}}]
   (let [add-defaults
         {:compile
          (fn [schema _]
            (let [->k-default (fn [[k {default key :keys [optional]} v]]
                                (when-not optional
                                  (when-some [default (or default (some-> v m/properties key))]
                                    [k default])))
                  defaults    (into {} (keep ->k-default) (m/children schema))
                  exercise    (fn [x defaults]
                                (reduce-kv (fn [acc k v]
                                             ; the key difference compare to default-value-transformer
                                             ; we evaluate v instead of just passing it
                                             (if-not (contains? x k)
                                               (-> (assoc acc k ((m/eval v) x))
                                                   (try (catch Exception _ acc)))
                                               acc))
                                           x defaults))]
              (when (seq defaults)
                (fn [x] (if (map? x) (exercise x defaults) x)))))}]
     (mt/transformer
      {:decoders {:map add-defaults}
       :encoders {:map add-defaults}}))))
```

----------------------------------------

TITLE: Transforming Homogenous Enum with String Transformer in Clojure
DESCRIPTION: Decodes a string value against an enum schema using the string transformer. This example demonstrates automatic type detection for keywords.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_74

LANGUAGE: clojure
CODE:
```
(m/decode [:enum :kikka :kukka] "kukka" mt/string-transformer)
```

----------------------------------------

TITLE: Using Options with Malli Lite Syntax
DESCRIPTION: This snippet demonstrates how to use options with Malli's lite syntax by binding a dynamic `l/*options*` Var. This allows you to customize the schema definition process, such as by providing a custom registry.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_190

LANGUAGE: Clojure
CODE:
```
(binding [l/*options* {:registry (merge
                                  (m/default-schemas)
                                  {:user/id :int})}]
  (l/schema {:id (l/maybe :user/id)
             :child {:id :user/id}}))
```

----------------------------------------

TITLE: Prebuilding validator, decoder, and explainer for performance
DESCRIPTION: Demonstrates prebuilding the validator, decoder, and explainer functions for improved performance. This is especially useful when the same schema is used multiple times.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_89

LANGUAGE: clojure
CODE:
```
(def validate-Tags (m/validator Tags))
(def decode-Tags (m/decoder Tags mt/json-transformer))
(-> (jsonista.core/read-value "{\"tags\":[\"bar\",\"quux\"]}"
                              jsonista.core/keyword-keys-object-mapper)
    decode-Tags
    validate-Tags)
; => true
```

----------------------------------------

TITLE: Decomplecting Maps, Keys, and Values in Clojure
DESCRIPTION: Demonstrates how to decomplect maps, keys, and values using the global registry.  This example resets the registry and registers schemas for street, latlon, address, id, name, and user.

SOURCE: https://github.com/metosin/malli/blob/master/docs/reusable-schemas.md#_snippet_6

LANGUAGE: Clojure
CODE:
```
;; (╯°□°)╯︵ ┻━┻
(reset! *registry {})

(register! ::street :string)
(register! ::latlon [:tuple :double :double])
(register! ::address [:map ::street ::latlon])

(register! ::id :uuid)
(register! ::name :string)
(register! ::user [:map ::id ::name ::address])

(m/deref-recursive ::user)
;[:map
; [:user/id :uuid]
; [:user/name :string]
; [:user/address [:map 
;                 [:user/street :string] 
;                 [:user/latlon [:tuple :double :double]]]]]

;; data has a different shape now
(m/validate ::user {::id (random-uuid)
                    ::name "Maija"
                    ::address {::street "Kuninkaankatu 13"
                               ::latlon [61.5014816, 23.7678986]}})
; => true
```

----------------------------------------

TITLE: Seqable vs Every Schema Validation with Large Collections in Clojure
DESCRIPTION: This example highlights the difference between `:seqable` and `:every` schemas when dealing with large, uncounted, and unindexed collections. `:seqable` validates the entire collection, while `:every` checks only a limited number of elements. In this case, `:seqable` fails because the collection contains a `nil` value, while `:every` passes because it doesn't check all elements.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_27

LANGUAGE: clojure
CODE:
```
(m/validate [:seqable :int] (concat (range 1000) [nil]))
;=> false
(m/validate [:every :int] (concat (range 1000) [nil]))
;=> true
```

----------------------------------------

TITLE: Explaining Named Subsequences with Malli
DESCRIPTION: Demonstrates how to use `:catn` and `:altn` to name subsequences and alternatives in Malli schemas, and how these names appear in explain output. It contrasts this with the numeric indices used by `:cat` and `:alt`.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_32

LANGUAGE: clojure
CODE:
```
(m/explain
  [:* [:catn [:prop string?] [:val [:altn [:s string?] [:b boolean?]]]]]
  ["-server" "foo" "-verbose" 11 "-user" "joe"])
;; => {:schema [:* [:map [:prop string?] [:val [:map [:s string?] [:b boolean?]]]]],
;;     :value ["-server" "foo" "-verbose" 11 "-user" "joe"],
;;     :errors ({:path [0 :val :s], :in [3], :schema string?, :value 11}
;;              {:path [0 :val :b], :in [3], :schema boolean?, :value 11})}
```

----------------------------------------

TITLE: Accessing Function Metadata in ClojureScript
DESCRIPTION: This example shows how to explicitly access function metadata in ClojureScript using `(meta (var ...))`. Function metadata is excluded by default unless explicitly accessed.

SOURCE: https://github.com/metosin/malli/blob/master/docs/clojurescript-function-instrumentation.md#_snippet_5

LANGUAGE: Clojure
CODE:
```
(meta (var com.my-org.some.ns/a-fn))
```

----------------------------------------

TITLE: Automatic Negation with :error/message
DESCRIPTION: This snippet demonstrates how Malli automatically negates error messages defined with `:error/message` for `:not` schemas in the `:en` locale. If the message starts with 'should' or 'should not', they are swapped automatically.

SOURCE: https://github.com/metosin/malli/blob/master/README.md#_snippet_50

LANGUAGE: clojure
CODE:
```
(me/humanize
  (m/explain
    [:not
     [:fn {:error/message {:en "should be a multiple of 3"}}
      #(= 0 (mod % 3))]]
    3))
; => ["should not be a multiple of 3"]
```
