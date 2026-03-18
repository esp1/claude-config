# Web Application Setup

Configuration for Clojure web applications using Ring and FSR (filesystem router).

> **Directory structure**: See `project-structure.md` for standard layouts.
> Web apps use single-platform (`src/`) structure; PWAs use multi-platform (`src/clj`, `src/cljs`, `src/cljc`).

## Web Application (Ring + FSR)

### Dependencies (deps.edn)

```clojure
{:paths ["src"]

 ;; Get latest versions and full 40-char SHAs:
 ;; git ls-remote https://github.com/esp1/fsr HEAD
 :deps {ring/ring-core {:mvn/version "LATEST"}
        ring/ring-jetty-adapter {:mvn/version "LATEST"}
        io.github.esp1/fsr {:git/url "https://github.com/esp1/fsr"
                            :git/sha "FULL-40-CHAR-SHA"}}

 :aliases
 {:dev {:extra-paths ["dev" "test"]
        :extra-deps {metosin/malli {:mvn/version "LATEST"}
                     org.clojure/tools.namespace {:mvn/version "LATEST"}}}
  :run {:main-opts ["-m" "org.my-app.server"]}}}
```

### Server (src/org/my_app/server.clj)

```clojure
(ns org.my-app.server
  (:require [ring.adapter.jetty :as jetty]
            [esp1.fsr.ring :refer [wrap-fs-router]]))

(defn not-found-handler [_request]
  {:status 404 :body "Not Found"})

(defn create-app []
  (-> not-found-handler
      (wrap-fs-router "src/org/my_app/routes")))  ; Filesystem path, not classpath

(defn -main [& _args]
  (jetty/run-jetty (create-app) {:port 3000}))
```

### Route Files

FSR maps filesystem paths to URLs. Use `:endpoint/http` metadata with **quoted symbols**.

```clojure
;; src/org/my_app/routes/index.clj → GET /
(ns org.my-app.routes.index
  {:endpoint/http {:get 'handle-get}})

(defn handle-get [_request]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body "<h1>Welcome</h1>"})
```

```clojure
;; src/org/my_app/routes/users/$id.clj → GET /users/:id
(ns org.my-app.routes.users.$id
  {:endpoint/http {:get 'handle-get}})

(defn handle-get [request]
  (let [id (get-in request [:path-params :id])]
    {:status 200 :body (str "User: " id)}))
```

### bb.edn Tasks

```clojure
{:tasks
 {dev {:doc "Start dev server" :task (clojure "-M:dev:run")}
  test {:doc "Run tests" :task (clojure "-M:dev" "-m" "cognitect.test-runner")}}}
```

---

## Progressive Web App (PWA)

PWAs use multi-platform structure to share rendering code between server and client.

### Additional Dependencies

```clojure
;; Add to deps.edn :deps
io.github.cjohansen/replicant {:git/url "https://github.com/cjohansen/replicant"
                               :git/sha "FULL-40-CHAR-SHA"}
```

### Squint Setup

**package.json:**
```json
{"name": "my-pwa", "private": true, "type": "module",
 "dependencies": {"squint-cljs": "latest"}}
```

**squint.edn:**
```clojure
{:paths ["src/cljs" "src/cljc"]
 :output-dir "public/js"
 :extension "mjs"
 :import-maps {"squint-cljs/core.js" "https://cdn.jsdelivr.net/npm/squint-cljs@0.8.131/src/squint/core.js"
               "reagami" "https://esm.sh/reagami@0.0.6"}}
```

### Shared Views (src/cljc/org/my_pwa/views.cljc)

Hiccup components that render on both server (Replicant) and client (Reagami):

```clojure
(ns org.my-pwa.views)

(defn page-shell [& body]
  [:html {:lang "en"}
   [:head
    [:meta {:charset "utf-8"}]
    [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
    [:title "My PWA"]
    [:link {:rel "manifest" :href "/manifest.json"}]]
   [:body
    [:div#app body]
    [:script {:type "module" :src "/js/org/my_pwa/app.mjs"}]]])

(defn home-content [] [:div [:h1 "Welcome"]])
(defn offline-content [] [:div [:h1 "Offline"]])
```

