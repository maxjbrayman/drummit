package middleware

import (
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"
)

// okHandler stands in for the real detection handler.
var okHandler = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
})

func call(h http.Handler) int {
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, "/detection", nil))
	return rec.Code
}

func TestDailyCapStopsAtLimit(t *testing.T) {
	h := NewDailyCap(3).Wrap(okHandler)

	for i := 1; i <= 3; i++ {
		if code := call(h); code != http.StatusOK {
			t.Fatalf("request %d: got %d, want 200", i, code)
		}
	}
	if code := call(h); code != http.StatusServiceUnavailable {
		t.Fatalf("request 4: got %d, want 503", code)
	}
}

func TestDailyCapResetsOnNewDay(t *testing.T) {
	c := NewDailyCap(1)
	h := c.Wrap(okHandler)

	call(h)
	if code := call(h); code != http.StatusServiceUnavailable {
		t.Fatalf("got %d, want 503 once the limit is used", code)
	}

	// Pretend the stored count belongs to yesterday.
	c.mu.Lock()
	c.day = "2000-01-01"
	c.mu.Unlock()

	if code := call(h); code != http.StatusOK {
		t.Fatalf("got %d, want 200 on a new day", code)
	}
}

func TestLimitConcurrencyRejectsWhenFull(t *testing.T) {
	const max = 2
	started := make(chan struct{})
	release := make(chan struct{})

	// A handler that stays busy until we close release.
	slow := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		started <- struct{}{}
		<-release
		w.WriteHeader(http.StatusOK)
	})
	h := LimitConcurrency(max, slow)

	// Fill every slot with a request that's still running.
	var wg sync.WaitGroup
	for range max {
		wg.Go(func() { call(h) })
		<-started
	}

	// The next request finds no free slot.
	if code := call(h); code != http.StatusServiceUnavailable {
		t.Fatalf("got %d, want 503 while all slots are busy", code)
	}

	// Once the slow requests finish, their slots are free again.
	close(release)
	wg.Wait()
	go func() { <-started }()
	if code := call(h); code != http.StatusOK {
		t.Fatalf("got %d, want 200 after slots are freed", code)
	}
}
