(ns myapp.core
  (:require [ring.adapter.jetty :as jetty]
            [myapp.routes :as routes]
            [myapp.db :as db]))

(defn start-server
  "Start the HTTP server on the given port."
  [{:keys [port] :or {port 3000}}]
  (db/init-pool!)
  (jetty/run-jetty (routes/app) {:port port :join? false}))

(defn -main [& _args]
  (start-server {:port (Integer/parseInt (or (System/getenv "PORT") "3000"))}))
