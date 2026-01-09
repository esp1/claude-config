#!/usr/bin/env bb

;; Inspect Clojure namespace for REPL-driven development
;; Shows available functions, their signatures, and docstrings
;;
;; Usage:
;;   ./inspect_namespace.clj <file> [options]
;;
;; Options:
;;   --public-only     Show only public vars (default: all)
;;   --with-private    Include private vars
;;   --names-only      Show only function names
;;   --summary         Show summary statistics

(require '[rewrite-clj.zip :as z]
         '[clojure.string :as str])

(defn extract-docstring
  "Extract docstring from a defn form"
  [zloc]
  (when (z/list? zloc)
    (loop [loc (-> zloc z/down z/right z/right)] ; Skip 'defn' and name
      (when loc
        (let [node (z/node loc)]
          (cond
            (= :token (-> node meta :tag))
            (let [value (z/sexpr loc)]
              (when (string? value)
                value))

            :else (recur (z/right loc))))))))

(defn extract-args
  "Extract argument vector from a defn form"
  [zloc]
  (when (z/list? zloc)
    (loop [loc (-> zloc z/down z/right z/right)] ; Skip 'defn' and name
      (when loc
        (cond
          (z/vector? loc) (z/sexpr loc)
          :else (recur (z/right loc)))))))

(defn form-visibility
  "Determine if a form is public or private"
  [zloc]
  (when (z/list? zloc)
    (let [form-type (-> zloc z/down z/sexpr)]
      (cond
        (= 'defn- form-type) :private
        (= 'defn form-type) :public
        (= 'def form-type) :public
        :else :other))))

(defn extract-namespace-info
  "Extract namespace declaration and metadata"
  [zloc]
  (loop [loc zloc]
    (when loc
      (if (and (z/list? loc)
               (= 'ns (-> loc z/down z/sexpr)))
        {:ns-name (-> loc z/down z/right z/sexpr)
         :ns-doc (extract-docstring loc)}
        (recur (z/right loc))))))

(defn extract-all-forms
  "Extract all top-level forms with their metadata"
  [file-path {:keys [public-only with-private]}]
  (let [zloc (z/of-file file-path)
        ns-info (extract-namespace-info zloc)]
    (loop [loc zloc
           results []]
      (if-not loc
        {:namespace ns-info
         :forms results}
        (if (z/list? loc)
          (let [form-type (-> loc z/down z/sexpr)
                form-name (-> loc z/down z/right z/sexpr)
                visibility (form-visibility loc)
                include? (cond
                          with-private true
                          public-only (= :public visibility)
                          :else (not= :private visibility))]
            (recur (z/right loc)
                   (if (and include?
                            (or (= 'defn form-type)
                                (= 'defn- form-type)
                                (= 'def form-type)
                                (= 'defmethod form-type)))
                     (conj results
                           {:type form-type
                            :name form-name
                            :visibility visibility
                            :args (extract-args loc)
                            :doc (extract-docstring loc)
                            :line (or (some-> loc z/node meta :row) 0)})
                     results)))
          (recur (z/right loc) results))))))

(defn format-function
  "Format a function for display"
  [{:keys [type name visibility args doc line]} names-only?]
  (if names-only?
    (str name)
    (let [vis-str (when (= :private visibility) "[private] ")
          type-str (str "[" type "] ")
          sig-str (if args
                   (str "(" name " " (str/join " " args) ")")
                   (str name))
          doc-str (when doc (str "\n  " (str/replace doc #"\n" "\n  ")))]
      (str "Line " line ": " vis-str type-str sig-str doc-str))))

(defn format-summary
  "Format summary statistics"
  [forms]
  (let [by-type (group-by :type forms)
        by-visibility (group-by :visibility forms)
        total (count forms)
        public (count (get by-visibility :public []))
        private (count (get by-visibility :private []))]
    (str "Total forms: " total "\n"
         "Public: " public "\n"
         "Private: " private "\n"
         "By type:\n"
         (str/join "\n"
                   (for [[type items] by-type]
                     (str "  " type ": " (count items)))))))

(defn -main [& args]
  (let [[file & opts] args
        options (set opts)
        params {:public-only (or (contains? options "--public-only")
                                (not (contains? options "--with-private")))
                :with-private (contains? options "--with-private")}
        names-only? (contains? options "--names-only")
        summary? (contains? options "--summary")]

    (if-not file
      (do
        (println "Usage: bb inspect_namespace.clj <file> [options]")
        (println "Options:")
        (println "  --public-only     Show only public vars (default)")
        (println "  --with-private    Include private vars")
        (println "  --names-only      Show only function names")
        (println "  --summary         Show summary statistics")
        (System/exit 1))
      (try
        (let [{:keys [namespace forms]} (extract-all-forms file params)]
          (when namespace
            (println "Namespace:" (:ns-name namespace))
            (when-let [doc (:ns-doc namespace)]
              (println "Doc:" doc))
            (println))

          (if summary?
            (println (format-summary forms))
            (doseq [form forms]
              (println (format-function form names-only?))
              (println))))
        (catch Exception e
          (println "Error:" (.getMessage e))
          (System/exit 1))))))

(when (= *file* (System/getProperty "babashka.file"))
  (apply -main *command-line-args*))
