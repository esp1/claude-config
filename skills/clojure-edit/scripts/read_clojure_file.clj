#!/usr/bin/env bb

;; Read Clojure files with pattern-based introspection
;;
;; This script uses the bundled babashka binary and can be run directly:
;;   ./read_clojure_file.clj <args>
;;
;; Inspired by clojure-mcp's pattern-based file reading
;;
;; Usage:
;;   ./read_clojure_file.clj <file> [options]
;;
;; Options:
;;   --name-pattern <pattern>     Find forms by name (regex)
;;   --collapsed                  Show only signatures, not bodies
;;   --content-pattern <pattern>  Search within content
;;   --form-type <type>           Filter by form type (defn, defmethod, def, etc.)

(require '[rewrite-clj.zip :as z]
         '[rewrite-clj.node :as n]
         '[clojure.string :as str]
         '[clojure.java.io :as io])

(defn form-name
  "Extract name from a form node"
  [zloc]
  (when (z/list? zloc)
    (let [first-child (z/down zloc)]
      (when first-child
        (let [form-type (z/sexpr first-child)
              name-loc (z/right first-child)]
          (when name-loc
            {:type form-type
             :name (z/sexpr name-loc)}))))))

(defn form-signature
  "Get collapsed signature of a form (no body)"
  [zloc]
  (when (z/list? zloc)
    (let [nodes (loop [loc (z/down zloc)
                       result []]
                  (if-not loc
                    result
                    (let [node (z/node loc)]
                      ;; For defn/defmethod, include name, args, but not body
                      (if (and (seq result) (>= (count result) 2))
                        ;; Skip to args list if present
                        (if (= :vector (n/tag node))
                          (recur nil (conj result node))
                          (recur (z/right loc) (conj result node)))
                        (recur (z/right loc) (conj result node))))))]
      (when (seq nodes)
        (str "(" (str/join " " (map n/string nodes)) ")")))))

(defn extract-forms
  "Extract top-level forms from file with optional filtering"
  [file-path {:keys [name-pattern form-type collapsed content-pattern]}]
  (let [zloc (z/of-file file-path)
        name-re (when name-pattern (re-pattern name-pattern))
        content-re (when content-pattern (re-pattern content-pattern))]
    (loop [loc zloc
           results []]
      (if-not loc
        results
        (let [form-info (form-name loc)
              form-str (if collapsed
                        (form-signature loc)
                        (z/string loc))
              matches? (and
                        ;; Name pattern check
                        (or (not name-re)
                            (and form-info
                                 (re-find name-re (str (:name form-info)))))
                        ;; Form type check
                        (or (not form-type)
                            (and form-info
                                 (= (keyword form-type) (:type form-info))))
                        ;; Content pattern check
                        (or (not content-re)
                            (re-find content-re form-str)))]
          (recur (z/right loc)
                 (if matches?
                   (conj results {:form form-info
                                  :text form-str
                                  :line (or (some-> loc z/node meta :row) 0)})
                   results)))))))

(defn format-result
  "Format a single result for display"
  [{:keys [form text line]}]
  (let [type-str (when form (str "[" (name (:type form)) "]"))
        name-str (when form (str " " (:name form)))
        line-str (str "Line " line)]
    (str line-str " " type-str name-str "\n" text "\n")))

(defn -main [& args]
  (let [[file & opts] args
        opts-set (set opts)
        key-value-opts (remove #(= "--collapsed" %) opts)
        options (apply hash-map key-value-opts)
        params {:name-pattern (get options "--name-pattern")
                :collapsed (contains? opts-set "--collapsed")
                :content-pattern (get options "--content-pattern")
                :form-type (get options "--form-type")}]
    (if-not file
      (do
        (println "Usage: bb read_clojure_file.clj <file> [options]")
        (println "Options:")
        (println "  --name-pattern <pattern>     Find forms by name (regex)")
        (println "  --collapsed                  Show only signatures, not bodies")
        (println "  --content-pattern <pattern>  Search within content")
        (println "  --form-type <type>           Filter by form type (defn, defmethod, def, etc.)")
        (System/exit 1))
      (try
        (let [results (extract-forms file params)]
          (if (seq results)
            (doseq [result results]
              (println (format-result result)))
            (println "No matching forms found.")))
        (catch Exception e
          (println "Error:" (.getMessage e))
          (System/exit 1))))))

(when (= *file* (System/getProperty "babashka.file"))
  (apply -main *command-line-args*))
