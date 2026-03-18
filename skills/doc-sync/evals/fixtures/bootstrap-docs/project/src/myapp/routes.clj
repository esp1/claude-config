(ns myapp.routes
  (:require [reitit.ring :as ring]
            [myapp.handlers.users :as users]
            [myapp.handlers.auth :as auth]
            [myapp.middleware :as mw]))

(defn app []
  (ring/ring-handler
   (ring/router
    [["/api"
      ["/auth"
       ["/login" {:post auth/login}]
       ["/register" {:post auth/register}]
       ["/refresh" {:post auth/refresh-token}]]
      ["/users" {:middleware [mw/require-auth]}
       ["" {:get users/list-users}]
       ["/:id" {:get users/get-user
                :put users/update-user
                :delete users/delete-user}]]]])))
