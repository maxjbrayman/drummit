package routes

import (
	"encoding/json"
	"log"
	"net/http"
)

func HealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	// 2. Initialize your data structure
	response := map[string]string{
		"ok": "true",
	}

	// 3. Encode the struct directly to the response writer
	err := json.NewEncoder(w).Encode(response)
	if err != nil {
		// Handle potential encoding errors gracefully
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		log.Printf("Failed to encode JSON: %v", err)
		return
	}
}