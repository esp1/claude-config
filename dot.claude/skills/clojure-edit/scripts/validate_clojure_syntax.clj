#!/usr/bin/env bb
;; Validates Clojure file syntax after edits
;; Reads file path from stdin JSON (PostToolUse hook input)
;; Exit 0 = valid, Exit 2 = invalid (blocks with error message)
;; Uses rewrite-clj to parse ALL forms in the file, not just the first

(require '[cheshire.core :as json]
         '[clojure.java.io :as io])

(let [input (json/parse-stream *in* true)
      file-path (get-in input [:tool_input :file_path] "")]
  (when (re-matches #".*\.(clj|cljs|cljc|edn|bb|cljd)$" file-path)
    (try
      (let [content (slurp file-path)
            reader (java.io.PushbackReader. (java.io.StringReader. content))]
        ;; Read ALL forms in the file, not just the first
        (loop []
          (let [form (read {:eof ::eof} reader)]
            (when-not (= form ::eof)
              (recur)))))
      ;; Valid - exit silently
      (catch Exception e
        ;; Invalid - exit 2 with error to stderr
        (binding [*out* *err*]
          (println "SYNTAX ERROR: Unbalanced parens or invalid syntax in" file-path)
          (println (.getMessage e)))
        (System/exit 2)))))
