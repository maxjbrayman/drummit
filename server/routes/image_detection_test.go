package routes

import (
	"errors"
	"fmt"
	"net/http"
	"testing"

	"google.golang.org/genai/interactions/models/apierrors"
	"google.golang.org/genai/interactions/models/components"
)

func TestGeminiStatusCode(t *testing.T) {
	meta := func(code int) components.HTTPMetadata {
		return components.HTTPMetadata{Response: &http.Response{StatusCode: code}}
	}

	tests := []struct {
		name string
		err  error
		want int
	}{
		{"4xx error", &apierrors.CreateInteractionClientError{HTTPMeta: meta(429)}, 429},
		{"5xx error", &apierrors.CreateInteractionServerError{HTTPMeta: meta(503)}, 503},
		{"unexpected reply", apierrors.NewAPIError("unknown status code returned", 418, "", nil), 418},
		{"wrapped error", fmt.Errorf("calling gemini: %w", &apierrors.CreateInteractionClientError{HTTPMeta: meta(429)}), 429},
		{"no reply at all", errors.New("connection refused"), 0},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := geminiStatusCode(tt.err); got != tt.want {
				t.Errorf("got %d, want %d", got, tt.want)
			}
		})
	}
}
