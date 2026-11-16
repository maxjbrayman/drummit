package main

import (
	"context"
	"drummit/app/client"
	"drummit/app/middleware"
	"drummit/app/routes"
	"log"
	"net/http"

	"firebase.google.com/go/v4/appcheck"
	"google.golang.org/genai"
)

type Server struct {
	Mux      *http.ServeMux
	Gemini   *genai.Client
	AppCheck *appcheck.Client
}

func (s *Server) Routes() {
	// Only requests with a valid App Check token reach the Gemini call.
	s.Mux.Handle("/detection", middleware.RequireAppCheck(
		s.AppCheck,
		&routes.DetectionHandler{Gemini: s.Gemini},
	))
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

	srv := &Server{Mux: http.NewServeMux(), Gemini: gemini, AppCheck: appCheck}
	srv.Routes()

	log.Fatal(http.ListenAndServe(":8080", srv.Mux))
}
