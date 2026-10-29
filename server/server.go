package main

import (
	"context"
	"drummit/app/client"
	"drummit/app/routes"
	"log"
	"net/http"

	"google.golang.org/genai"
)

type Server struct {
	Mux    *http.ServeMux
	Gemini *genai.Client
}

func (s *Server) Routes() {
	s.Mux.Handle("/detection", &routes.DetectionHandler{Gemini: s.Gemini})
	s.Mux.HandleFunc("GET /health-check", routes.HealthCheckHandler)
}

func initializeHttpServer() {
	gemini, err := client.NewGeminiClient(context.Background())
	if err != nil {
		log.Fatalf("creating Gemini client: %v", err)
	}

	srv := &Server{Mux: http.NewServeMux(), Gemini: gemini}
	srv.Routes()

	log.Fatal(http.ListenAndServe(":8080", srv.Mux))
}
