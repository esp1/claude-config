(ns acme.my-app.core-test
  "Tests for core functionality.

   Demonstrates:
   - Malli registry fixture setup
   - Property-based testing with test.check and Malli generators
   - Integration tests with temp directory cleanup
   - Unit tests for edge cases"
  (:require [clojure.test :refer [deftest is testing use-fixtures]]
            [clojure.test.check.clojure-test :refer [defspec]]
            [clojure.test.check.generators :as gen]
            [clojure.test.check.properties :as prop]
            [malli.core :as m]
            [malli.dev :as mdev]
            [malli.generator :as mg]
            [malli.registry :as mr]
            [clojure.java.io :as io]
            [acme.my-app.core :as core]
            [acme.my-app.schema :as app-schema])
  (:import [java.nio.file Files]
           [java.nio.file.attribute FileAttribute]))

;; ============================================================
;; Fixtures
;; ============================================================

;; Malli registry fixture — register only what this namespace needs
(use-fixtures :once
  (fn [f]
    (mr/set-default-registry!
     (merge
      (m/comparator-schemas)
      (m/type-schemas)
      (m/sequence-schemas)
      (m/base-schemas)
      (app-schema/all-schemas)))
    (mdev/start!)  ;; Enable dev-mode instrumentation
    (f)
    (mdev/stop!)
    (mr/set-default-registry! m/default-registry)))

;; Thread-safe temp directory for integration tests
(def temp-output-dir
  (str (Files/createTempDirectory "core-test-" (into-array FileAttribute []))))

(use-fixtures :once
  (fn [f]
    (try
      (f)
      (finally
        (when (.exists (io/file temp-output-dir))
          (doseq [file (reverse (file-seq (io/file temp-output-dir)))]
            (.delete file)))))))

;; ============================================================
;; Property-Based Tests (preferred approach)
;; ============================================================

;; Using test.check — provides shrinking and seed reporting
(defspec process-data-roundtrip 100
  (prop/for-all [input gen/string-alphanumeric]
    (let [result (core/process-data input)]
      ;; Test properties, not specific values
      (and (string? result)
           (<= (count result) (* 2 (count input)))))))

;; Using Malli generators — when schema already defines valid inputs
(deftest process-request-properties
  (testing "process-request handles all valid inputs"
    (let [args-schema (-> #'core/process-request meta :malli/schema second)
          args-gen (mg/generator args-schema)]
      (dotimes [_ 100]
        (let [[ctx] (gen/generate args-gen)
              result (core/process-request ctx)]
          (is (map? result) "Result should always be a map")
          (is (contains? result :status) "Result should have :status"))))))

;; ============================================================
;; Unit Tests (for specific edge cases)
;; ============================================================

(deftest process-data-edge-cases
  (testing "empty input"
    (is (= "" (core/process-data ""))))

  (testing "nil handling"
    (is (nil? (core/process-data nil)))))

;; ============================================================
;; Integration Tests
;; ============================================================

(deftest full-pipeline-test
  (testing "Complete processing pipeline"
    (let [input {:data "test-value"}
          output-file (str temp-output-dir "/output.edn")]

      ;; Process
      (core/process-and-write input output-file)

      ;; Verify file created
      (is (.exists (io/file output-file)))

      ;; Load and verify
      (let [loaded (read-string (slurp output-file))]
        (is (= (:data input) (:data loaded)))))))
