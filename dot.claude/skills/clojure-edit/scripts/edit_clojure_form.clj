#!/usr/bin/env bb

;; Edit Clojure forms structurally
;; Inspired by clojure-mcp's form-aware editing
;;
;; Usage:
;;   ./edit_clojure_form.clj --file <file> --name <name> --operation <op> [options]
;;
;; Operations:
;;   replace --new-form <form>       Replace entire form
;;   insert-before --new-form <form> Insert before matched form
;;   insert-after --new-form <form>  Insert after matched form
;;
;; Options:
;;   --name <name>                   Name of form to edit
;;   --form-type <type>              Type of form (defn, def, defmethod, etc.)
;;   --output <file>                 Output file (default: overwrite input)
;;   --dry-run                       Print changes without writing

(require '[rewrite-clj.zip :as z]
         '[rewrite-clj.node :as n]
         '[rewrite-clj.parser :as p])

(defn find-form-by-name
  "Find a top-level form by name and optionally type"
  [zloc target-name target-type]
  (loop [loc zloc]
    (if-not loc
      nil
      (if (z/list? loc)
        (let [first-child (z/down loc)]
          (when first-child
            (let [form-type (z/sexpr first-child)
                  name-loc (z/right first-child)]
              (if (and name-loc
                       (= target-name (str (z/sexpr name-loc)))
                       (or (not target-type)
                           (= (keyword target-type) form-type)))
                loc
                (recur (z/right loc))))))
        (recur (z/right loc))))))

(defn replace-form
  "Replace a form with new content"
  [zloc new-form-str]
  (let [new-node (p/parse-string new-form-str)]
    (z/replace zloc new-node)))

(defn insert-before-form
  "Insert new form before the target form"
  [zloc new-form-str]
  (let [new-form-with-spacing (str new-form-str "\n\n")
        new-node (p/parse-string-all new-form-with-spacing)]
    (z/insert-left zloc new-node)))

(defn insert-after-form
  "Insert new form after the target form"
  [zloc new-form-str]
  (let [new-form-with-spacing (str "\n\n" new-form-str)
        new-node (p/parse-string-all new-form-with-spacing)]
    (z/insert-right zloc new-node)))

(defn edit-clojure-file
  "Edit a Clojure file by finding and modifying a form"
  [file-path {:keys [name form-type operation new-form]}]
  (try
    (let [zloc (z/of-file file-path)
          target-loc (find-form-by-name zloc name form-type)]
      (if-not target-loc
        {:error (str "Form not found: " name
                     (when form-type (str " (type: " form-type ")")))}
        (let [edited-loc (case operation
                           "replace" (replace-form target-loc new-form)
                           "insert-before" (insert-before-form target-loc new-form)
                           "insert-after" (insert-after-form target-loc new-form)
                           (throw (ex-info "Unknown operation" {:operation operation})))
              root (z/root edited-loc)]
          {:success true
           :content (n/string root)})))
    (catch Exception e
      {:error (str "Exception during edit: " (.getMessage e))
       :exception e})))

(defn -main [& args]
  (let [args-set (set args)
        dry-run? (contains? args-set "--dry-run")
        key-value-args (remove #{"--dry-run"} args)
        options (apply hash-map key-value-args)
        file (get options "--file")
        name (get options "--name")
        form-type (get options "--form-type")
        operation (get options "--operation")
        new-form (get options "--new-form")
        output (get options "--output" file)]

    (when-not (and file name operation new-form)
      (println "Usage: bb edit_clojure_form.clj --file <file> --name <name> --operation <op> --new-form <form>")
      (println "\nOperations:")
      (println "  replace         Replace entire form")
      (println "  insert-before   Insert before matched form")
      (println "  insert-after    Insert after matched form")
      (println "\nOptions:")
      (println "  --form-type <type>  Type of form (defn, def, defmethod, etc.)")
      (println "  --output <file>     Output file (default: overwrite input)")
      (println "  --dry-run          Print changes without writing")
      (System/exit 1))

    (try
      (let [result (edit-clojure-file file
                                      {:name name
                                       :form-type form-type
                                       :operation operation
                                       :new-form new-form})]
        (if (:error result)
          (do
            (binding [*out* *err*]
              (println "Error:" (:error result))
              (when-let [ex (:exception result)]
                (println "\nStack trace:")
                (.printStackTrace ex)))
            (System/exit 1))
          (if dry-run?
            (println (:content result))
            (do
              (spit output (:content result))
              (println "Successfully edited" output)))))
      (catch Exception e
        (binding [*out* *err*]
          (println "Unexpected error:" (.getMessage e))
          (println "\nStack trace:")
          (.printStackTrace e))
        (System/exit 1)))))

(when (= *file* (System/getProperty "babashka.file"))
  (apply -main *command-line-args*))
