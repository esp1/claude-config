#!/usr/bin/env bb
;; Validates Clojure file syntax after edits
;; Reads file path from stdin JSON (PostToolUse hook input)
;; Exit 0 = valid, Exit 2 = invalid (blocks with error message)

(require '[cheshire.core :as json]
         '[clojure.java.io :as io])

(let [input (json/parse-stream *in* true)
      file-path (get-in input [:tool_input :file_path] "")]
  (when (re-matches #".*\.(clj|cljs|cljc|edn|bb|cljd)$" file-path)
    (try
      (read-string (slurp file-path))
      ;; Valid - exit silently
      (catch Exception e
        ;; Invalid - exit 2 with error to stderr
        (binding [*out* *err*]
          (println "SYNTAX ERROR: Unbalanced parens or invalid syntax in" file-path)
          (println (.getMessage e)))
        (System/exit 2)))))
