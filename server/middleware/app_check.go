package middleware

import (
	"drummit/app/client"
	"log"
	"net/http"

	"firebase.google.com/go/v4/appcheck"
)

// appCheckHeader is the header Firebase's docs use for App Check tokens. The
// iOS app must send its token under this exact name.
const appCheckHeader = "X-Firebase-AppCheck"

// RequireAppCheck wraps next so it only runs for requests carrying a valid
// Firebase App Check token. Requests without one get a 401 and never reach
// next, so they cost nothing.
func RequireAppCheck(appCheck *appcheck.Client, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get(appCheckHeader)
		if token == "" {
			log.Printf("app check: missing token from %s", r.RemoteAddr)
			client.JsonError(w, "unauthorized", http.StatusUnauthorized)
			return
		}

		if _, err := appCheck.VerifyToken(token); err != nil {
			log.Printf("app check: invalid token from %s: %v", r.RemoteAddr, err)
			client.JsonError(w, "unauthorized", http.StatusUnauthorized)
			return
		}

		next.ServeHTTP(w, r)
	})
}
