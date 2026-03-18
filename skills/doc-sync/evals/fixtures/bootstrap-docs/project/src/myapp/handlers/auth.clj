(ns myapp.handlers.auth
  (:require [myapp.db :as db]
            [buddy.hashers :as hashers]
            [buddy.sign.jwt :as jwt]))

(def ^:private secret (or (System/getenv "JWT_SECRET") "dev-secret"))

(defn register [{:keys [body-params]}]
  (let [{:keys [email password name]} body-params
        hashed (hashers/derive password)]
    (db/execute-one! ["INSERT INTO users (email, password_hash, name) VALUES (?, ?, ?)"
                      email hashed name])
    {:status 201 :body {:message "User registered"}}))

(defn login [{:keys [body-params]}]
  (let [{:keys [email password]} body-params
        user (db/execute-one! ["SELECT * FROM users WHERE email = ?" email])]
    (if (and user (hashers/check password (:users/password_hash user)))
      (let [token (jwt/sign {:user-id (:users/id user)} secret {:exp (* 24 3600)})]
        {:status 200 :body {:token token}})
      {:status 401 :body {:error "Invalid credentials"}})))

(defn refresh-token [{:keys [identity]}]
  (let [token (jwt/sign {:user-id (:user-id identity)} secret {:exp (* 24 3600)})]
    {:status 200 :body {:token token}}))