### Route with Replicant (src/clj/org/my_pwa/routes/index.clj)

```clojure
(ns org.my-pwa.routes.index
  {:endpoint/http {:get 'handle-get}}
  (:require [replicant.string :as rs]
            [org.my-pwa.views :as views]))

(defn handle-get [_request]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body (str "<!DOCTYPE html>"
              (rs/render (views/page-shell (views/home-content))))})
```

**Tip:** Use `:innerHTML` for unescaped content:
```clojure
[:script {:type "application/json" :innerHTML "{\"key\": \"value\"}"}]
```

### Client App (src/cljs/org/my_pwa/app.cljs)

```clojure
(ns org.my-pwa.app
  (:require ["reagami" :as r]
            [org.my-pwa.views :as views]))

(defn register-sw []
  (when (exists? js/navigator.serviceWorker)
    (js/navigator.serviceWorker.register "/js/org/my_pwa/sw.mjs" #js {:type "module"})))

(defn render-offline []
  (when-let [el (js/document.getElementById "app")]
    (r/render el (views/offline-content))))

(defn init [] (register-sw))

(if (= js/document.readyState "loading")
  (js/document.addEventListener "DOMContentLoaded" init)
  (init))
```

### Service Worker (src/cljs/org/my_pwa/sw.cljs)

```clojure
(ns org.my-pwa.sw)

(def CACHE_NAME "my-pwa-v1")
(def URLS_TO_CACHE #js ["/" "/manifest.json" "/js/org/my_pwa/app.mjs" "/js/org/my_pwa/views.mjs"])

(defn handle-install [event]
  (.waitUntil event
    (-> (js/caches.open CACHE_NAME)
        (.then #(.addAll % URLS_TO_CACHE)))))

(defn handle-fetch [event]
  (.respondWith event
    (-> (js/caches.match (.-request event))
        (.then #(or % (js/fetch (.-request event)))))))

(js/self.addEventListener "install" handle-install)
(js/self.addEventListener "fetch" handle-fetch)
```

### Server with Static Files

```clojure
(ns org.my-pwa.server
  (:require [ring.adapter.jetty :as jetty]
            [ring.middleware.file :refer [wrap-file]]
            [ring.middleware.content-type :refer [wrap-content-type]]
            [esp1.fsr.ring :refer [wrap-fs-router]]))

(defn create-app []
  (-> (constantly {:status 404 :body "Not Found"})
      (wrap-fs-router "src/clj/org/my_pwa/routes")
      (wrap-file "public")
      wrap-content-type))
```

**Middleware order:** `wrap-file` after `wrap-fs-router` means static files are checked first.

### bb.edn for PWA

```clojure
{:paths ["src/clj" "src/cljc"]
 :tasks
 {:requires ([babashka.process :as p])
  build:js {:task (p/shell "npx squint compile")}
  dev {:depends [build:js] :task (clojure "-M:dev:run")}}}
```

### .gitignore additions

```
node_modules/
public/js/
```

---

## Checklists

### Web Application
- [ ] Add Ring + FSR to deps.edn
- [ ] Create server.clj with `wrap-fs-router`
- [ ] Create routes/ directory with index.clj
- [ ] Add `:run` alias and `dev` task
- [ ] Test with `bb dev`

### PWA (extends above)
- [ ] Switch to multi-platform paths (`src/clj`, `src/cljs`, `src/cljc`)
- [ ] Add Replicant to deps.edn
- [ ] Create package.json + squint.edn
- [ ] Create shared views in src/cljc/
- [ ] Create app.cljs + sw.cljs in src/cljs/
- [ ] Add `wrap-file "public"` middleware
- [ ] Create public/manifest.json
- [ ] Run `npm install && bb dev`
