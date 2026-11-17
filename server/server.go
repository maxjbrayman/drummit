package main

import (
	"context"
	"drummit/app/client"
	"drummit/app/middleware"
	"drummit/app/routes"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"

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

	log.Fatal(http.ListenAndServe(":8080", srv.Mux))
}

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
