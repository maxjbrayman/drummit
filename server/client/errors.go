package client

import (
	"encoding/json"
	"net/http"
)

type APIError struct {
	Error string `json:"error"`
}

func JsonError(w http.ResponseWriter, message string, statusCode int) {
	// 1. Set the correct JSON header first
	w.Header().Set("Content-Type", "application/json")
	
	// 2. Set the HTTP response status code
	w.WriteHeader(statusCode)
	
	// 3. Encode and send your payload
	json.NewEncoder(w).Encode(APIError{
		Error: message,
	})
}