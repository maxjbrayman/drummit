package main

import (
	"context"
	"drummit/app/client"
	"drummit/app/middleware"
	"drummit/app/routes"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"

	"firebase.google.com/go/v4/appcheck"
	"google.golang.org/genai"
)

type Server struct {
	Mux      *http.ServeMux
	Gemini   *genai.Client
	AppCheck *appcheck.Client

	MaxConcurrent int
	DailyCap      *middleware.DailyCap
}

func (s *Server) Routes() {
	// A request passes through these checks from the outside in, and each
	// one can turn it away before it reaches the (paid) Gemini call:
	//   1. App Check: is this our real app?
	//   2. Concurrency: is there a free slot right now?
	//   3. Daily cap: is there room left in today's budget?
	var detection http.Handler = &routes.DetectionHandler{Gemini: s.Gemini}
	detection = s.DailyCap.Wrap(detection)
	detection = middleware.LimitConcurrency(s.MaxConcurrent, detection)
	detection = middleware.RequireAppCheck(s.AppCheck, detection)
	s.Mux.Handle("/detection", detection)

	// Health checks come from your host, not the app, so they stay open.
	s.Mux.HandleFunc("GET /health-check", routes.HealthCheckHandler)
}

func initializeHttpServer() {
	ctx := context.Background()

	gemini, err := client.NewGeminiClient(ctx)
	if err != nil {
		log.Fatalf("creating Gemini client: %v", err)
	}

	appCheck, err := client.NewAppCheckClient(ctx)
	if err != nil {
		log.Fatalf("creating App Check client: %v", err)
	}

	maxConcurrent := envInt("DETECTION_MAX_CONCURRENT", 5)
	dailyLimit := envInt("DETECTION_DAILY_LIMIT", 500)
	log.Printf("detection limits: %d at once, %d per day", maxConcurrent, dailyLimit)

	srv := &Server{
		Mux:           http.NewServeMux(),
		Gemini:        gemini,
		AppCheck:      appCheck,
		MaxConcurrent: maxConcurrent,
		DailyCap:      middleware.NewDailyCap(dailyLimit),
	}
	srv.Routes()

	// Hosting platforms choose the port and pass it in PORT. Locally, where
	// PORT usually isn't set, fall back to 8080.
	port := strings.TrimSpace(os.Getenv("PORT"))
	if port == "" {
		port = "8080"
	}

	httpServer := &http.Server{
		Addr:    ":" + port,
		Handler: srv.Mux,

		// How long a client gets to send its request headers. Short, because
		// headers are tiny. This is the main defence against "slowloris"
		// clients that hold connections open by sending headers very slowly.
		ReadHeaderTimeout: 10 * time.Second,

		// How long a client gets to send the whole request, image included.
		// Counted from when the connection is accepted.
		ReadTimeout: uploadTimeout,

		// How long the server has to finish writing the response. Counted
		// from when the headers have been read, so it has to cover the
		// upload, the Gemini call and sending the result, plus some margin.
		WriteTimeout: uploadTimeout + routes.GeminiTimeout + 15*time.Second,

		// How long an idle keep-alive connection stays open waiting for the
		// client's next request.
		IdleTimeout: 60 * time.Second,
	}

	// stopCtx is cancelled when the process is asked to stop: SIGTERM is what
	// hosting platforms send before a redeploy or scale-down, and
	// os.Interrupt is Ctrl+C in your terminal.
	stopCtx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	// ListenAndServe blocks until the server stops, so it runs in its own
	// goroutine, leaving this one free to wait for a stop signal.
	serveErr := make(chan error, 1)
	go func() {
		log.Printf("listening on port %s", port)
		serveErr <- httpServer.ListenAndServe()
	}()

	// Wait for whichever comes first: the server failing on its own (e.g.
	// the port is already in use) or a stop signal.
	select {
	case err := <-serveErr:
		log.Fatalf("server stopped unexpectedly: %v", err)
	case <-stopCtx.Done():
	}

	// Restore default signal handling, so a second Ctrl+C quits immediately
	// instead of waiting for the shutdown below.
	stop()

	log.Printf("shutting down: no new requests, waiting up to %s for running ones", shutdownTimeout)
	shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
	defer cancel()

	// Shutdown stops accepting new connections, closes idle ones, and waits
	// for requests already in progress to finish, or for shutdownCtx to run
	// out.
	if err := httpServer.Shutdown(shutdownCtx); err != nil {
		log.Printf("shutdown: gave up waiting for running requests: %v", err)
		return
	}
	log.Printf("shutdown complete")
}

// shutdownTimeout is how long a stopping server waits for running scans to
// finish. Most scans finish well within it. Hosting platforms also give a
// stopping server a fixed grace period before force-killing it (e.g. 10s
// on Cloud Run, configurable on Fly.io), and that limit applies whatever
// this value is.
const shutdownTimeout = 30 * time.Second

// uploadTimeout is how long a client may take to upload a request. Scans are
// usually a few MB, which takes seconds; 60s leaves room for a slow mobile
// connection without letting a stalled client hold a connection open for long.
const uploadTimeout = 60 * time.Second

// envInt reads a positive integer from the named env var, or returns def if
// the variable is unset. It stops the server if the value is set but isn't a
// positive integer, so a typo can't quietly switch a limit off.
func envInt(name string, def int) int {
	raw := strings.TrimSpace(os.Getenv(name))
	if raw == "" {
		return def
	}
	n, err := strconv.Atoi(raw)
	if err != nil || n < 1 {
		log.Fatalf("%s must be a positive integer, got %q", name, raw)
	}
	return n
}
