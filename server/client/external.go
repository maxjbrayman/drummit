package client

import (
	"context"

	"google.golang.org/genai"
)

// NewGeminiClient creates the shared Gemini client. Call it once at startup.
// With a nil config it reads the API key from the GEMINI_API_KEY env var.
func NewGeminiClient(ctx context.Context) (*genai.Client, error) {
	return genai.NewClient(ctx, nil)
}
