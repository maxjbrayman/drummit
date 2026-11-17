package middleware

import (
	"drummit/app/client"
	"log"
	"net/http"
	"sync"
	"time"
)

// DailyCap counts requests per UTC day and turns requests away once the day's
// limit is reached. It is a hard ceiling on how many Gemini calls, and so
// how much spend, one day can produce, however many users there are.
//
// The count lives in memory, so it assumes a single server instance and
// starts again from zero if the server restarts.
type DailyCap struct {
	limit int

	mu    sync.Mutex // guards day and count, which every request touches
	day   string     // the UTC date being counted, e.g. "2026-11-16"
	count int
}

func NewDailyCap(limit int) *DailyCap {
	return &DailyCap{limit: limit}
}

// allow reports whether one more request fits under today's limit, and if
// so, counts it.
func (c *DailyCap) allow() bool {
	today := time.Now().UTC().Format(time.DateOnly)

	c.mu.Lock()
	defer c.mu.Unlock()

	// First request of a new day: start counting again.
	if today != c.day {
		c.day = today
		c.count = 0
	}

	if c.count >= c.limit {
		return false
	}
	c.count++
	return true
}

// Wrap returns a handler that only runs next while today's limit has room.
func (c *DailyCap) Wrap(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !c.allow() {
			log.Printf("daily cap: limit of %d reached, rejecting request", c.limit)
			client.JsonError(w, "daily scan limit reached, try again tomorrow", http.StatusServiceUnavailable)
			return
		}
		next.ServeHTTP(w, r)
	})
}
