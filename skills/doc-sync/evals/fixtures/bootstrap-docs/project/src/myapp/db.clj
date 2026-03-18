(ns myapp.db
  (:require [next.jdbc :as jdbc]
            [next.jdbc.connection :as connection])
  (:import [com.zaxxer.hikari HikariDataSource]))

(defonce ^:private datasource (atom nil))

(defn init-pool!
  "Initialize the HikariCP connection pool."
  []
  (reset! datasource
          (connection/->pool HikariDataSource
                             {:dbtype "postgresql"
                              :dbname (or (System/getenv "DB_NAME") "myapp")
                              :host (or (System/getenv "DB_HOST") "localhost")
                              :port (Integer/parseInt (or (System/getenv "DB_PORT") "5432"))
                              :username (or (System/getenv "DB_USER") "postgres")
                              :password (System/getenv "DB_PASSWORD")})))

(defn ds [] @datasource)

(defn execute! [sql-params]
  (jdbc/execute! (ds) sql-params))

(defn execute-one! [sql-params]
  (jdbc/execute-one! (ds) sql-params))
