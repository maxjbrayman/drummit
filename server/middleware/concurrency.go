package middleware

import (
	"drummit/app/client"
	"net/http"
)

// LimitConcurrency lets at most max requests run next at the same time.
// Requests beyond that are turned away with a 503 straight away instead of
// waiting in a queue, so a burst of traffic can't pile up open connections
// and memory (each one holds an image of up to 10MB).
func LimitConcurrency(max int, next http.Handler) http.Handler {
	// A buffered channel works as a counting semaphore: its capacity is the
	// number of slots, and each running request holds one slot.
	slots := make(chan struct{}, max)

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		select {
		case slots <- struct{}{}:
			// Got a slot. Give it back when this request finishes, however
			// it finishes.
			defer func() { <-slots }()
			next.ServeHTTP(w, r)
		default:
			// All slots taken. select picks default when no other case can
			// proceed without waiting.
			w.Header().Set("Retry-After", "5")
			client.JsonError(w, "server is busy, try again shortly", http.StatusServiceUnavailable)
		}
	})
}
